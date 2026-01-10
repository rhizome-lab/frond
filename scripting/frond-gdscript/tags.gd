class_name FrondTags
extends RefCounted
## Tag-based query system for constraint checking.
##
## Tags are strings. Queries support:
## - "tag" - must have tag
## - "!tag" - must NOT have tag
## - ["a", "b"] - must have ALL (AND)
## - Use match_any() for OR queries

var _tags: Dictionary = {}  # String -> bool (set)


func _init(initial_tags: Array = []) -> void:
	for tag in initial_tags:
		_tags[String(tag)] = true


func add(tag: String) -> FrondTags:
	_tags[tag] = true
	return self


func remove(tag: String) -> FrondTags:
	_tags.erase(tag)
	return self


func has(tag: String) -> bool:
	return _tags.has(tag)


func has_all(tags: Array) -> bool:
	for tag in tags:
		if not _tags.has(tag):
			return false
	return true


func has_any(tags: Array) -> bool:
	for tag in tags:
		if _tags.has(tag):
			return true
	return false


## Check a single query term: "tag" or "!tag"
func matches_term(term: String) -> bool:
	if term.begins_with("!"):
		return not _tags.has(term.substr(1))
	else:
		return _tags.has(term)


## Check all query terms (AND logic)
## Example: matches(["hand", "!clawed"]) -> has hand AND not clawed
func matches(query: Array) -> bool:
	for term in query:
		if not matches_term(term):
			return false
	return true


## Check any query term (OR logic)
func matches_any(query: Array) -> bool:
	for term in query:
		if matches_term(term):
			return true
	return false


func to_array() -> Array[String]:
	var result: Array[String] = []
	result.assign(_tags.keys())
	return result


func duplicate() -> FrondTags:
	var copy = FrondTags.new()
	copy._tags = _tags.duplicate()
	return copy


func _to_string() -> String:
	return "Tags(%s)" % [", ".join(_tags.keys())]
