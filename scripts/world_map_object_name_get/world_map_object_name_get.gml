/// @description Reuses squad unit names and makes enemy/building asset names readable in tooltips.
function world_map_object_name_get(_object)
{
	if (!object_exists(_object)) return "Unknown";
	var _name = hud_unit_display_name_get(_object);
	if (string_copy(_name, 1, 2) == "o_")
	{
		_name = string_delete(_name, 1, 2);
		_name = string_replace(_name, "enemy_", "");
		_name = string_replace_all(_name, "_", " ");
		_name = string_upper(string_char_at(_name, 1)) + string_delete(_name, 1, 1);
	}
	return _name;
}
