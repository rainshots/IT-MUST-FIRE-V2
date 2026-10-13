/// @description Draws expandable ammo slots, their hover names, the FIRE button, and the world-scaled aim circle.
function cannon_ammo_draw()
{
	if (fight_state == FIGHT_STATE.WON || fight_state == FIGHT_STATE.LOST) return;
	var _scale = clamp(display_get_gui_height() / 1080, 0.6, 1);
	var _left = display_get_gui_width() - 328 * _scale;
	var _top = 172 * _scale;
	var _spacing = 54 * _scale;
	var _radius = 18 * _scale;
	var _colors = [COLOR_CANNON_NORMAL, COLOR_CANNON_POISON, COLOR_CANNON_NECRO, COLOR_CANNON_FIRE];
	var _names = ["Normal ball", "Poisoned ball", "Necro ball", "Fire Ball"];
	var _columns = 5;
	var _mx = device_mouse_x_to_gui(0);
	var _my = device_mouse_y_to_gui(0);
	draw_set_alpha(1);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	for (var _index = 0; _index < cannon_ammo_capacity; ++_index)
	{
		var _icon_y = _top + (_index div _columns) * _spacing;
		var _x = _left + _radius + (_index mod _columns) * _spacing;
		var _loaded = _index < array_length(cannon_ammo);
		draw_set_color(_loaded ? _colors[cannon_ammo[_index]] : COLOR_HUD_BACKGROUND);
		draw_circle(_x, _icon_y, _radius, false);
		draw_set_color(COLOR_HUD_TEXT);
		draw_circle(_x, _icon_y, _radius, true);
		if (_loaded)
		{
			var _type = cannon_ammo[_index];
			// Distinct glyphs supplement color: cannonball, poison drops, skull, and flame.
			if (_type == CANNONBALL_TYPE.NORMAL) draw_circle(_x - _radius * 0.3, _icon_y - _radius * 0.3, _radius * 0.2, false);
			else if (_type == CANNONBALL_TYPE.POISON)
			{
				draw_circle(_x - _radius * 0.3, _icon_y, _radius * 0.2, false);
				draw_circle(_x + _radius * 0.3, _icon_y - _radius * 0.3, _radius * 0.25, false);
			}
			else if (_type == CANNONBALL_TYPE.NECRO)
			{
				draw_circle(_x, _icon_y - _radius * 0.15, _radius * 0.5, false);
				draw_rectangle(_x - _radius * 0.3, _icon_y, _x + _radius * 0.3, _icon_y + _radius * 0.5, false);
				draw_set_color(COLOR_HUD_BACKGROUND);
				draw_circle(_x - _radius * 0.2, _icon_y - _radius * 0.15, _radius * 0.12, false);
				draw_circle(_x + _radius * 0.2, _icon_y - _radius * 0.15, _radius * 0.12, false);
			}
			else draw_triangle(_x - _radius * 0.4, _icon_y + _radius * 0.4, _x, _icon_y - _radius * 0.7, _x + _radius * 0.4, _icon_y + _radius * 0.4, false);
			if (point_distance(_mx, _my, _x, _icon_y) <= _radius)
			{
				draw_set_color(COLOR_HUD_TEXT);
				draw_text_transformed(_left + 130 * _scale, _icon_y + 35 * _scale, _names[_type], _scale * 0.7, _scale * 0.7, 0);
			}
		}
	}
	if (!global.pause && global.focus_window == FOCUS_WINDOW.NOONE && !debug_menu_open && fight_state == FIGHT_STATE.ACTIVE)
	{
		if (cannon_aiming && instance_exists(o_camera_controller))
		{
			var _camera = o_camera_controller.camera_id;
			var _rx = BALANCE_CANNON_TARGET_RADIUS * display_get_gui_width() / camera_get_view_width(_camera);
			var _ry = BALANCE_CANNON_TARGET_RADIUS * display_get_gui_height() / camera_get_view_height(_camera);
			draw_set_color(COLOR_CANNON_FIRE);
			draw_set_alpha(0.2);
			draw_ellipse(_mx - _rx, _my - _ry, _mx + _rx, _my + _ry, false);
			draw_set_alpha(1);
			draw_ellipse(_mx - _rx, _my - _ry, _mx + _rx, _my + _ry, true);
			draw_set_color(COLOR_HUD_TEXT);
			draw_text(_mx, _my + _ry + 24, "Click to fire - RMB / Esc to cancel");
		}
		else if (fight_charge >= BALANCE_FIGHT_CHARGE_MAX && array_length(cannon_ammo) > 0)
		{
			var _rect = cannon_fire_rect_get();
			draw_set_color(COLOR_HUD_BACKGROUND);
			draw_rectangle(_rect.x, _rect.y, _rect.x + _rect.width, _rect.y + _rect.height, false);
			draw_set_color(COLOR_HUD_TEXT);
			draw_text(_rect.x + _rect.width * 0.5, _rect.y + _rect.height * 0.5, "FIRE!");
		}
	}
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
}
