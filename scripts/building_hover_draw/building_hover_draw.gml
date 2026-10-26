/// @description Shows placed-building descriptions near the cursor; controller context.
function building_hover_draw()
{
	if (!instance_exists(o_camera_controller) || global.focus_window != FOCUS_WINDOW.NOONE
		|| debug_menu_open || instance_exists(shop_preview) || instance_exists(worker_dragged)
		|| fight_state == FIGHT_STATE.LOST || fight_state == FIGHT_STATE.WON) return;
	var _mx = device_mouse_x_to_gui(0);
	var _my = device_mouse_y_to_gui(0);
	var _bar = shop_offer_rect(-1);
	if (_my >= _bar.y) return;
	var _mode = player_unit_mode_rect();
	if (point_in_rectangle(_mx, _my, _mode.x, _mode.y, _mode.x + _mode.width, _mode.y + _mode.height)) return;
	var _speed = game_speed_button_rect();
	if (point_in_rectangle(_mx, _my, _speed.x, _speed.y, _speed.x + _speed.width, _speed.y + _speed.height)) return;
	var _outlines = building_outlines_button_rect();
	if (point_in_rectangle(_mx, _my, _outlines.x, _outlines.y, _outlines.x + _outlines.width, _outlines.y + _outlines.height)) return;
	var _camera = o_camera_controller.camera_id;
	var _x = camera_get_view_x(_camera) + _mx * camera_get_view_width(_camera) / display_get_gui_width();
	var _y = camera_get_view_y(_camera) + _my * camera_get_view_height(_camera) / display_get_gui_height();
	var _building = noone;
	with (o_worker_building_parent)
	{
		if (is_grid_trash || placement_preview || is_being_dragged) continue;
		var _bounds = building_bounds_get(id, x, y);
		if (point_in_rectangle(_x, _y, _bounds.left, _bounds.top, _bounds.right, _bounds.bottom))
			if (!instance_exists(_building) || depth < _building.depth) _building = id;
	}
	if (!instance_exists(_building))
	{
		with (o_living_house)
			if (point_in_rectangle(_x, _y, bbox_left, bbox_top, bbox_right, bbox_bottom)) _building = id;
		with (o_base_tower)
			if (point_in_rectangle(_x, _y, bbox_left, bbox_top, bbox_right, bbox_bottom)) _building = id;
	}
	if (!instance_exists(_building)) return;
	var _description = "";
	var _pool = shop_offer_pool_get();
	for (var _i = 0; _i < array_length(_pool); ++_i)
		if (_pool[_i].object == _building.object_index) { _description = _pool[_i].description; break; }
	switch (_building.object_index)
	{
		case o_living_house: _description = "Spawns defenders when player units approach within 300px, then replaces one fallen guard every minute. Destroy for 15 Mana."; break;
		case o_defense_tower: _description = "Fires explosive shots at player units. Destroy for 30 Mana."; break;
		case o_base_tower: _description = "Destroy the Base Tower to finish the fight."; break;
		case o_new_idol: _description = "Protect this outpost. If destroyed, a Cultist must repair it for 3 minutes before this Grid can work again."; break;
		case o_heart: _description = "Protect The Heart. If it is destroyed, the game ends."; break;
		case o_super_graveyard: _description = "A working Cultist summons Skeleton Mages.\nFully upgraded."; break;
		case o_unholy_shrine: _description = "A working Cultist summons Balgors.\nFully upgraded."; break;
		case o_feast_table: _description = "A working Cultist heals idle units with 50% more healing than a Kitchen.\nFully upgraded."; break;
		case o_bomb_tower: _description = "Fires explosive projectiles at enemies while a Cultist works here.\nFully upgraded."; break;
		case o_big_hall: _description = "Adds +10 unit capacity while placed on the Grid. No worker required.\nFully upgraded."; break;
		case o_witch_well: _description = "A working Cultist generates 1 Mana every 5 seconds.\nFully upgraded."; break;
	}
	if (_description == "") return;
	if (font_exists(global.ui_font)) draw_set_font(global.ui_font);
	var _label = _building.object_index == o_base_tower ? "Base Tower" : _building.building_label;
	var _text = _label + "\n" + _description;
	var _scale = _bar.scale * BALANCE_BUILDING_TOOLTIP_SCALE;
	var _padding = BALANCE_SHOP_TOOLTIP_PADDING * _scale;
	var _width = min(BALANCE_SHOP_TOOLTIP_WIDTH * _scale, display_get_gui_width() - _padding * 2);
	var _text_scale = BALANCE_SHOP_TOOLTIP_TEXT_SCALE * _scale;
	var _wrap = (_width - _padding * 2) / _text_scale;
	var _height = string_height_ext(_text, -1, _wrap) * _text_scale + _padding * 2;
	var _left = clamp(_mx + _padding, _padding, display_get_gui_width() - _width - _padding);
	var _top = clamp(_my - _height - _padding, _padding, max(_padding, _bar.y - _height - _padding));
	draw_set_alpha(1);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_rectangle(_left, _top, _left + _width, _top + _height, false);
	draw_set_color(COLOR_HUD_TEXT);
	draw_rectangle(_left, _top, _left + _width, _top + _height, true);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_text_ext_transformed(_left + _padding, _top + _padding, _text, -1, _wrap, _text_scale, _text_scale, 0);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
}
