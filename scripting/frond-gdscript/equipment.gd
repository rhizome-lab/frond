class_name FrondEquipment
extends Resource
## Equipment definition - items that can be equipped to body slots.
##
## Equipment has constraints against body tags and a resolution
## strategy for when constraints are violated by transformations.

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""

## Which body slot this equips to
@export var slot: String = ""

## Tag constraints for this slot (uses FrondConstraints query format)
## Example: ["hand", "!clawed"] = needs hand, can't have claws
@export var constraints: Array[String] = []

## What happens when constraints are violated
## Options: "unequip", "degrade", "adapt", "destroy", "prompt", "custom"
@export var on_conflict: String = "unequip"

## For "degrade" strategy: stat penalties per violated constraint
@export var degrade_penalties: Dictionary = {}

## For "adapt" strategy: alternative constraints that also work
## If any alternative matches, equipment adapts instead of conflicting
@export var adapt_alternatives: Array = []  # Array of Array[String]

## Tags this equipment adds to the slot while equipped
@export var grants_tags: Array[String] = []

## Custom script for "custom" resolution strategy
@export var custom_resolver: GDScript = null


## Check if this equipment can be equipped to a body
func can_equip(body: FrondBody) -> Dictionary:
	if not body.has_slot(slot):
		return { "can_equip": false, "reason": "slot_missing", "slot": slot }

	var effective = body.get_effective_tags(slot)

	if not effective.matches(constraints):
		return { "can_equip": false, "reason": "constraints", "failed": _get_failed_terms(effective) }

	return { "can_equip": true }


## Check constraints and return violation info (for already-equipped items)
func check_constraints(body: FrondBody) -> Variant:
	var effective = body.get_effective_tags(slot)

	if effective.matches(constraints):
		return null  # No violation

	# Check if any adaptation alternative matches
	for alt in adapt_alternatives:
		if effective.matches(alt):
			return { "adapted": true, "alternative": alt }

	var failed = _get_failed_terms(effective)
	return {
		"equipment": id,
		"slot": slot,
		"constraints": constraints,
		"failed_terms": failed,
		"on_conflict": on_conflict,
	}


func _get_failed_terms(effective: FrondTags) -> Array:
	var failed: Array = []
	for term in constraints:
		if not effective.matches_term(term):
			failed.append(term)
	return failed


## Create from dictionary (for data-driven loading)
static func from_dict(data: Dictionary) -> FrondEquipment:
	var eq = FrondEquipment.new()
	eq.id = data.get("id", "")
	eq.display_name = data.get("display_name", eq.id)
	eq.description = data.get("description", "")
	eq.slot = data.get("slot", "")
	eq.constraints.assign(data.get("constraints", []))
	eq.on_conflict = data.get("on_conflict", "unequip")
	eq.degrade_penalties = data.get("degrade_penalties", {})
	eq.adapt_alternatives = data.get("adapt_alternatives", [])
	eq.grants_tags.assign(data.get("grants_tags", []))
	return eq


## Equipped items container - manages equipment on a body
class Loadout extends RefCounted:
	var _equipped: Dictionary = {}  # slot -> FrondEquipment
	var _body: FrondBody

	func _init(body: FrondBody) -> void:
		_body = body

	## Equip an item (returns success info)
	func equip(item: FrondEquipment) -> Dictionary:
		var check = item.can_equip(_body)
		if not check.can_equip:
			return check

		# Unequip existing
		if _equipped.has(item.slot):
			unequip(item.slot)

		_equipped[item.slot] = item
		return { "success": true, "slot": item.slot }

	## Unequip from a slot
	func unequip(slot: String) -> Variant:
		if not _equipped.has(slot):
			return null
		var item = _equipped[slot]
		_equipped.erase(slot)
		return item

	## Get equipped item in slot
	func get_equipped(slot: String) -> Variant:
		return _equipped.get(slot)

	## Get all equipped items
	func get_all_equipped() -> Dictionary:
		return _equipped.duplicate()

	## Check all equipment for constraint violations
	## Returns array of violation dicts
	func check_all_constraints() -> Array:
		var violations: Array = []
		for slot in _equipped:
			var item = _equipped[slot]
			var violation = item.check_constraints(_body)
			if violation and not violation.get("adapted", false):
				violations.append(violation)
		return violations

	## Apply resolution strategies to all violations
	## Returns dict of what happened: { unequipped: [], degraded: {}, ... }
	func resolve_violations() -> Dictionary:
		var result = {
			"unequipped": [],
			"degraded": {},
			"adapted": [],
			"destroyed": [],
			"prompted": [],
			"custom": [],
		}

		var violations = check_all_constraints()
		for v in violations:
			match v.on_conflict:
				"unequip":
					unequip(v.slot)
					result.unequipped.append(v.equipment)
				"degrade":
					var item = _equipped[v.slot]
					result.degraded[v.equipment] = item.degrade_penalties
				"destroy":
					unequip(v.slot)
					result.destroyed.append(v.equipment)
				"prompt":
					result.prompted.append(v)
				"custom":
					result.custom.append(v)
				_:
					# Default to unequip
					unequip(v.slot)
					result.unequipped.append(v.equipment)

		return result
