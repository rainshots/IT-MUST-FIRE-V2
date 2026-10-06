/// @description Draws the editor-placed route, original squad cards, and the right-hand information panel.
function world_map_draw(_map)
{
	if (!instance_exists(_map)) return;
	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);

	// Connections stop at the point borders and use s_level_line's own color and thickness.
	var _levels = _map.levels;
	var _count = array_length(_levels);
	var _line_width = max(1, sprite_get_width(s_level_line));
	for (var _index = 0; _index < _count; ++_index)
	{
		var _entry = _levels[_index];
		var _source = _entry.point;
		if (!instance_exists(_source)) continue;
		var _next_count = array_length(_entry.next_levels);
		for (var _next_index = 0; _next_index < _next_count; ++_next_index)
		{
			var _target = instance_find(_entry.next_levels[_next_index], 0);
			if (!instance_exists(_target) || _source == _target) continue;
			var _angle = point_direction(_source.x, _source.y, _target.x, _target.y);
			var _source_radius = sprite_get_width(_source.sprite_index) * abs(_source.image_xscale) * 0.44;
			var _target_radius = sprite_get_width(_target.sprite_index) * abs(_target.image_xscale) * 0.44;
			var _start_x = _source.x + lengthdir_x(_source_radius, _angle);
			var _start_y = _source.y + lengthdir_y(_source_radius, _angle);
			var _end_x = _target.x - lengthdir_x(_target_radius, _angle);
			var _end_y = _target.y - lengthdir_y(_target_radius, _angle);
			var _length = max(0, point_distance(_source.x, _source.y, _target.x, _target.y) - _source_radius - _target_radius);
			draw_sprite_ext(s_level_line, 0, (_start_x + _end_x) * 0.5, (_start_y + _end_y) * 0.5,
				_length / _line_width, _map.level_line_thickness_scale, _angle, c_white, 1);
		}
	}

	// Sprites alone express point state; reference numbers are deliberately not drawn.
	for (var _index = 0; _index < _count; ++_index)
	{
		var _point = _levels[_index].point;
		if (!instance_exists(_point)) continue;
		if (_point == _map.hovered_level || _point == _map.pinned_level)
		{
			draw_sprite_ext(s_map_point_03, 0, _point.x, _point.y,
				_point.image_xscale * _map.point_outline_scale, _point.image_yscale * _map.point_outline_scale,
				0, c_white, 1);
		}
		draw_sprite_ext(_point.sprite_index, 0, _point.x, _point.y,
			_point.image_xscale, _point.image_yscale, 0, c_white, 1);
	}
	world_map_roster_draw(_map);
	world_map_info_draw(_map);
	draw_set_font(_map.map_font);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
}
