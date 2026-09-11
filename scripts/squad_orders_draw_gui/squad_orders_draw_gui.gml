/// @description Draws the pending direct-order points and member links below the squad flag HUD.
function squad_orders_draw_gui()
{
	if (global.day_phase != DAY_PHASE.NIGHT || !instance_exists(o_camera_controller))
	{
		return;
	}
	var _camera = instance_find(o_camera_controller, 0);
	var _camera_x = camera_get_view_x(_camera.camera_id);
	var _camera_y = camera_get_view_y(_camera.camera_id);
	var _scale_x = display_get_gui_width() / max(1, camera_get_view_width(_camera.camera_id));
	var _scale_y = display_get_gui_height() / max(1, camera_get_view_height(_camera.camera_id));
	var _squad_count = array_length(global.squads);

	for (var _index = 0; _index < _squad_count; ++_index)
	{
		var _squad = global.squads[_index];
		if (!squad_order_is_active(_squad))
		{
			continue;
		}
		var _properties = _squad.properties;
		var _point_x = (_properties.order_x - _camera_x) * _scale_x;
		var _point_y = (_properties.order_y - _camera_y) * _scale_y;
		var _color = _properties.order_mode == SQUAD_ORDER.MOVE_AND_ATTACK
			? COLOR_SQUAD_ORDER_ATTACK : COLOR_SQUAD_ORDER_MOVE;
		draw_set_color(_color);
		draw_set_alpha(BALANCE_SQUAD_ORDER_LINE_ALPHA);
		var _unit_count = array_length(_squad.units);

		for (var _unit_index = 0; _unit_index < _unit_count; ++_unit_index)
		{
			var _unit = _squad.units[_unit_index];
			if (!instance_exists(_unit) || !_unit.visible || _unit.hp <= 0
				|| !variable_instance_exists(_unit, "squad_order_arrived")
				|| (_unit.squad_order_serial == _properties.order_serial && _unit.squad_order_arrived))
			{
				continue;
			}
			draw_line_width((_unit.x - _camera_x) * _scale_x, (_unit.y - _camera_y) * _scale_y,
				_point_x, _point_y, BALANCE_SQUAD_ORDER_LINE_WIDTH);
		}
		draw_set_alpha(BALANCE_SQUAD_SELECTION_ALPHA);
		draw_circle(_point_x, _point_y, BALANCE_SQUAD_ORDER_POINT_RADIUS, false);
	}
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
}
