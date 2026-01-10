class_name FrondTransformation
extends Resource
## Transformation definition - a template for body modifications.
##
## This is the "blueprint" - when applied to a body, it creates
## an active transformation instance with duration tracking.

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""

## Which slot this affects
@export var slot: String = ""

## Tags to add when active
@export var add_tags: Array[String] = []

## Tags to remove when active
@export var remove_tags: Array[String] = []

## Duration in seconds (0 or negative = permanent)
@export var base_duration: float = 0.0

## Tags that conflict - TF can't be applied if slot has any of these
@export var conflicts_with_tags: Array[String] = []

## Tags required on the slot to apply this TF
@export var requires_tags: Array[String] = []

## Conflict relationships with other TFs.
## Keys are TF ids (or "*" for default), values are arbitrary relationship strings.
## Examples: "stack", "replace", "block", "annihilate", "merge", or any custom string.
## Game logic decides what each relationship means.
@export var conflicts: Dictionary = {}  # { tf_id: relationship_string }


## Get the relationship with another TF by id.
## Returns the relationship string, or default ("*"), or null if no relationship defined.
func get_relationship(other_tf_id: String) -> Variant:
	if conflicts.has(other_tf_id):
		return conflicts[other_tf_id]
	if conflicts.has("*"):
		return conflicts["*"]
	return null


## Query all conflicts with currently active TFs on a body.
## Returns array of { existing_id, existing_tf, relationship } dicts.
## Game logic decides how to resolve each relationship.
func get_conflicts(body: FrondBody) -> Array:
	var result: Array = []
	for tf in body.get_transformations():
		var rel = get_relationship(tf.id)
		if rel != null:
			result.append({
				"existing_id": tf.id,
				"existing_tf": tf,
				"relationship": rel,
			})
	return result


## Check if this TF can be applied to a body slot
func can_apply(body: FrondBody) -> Dictionary:
	if not body.has_slot(slot):
		return { "can_apply": false, "reason": "slot_missing", "slot": slot }

	var effective = body.get_effective_tags(slot)

	# Check requirements
	for tag in requires_tags:
		if not effective.has(tag):
			return { "can_apply": false, "reason": "missing_required", "tag": tag }

	# Check conflicts
	for tag in conflicts_with_tags:
		if effective.has(tag):
			return { "can_apply": false, "reason": "conflicts", "tag": tag }

	return { "can_apply": true }


## Apply this transformation to a body.
## NOTE: This does NOT handle conflict resolution - call get_conflicts() first
## and resolve them according to your game's policy before calling apply().
## Returns the applied transformation dict, or null if can't apply.
func apply(body: FrondBody, duration_override: float = -1.0) -> Variant:
	var check = can_apply(body)
	if not check.can_apply:
		return null

	# Calculate duration
	var duration = duration_override if duration_override >= 0 else base_duration
	var tf_instance = {
		"id": id,
		"slot": slot,
		"add_tags": add_tags.duplicate(),
		"remove_tags": remove_tags.duplicate(),
		"duration": null if duration <= 0 else duration,
		"source": self,  # Reference back to definition
	}

	body.apply_transformation(tf_instance)
	return tf_instance


## Create a transformation definition from a dictionary (for data-driven loading)
static func from_dict(data: Dictionary) -> FrondTransformation:
	var tf = FrondTransformation.new()
	tf.id = data.get("id", "")
	tf.display_name = data.get("display_name", tf.id)
	tf.description = data.get("description", "")
	tf.slot = data.get("slot", "")
	tf.add_tags.assign(data.get("add_tags", []))
	tf.remove_tags.assign(data.get("remove_tags", []))
	tf.base_duration = data.get("base_duration", 0.0)
	tf.conflicts_with_tags.assign(data.get("conflicts_with_tags", []))
	tf.requires_tags.assign(data.get("requires_tags", []))
	tf.conflicts = data.get("conflicts", {})
	return tf
