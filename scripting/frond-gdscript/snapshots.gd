class_name FrondSnapshots
extends RefCounted
## Optional snapshot system for body state reversibility.
##
## Saves and restores body state (base tags + TF stack).
## Use when you need undo/revert functionality.
## Composable - doesn't modify FrondBody, just observes and restores.

var _body: FrondBody
var _snapshots: Dictionary = {}  # name -> snapshot data


func _init(body: FrondBody) -> void:
	_body = body


## Save current body state with a name.
## Overwrites if name already exists.
func save(name: String) -> void:
	_snapshots[name] = _capture()


## Restore body state from a named snapshot.
## Returns true if restored, false if snapshot doesn't exist.
func restore(name: String) -> bool:
	if not _snapshots.has(name):
		return false
	_apply(_snapshots[name])
	return true


## Check if a snapshot exists.
func has(name: String) -> bool:
	return _snapshots.has(name)


## Delete a snapshot.
func delete(name: String) -> bool:
	return _snapshots.erase(name)


## List all snapshot names.
func list() -> Array:
	return _snapshots.keys()


## Clear all snapshots.
func clear() -> void:
	_snapshots.clear()


## Get snapshot data without restoring (for inspection/serialization).
func get_snapshot(name: String) -> Variant:
	return _snapshots.get(name)


## Import snapshot data (for deserialization).
func set_snapshot(name: String, data: Dictionary) -> void:
	_snapshots[name] = data


## Compare current state to a snapshot.
## Returns { changed: bool, added_tags: {slot: [tags]}, removed_tags: {slot: [tags]} }
func diff(name: String) -> Dictionary:
	if not _snapshots.has(name):
		return { "error": "snapshot_not_found" }

	var snapshot = _snapshots[name]
	var current = _capture()
	var result = {
		"changed": false,
		"slots_added": [],
		"slots_removed": [],
		"tags_added": {},
		"tags_removed": {},
		"tfs_added": [],
		"tfs_removed": [],
	}

	# Compare slots
	var old_slots = snapshot.base_slots.keys()
	var new_slots = current.base_slots.keys()

	for slot in new_slots:
		if slot not in old_slots:
			result.slots_added.append(slot)
			result.changed = true

	for slot in old_slots:
		if slot not in new_slots:
			result.slots_removed.append(slot)
			result.changed = true

	# Compare tags per slot
	for slot in old_slots:
		if slot not in new_slots:
			continue
		var old_tags = snapshot.base_slots[slot]
		var new_tags = current.base_slots[slot]

		var added = []
		var removed = []

		for tag in new_tags:
			if tag not in old_tags:
				added.append(tag)
		for tag in old_tags:
			if tag not in new_tags:
				removed.append(tag)

		if added.size() > 0:
			result.tags_added[slot] = added
			result.changed = true
		if removed.size() > 0:
			result.tags_removed[slot] = removed
			result.changed = true

	# Compare transformations
	var old_tf_ids = snapshot.transformations.map(func(tf): return tf.id)
	var new_tf_ids = current.transformations.map(func(tf): return tf.id)

	for tf_id in new_tf_ids:
		if tf_id not in old_tf_ids:
			result.tfs_added.append(tf_id)
			result.changed = true

	for tf_id in old_tf_ids:
		if tf_id not in new_tf_ids:
			result.tfs_removed.append(tf_id)
			result.changed = true

	return result


# --- Internal ---

func _capture() -> Dictionary:
	var base_slots = {}
	for slot in _body.get_slots():
		base_slots[slot] = _body.get_base_tags(slot).to_array()

	var transformations = []
	for tf in _body.get_transformations():
		transformations.append(tf.duplicate(true))

	return {
		"base_slots": base_slots,
		"transformations": transformations,
	}


func _apply(snapshot: Dictionary) -> void:
	# Clear current TFs
	for tf in _body.get_transformations():
		_body.remove_transformation(tf.id)

	# Restore base slots
	for slot in snapshot.base_slots:
		_body.set_base_tags(slot, FrondTags.new(snapshot.base_slots[slot]))

	# Restore transformations
	for tf in snapshot.transformations:
		_body.apply_transformation(tf.duplicate(true))
