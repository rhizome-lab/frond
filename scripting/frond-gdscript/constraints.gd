class_name FrondConstraints
extends RefCounted
## Constraint checking system.
##
## Detects constraint violations without deciding resolution.
## Returns violations as dictionaries for game logic to handle.

## Check a single constraint against tags
## Returns null if passed, or a violation dict if failed:
## { source: String, constraint: Array, failed_terms: Array, context: Dictionary }
static func check(source: String, constraint: Array, tags: FrondTags, context: Dictionary = {}) -> Variant:
	var failed: Array = []
	for term in constraint:
		if not tags.matches_term(term):
			failed.append(term)

	if failed.is_empty():
		return null
	else:
		return {
			"source": source,
			"constraint": constraint,
			"failed_terms": failed,
			"context": context,
		}


## Check multiple constraints, return array of violation dicts
## constraints_dict: { "source_name": ["tag", "!tag", ...], ... }
static func check_all(constraints_dict: Dictionary, tags) -> Array:
	var violations: Array = []
	for source in constraints_dict:
		var violation = check(source, constraints_dict[source], tags)
		if violation:
			violations.append(violation)
	return violations


## Resolution strategy helpers

## Strategy: collect items that should be unequipped
static func resolve_unequip(violations: Array) -> Array:
	var to_unequip: Array = []
	for v in violations:
		to_unequip.append(v.source)
	return to_unequip


## Strategy: collect items with penalties (returns { source: failed_terms })
static func resolve_degrade(violations: Array) -> Dictionary:
	var penalties: Dictionary = {}
	for v in violations:
		penalties[v.source] = v.failed_terms
	return penalties
