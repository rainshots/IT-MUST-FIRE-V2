/// @description Picks only a deployed preparation flag at the same center and radius used by the HUD.
function battle_preparation_squad_at_world(_world_x, _world_y)
{
	var _layout = battle_ui_layout_get();
	var _world_scale = camera_get_view_width(view_camera[0]) / display_get_gui_width();
	var _radius = 20 * _layout.scale * _world_scale;
	var _squads = global.squads;
	var _count = array_length(_squads);
	for (var _index = _count - 1; _index >= 0; --_index)
	{
		var _squad = _squads[_index];
		if (_squad.properties.battle_deployed
			&& point_distance(_world_x, _world_y, _squad.properties.marker_x, _squad.properties.marker_y) <= _radius)
		{
			return _squad;
		}
	}
	return noone;
}
