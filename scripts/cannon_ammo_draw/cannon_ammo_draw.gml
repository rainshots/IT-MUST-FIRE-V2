/// @description Shows clickable Cannon contents, capacity, range preview and manual firing.
function cannon_ammo_draw()
{
	if (fight_state == FIGHT_STATE.WON || fight_state == FIGHT_STATE.LOST) return;
	var _used = cargo_capacity_used();
	var _scale = clamp(display_get_gui_height() / 1080, 0.6, 1);
	var _left = display_get_gui_width() - 328 * _scale;
	var _mx = device_mouse_x_to_gui(0); var _my = device_mouse_y_to_gui(0);
	draw_set_alpha(1); draw_set_color(COLOR_HUD_TEXT);
	draw_set_halign(fa_left); draw_set_valign(fa_top);
	draw_text_transformed(_left, 167 * _scale, "Capacity: " + string(_used) + " / " + string(cargo_capacity), _scale * 0.75, _scale * 0.75, 0);
	for (var _i = 0; _i < array_length(cargo_contents); ++_i)
	{
		var _item = cargo_contents[_i];
		var _rect = cargo_icon_rect_get(_i);
		draw_set_color(COLOR_HUD_BACKGROUND);
		draw_rectangle(_rect.x,_rect.y,_rect.x+_rect.size,_rect.y+_rect.size,false);
		draw_set_color(COLOR_HUD_TEXT);
		draw_rectangle(_rect.x,_rect.y,_rect.x+_rect.size,_rect.y+_rect.size,true);
		if (_item.sprite_index != -1)
		{
			var _sprite = _item.sprite_index;
			var _fit = (_rect.size - 8) / max(sprite_get_width(_sprite), sprite_get_height(_sprite));
			draw_sprite_ext(_sprite,0,_rect.x+_rect.size*0.5+(sprite_get_xoffset(_sprite)-sprite_get_width(_sprite)*0.5)*_fit,
				_rect.y+_rect.size*0.5+(sprite_get_yoffset(_sprite)-sprite_get_height(_sprite)*0.5)*_fit,_fit,_fit,0,c_white,1);
		}
		else
		{
			if (_item.object_index == o_exploding_shell)
				draw_set_color(_item.corruption_shell ? COLOR_CORRUPTION_SHELL : (_item.hell_shell ? COLOR_CANNON_FIRE : COLOR_CANNON_NORMAL));
			draw_circle(_rect.x+_rect.size*0.5,_rect.y+_rect.size*0.5,_rect.size*0.25,false);
			draw_set_color(COLOR_HUD_TEXT);
		}
		draw_text_transformed(_rect.x+3,_rect.y+3,string(_item.cargo_cost),0.5,0.5,0);
		if (point_in_rectangle(_mx,_my,_rect.x,_rect.y,_rect.x+_rect.size,_rect.y+_rect.size))
			draw_text_transformed(_left,310*_scale,"Click to unload",0.65*_scale,0.65*_scale,0);
	}
	if (!global.pause && fight_state == FIGHT_STATE.ACTIVE && global.focus_window == FOCUS_WINDOW.NOONE)
	{
		draw_set_halign(fa_center); draw_set_valign(fa_middle);
		if (cannon_aiming && instance_exists(o_camera_controller) && instance_exists(o_cannon))
		{
			var _camera = o_camera_controller.camera_id;
			var _sx = display_get_gui_width() / camera_get_view_width(_camera);
			var _sy = display_get_gui_height() / camera_get_view_height(_camera);
			var _cx = (o_cannon.x-camera_get_view_x(_camera))*_sx;
			var _cy = (o_cannon.y-camera_get_view_y(_camera))*_sy;
			var _range = cannon_range_get();
			draw_set_color(COLOR_HUD_TEXT);
			draw_ellipse(_cx-_range*_sx,_cy-_range*_sy,_cx+_range*_sx,_cy+_range*_sy,true);
			var _inside = point_distance((_mx-_cx)/_sx,(_my-_cy)/_sy,0,0)<=_range;
			draw_set_color(_inside ? COLOR_PROJECTILE_SUMMON : COLOR_STATUS_NEGATIVE_RED);
			draw_ellipse(_mx - BALANCE_CANNON_TARGET_RADIUS * _sx, _my - BALANCE_CANNON_TARGET_RADIUS * _sy,
				_mx + BALANCE_CANNON_TARGET_RADIUS * _sx, _my + BALANCE_CANNON_TARGET_RADIUS * _sy, true);
			draw_text_transformed(_mx,_my+30,"Range: "+string(round(_range))+"px - RMB / Esc cancels",0.65,0.65,0);
		}
		else if (fight_charge >= BALANCE_CARGO_MIN_CHARGE && _used > 0)
		{
			var _rect = cannon_fire_rect_get();
			draw_set_color(COLOR_HUD_BACKGROUND);
			draw_rectangle(_rect.x,_rect.y,_rect.x+_rect.width,_rect.y+_rect.height,false);
			draw_set_color(COLOR_HUD_TEXT);
			draw_text(_rect.x+_rect.width*0.5,_rect.y+_rect.height*0.5,"FIRE!");
		}
		if (cargo_notice_timer > 0)
		{
			draw_set_color(COLOR_STATUS_NEGATIVE_RED);
			draw_text_transformed(display_get_gui_width()*0.5,display_get_gui_height()*0.7,cargo_notice,0.7,0.7,0);
		}
	}
	draw_set_color(c_white);draw_set_alpha(1);draw_set_halign(fa_left);draw_set_valign(fa_top);
}
