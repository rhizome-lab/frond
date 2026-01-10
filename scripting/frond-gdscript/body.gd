class_name FrondBody
extends RefCounted
## Body system with slots, base state, and transformation stack.
##
## Each slot has base tags (the "natural" state).
## Transformations modify tags additively.
## Effective tags = base + transformation effects.

## Slot data: { slot_name: FrondTags }
var _base_slots: Dictionary = {}

## Active transformations: Array of transformation dicts
## Each: { id, slot, add_tags, remove_tags, duration (null = permanent) }
var _transformations: Array = []


func _init(slots: Dictionary = {}) -> void:
	for slot_name in slots:
		var tags = slots[slot_name]
		if tags is FrondTags:
			_base_slots[slot_name] = tags
		elif tags is Array:
			_base_slots[slot_name] = FrondTags.new(tags)


## Get base tags for a slot (unmodified by TFs)
func get_base_tags(slot: String) -> FrondTags:
	if not _base_slots.has(slot):
		return FrondTags.new()
	return _base_slots[slot].duplicate()


## Get effective tags for a slot (base + TF modifications)
func get_effective_tags(slot: String) -> FrondTags:
	var tags = get_base_tags(slot)

	for tf in _transformations:
		if tf.slot != slot:
			continue
		# Remove first, then add (order matters for conflicts)
		for tag in tf.get("remove_tags", []):
			tags.remove(tag)
		for tag in tf.get("add_tags", []):
			tags.add(tag)

	return tags


## Get all slot names
func get_slots() -> Array:
	return _base_slots.keys()


## Check if a slot exists
func has_slot(slot: String) -> bool:
	return _base_slots.has(slot)


## Add a new slot with base tags
func add_slot(slot: String, tags: Array = []) -> FrondBody:
	_base_slots[slot] = FrondTags.new(tags)
	return self


## Modify base tags directly (low-level)
func set_base_tags(slot: String, tags: FrondTags) -> FrondBody:
	_base_slots[slot] = tags
	return self


## Apply a transformation permanently to the base state.
## Unlike apply_transformation(), this modifies base tags directly.
## The TF "dissolves" into the body - no stack entry, can't be removed.
## Returns { success: bool, reason: String? }
func apply_permanent(tf: Dictionary) -> Dictionary:
	var slot = tf.get("slot", "")
	if not has_slot(slot):
		return { "success": false, "reason": "slot_missing" }

	var base = _base_slots[slot]

	# Remove tags first, then add (same order as effective calculation)
	for tag in tf.get("remove_tags", []):
		base.remove(tag)
	for tag in tf.get("add_tags", []):
		base.add(tag)

	return { "success": true }


## Apply a FrondTransformation resource permanently to base state.
## Checks requirements/conflicts before applying.
func apply_transformation_permanent(tf_def: Resource) -> Dictionary:
	var check = tf_def.can_apply(self)
	if not check.can_apply:
		return { "success": false, "reason": check.reason, "detail": check.get("tag", check.get("slot", "")) }

	# Remove TFs this one replaces (from the stack)
	for replace_id in tf_def.replaces:
		remove_transformation(replace_id)

	return apply_permanent({
		"slot": tf_def.slot,
		"add_tags": tf_def.add_tags,
		"remove_tags": tf_def.remove_tags,
	})


# --- Transformation Stack (Indefinite/Temporary) ---

## Apply a transformation
## tf: { id: String, slot: String, add_tags: Array, remove_tags: Array, duration: float or null }
func apply_transformation(tf: Dictionary) -> FrondBody:
	# Validate required fields
	assert(tf.has("id"), "Transformation must have 'id'")
	assert(tf.has("slot"), "Transformation must have 'slot'")

	# Remove existing TF with same id (no duplicates)
	remove_transformation(tf.id)

	_transformations.append(tf)
	return self


## Remove a transformation by id
func remove_transformation(id: String) -> bool:
	for i in range(_transformations.size() - 1, -1, -1):
		if _transformations[i].id == id:
			_transformations.remove_at(i)
			return true
	return false


## Get all active transformations
func get_transformations() -> Array:
	return _transformations.duplicate()


## Get transformations affecting a specific slot
func get_transformations_for_slot(slot: String) -> Array:
	return _transformations.filter(func(tf): return tf.slot == slot)


## Check if a transformation is active
func has_transformation(id: String) -> bool:
	for tf in _transformations:
		if tf.id == id:
			return true
	return false


## Get a transformation by id
func get_transformation(id: String) -> Variant:
	for tf in _transformations:
		if tf.id == id:
			return tf
	return null


## Update durations (call each frame/tick with delta)
## Returns array of expired transformation ids
func tick(delta: float) -> Array:
	var expired: Array = []

	for tf in _transformations:
		if tf.duration == null:
			continue  # Permanent
		tf.duration -= delta
		if tf.duration <= 0:
			expired.append(tf.id)

	# Remove expired
	for id in expired:
		remove_transformation(id)

	return expired


## Get all effective tags for all slots (for constraint checking)
func get_all_effective_tags() -> Dictionary:
	var result: Dictionary = {}
	for slot in _base_slots:
		result[slot] = get_effective_tags(slot)
	return result


func _to_string() -> String:
	return "Body(slots=%s, tfs=%d)" % [_base_slots.keys(), _transformations.size()]
