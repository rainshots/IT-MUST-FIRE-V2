/// @description Handles cargo unloading, map pickup, Cannon loading, and building relocation; controller context.
function cargo_drag_update()
{
	cargo_notice_timer = max(0, cargo_notice_timer - 1 / max(1, room_speed));
	if (global.pause || fight_state != FIGHT_STATE.ACTIVE || global.focus_window != FOCUS_WINDOW.NOONE)
	{
		if (instance_exists(cargo_dragged))
		{
			cargo_dragged.x = cargo_drag_start_x; cargo_dragged.y = cargo_drag_start_y;
			cargo_dragged.is_being_dragged = false;
		}
		cargo_dragged = noone;
		return false;
	}
	if (cannon_aiming || !instance_exists(o_camera_controller) || instance_exists(worker_dragged)) return false;
	var _camera = o_camera_controller.camera_id;
	var _mx = device_mouse_x_to_gui(0); var _my = device_mouse_y_to_gui(0);
	var _wx = camera_get_view_x(_camera) + _mx * camera_get_view_width(_camera) / display_get_gui_width();
	var _wy = camera_get_view_y(_camera) + _my * camera_get_view_height(_camera) / display_get_gui_height();
	if (!instance_exists(cargo_dragged) && mouse_check_button_pressed(mb_left))
	{
		for (var _i = 0; _i < array_length(cargo_contents); ++_i)
		{
			var _rect = cargo_icon_rect_get(_i);
			if (point_in_rectangle(_mx, _my, _rect.x, _rect.y, _rect.x + _rect.size, _rect.y + _rect.size)) { cargo_unload(_i); return true; }
		}
		var _fire = cannon_fire_rect_get();
		if (fight_charge >= BALANCE_CARGO_MIN_CHARGE && cargo_capacity_used() > 0
			&& point_in_rectangle(_mx,_my,_fire.x,_fire.y,_fire.x+_fire.width,_fire.y+_fire.height)) return false;
		var _purchase = shop_button_rect();
		if (_my >= _purchase.y) return false;
		// Cultists retain priority over buildings so assigned workers can be picked up.
		var _cultist_hit = false;
		with (o_cultist) if (point_in_rectangle(_wx, _wy, bbox_left, bbox_top, bbox_right, bbox_bottom)) _cultist_hit = true;
		if (_cultist_hit) return false;
		var _candidate = noone;
		with (all)
		{
			var _portable = object_index == o_exploding_shell || object_is_ancestor(object_index, o_friendly_units);
			if (!_portable || !visible) continue;
			if (variable_instance_exists(id, "hp") && hp <= 0) continue;
			var _hit = sprite_index == -1 ? point_distance(x,y,_wx,_wy) <= 24 : point_in_rectangle(_wx,_wy,bbox_left,bbox_top,bbox_right,bbox_bottom);
			if (_hit && (!instance_exists(_candidate) || depth < _candidate.depth)) _candidate = id;
		}
		if (instance_exists(_candidate))
		{
			cargo_dragged = _candidate; cargo_drag_start_x = _candidate.x; cargo_drag_start_y = _candidate.y;
			_candidate.is_being_dragged = true;
			if (worker_cursor_hidden) window_set_cursor(cr_default);
			worker_cursor_hidden = false; worker_hovered = noone;
		}
	}
	if (!instance_exists(cargo_dragged)) return false;
	cargo_dragged.x = _wx; cargo_dragged.y = _wy;
	if (mouse_check_button_pressed(mb_right) || !mouse_check_button(mb_left))
	{
		var _cancel = mouse_check_button_pressed(mb_right);
		var _building = object_is_ancestor(cargo_dragged.object_index, o_worker_building_parent);
		if (_building)
		{
			if (!building_place_valid(cargo_dragged, _wx, _wy))
			{
				_cancel = true; cargo_notice = "Place buildings inside the Building Zone without overlaps."; cargo_notice_timer = 3;
			}
		}
		else if (!_cancel && instance_exists(o_cannon) && point_in_rectangle(_wx,_wy,o_cannon.bbox_left,o_cannon.bbox_top,o_cannon.bbox_right,o_cannon.bbox_bottom))
		{
			if (!cargo_load(cargo_dragged)) { _cancel = true; cargo_notice = "Not enough Cannon capacity."; cargo_notice_timer = 3; }
		}
		if(cargo_dragged.object_index==o_exploding_shell && !cargo_dragged.cannon_loaded)
		{
			var _warehouse=noone;
			with(o_warehouse)
			{
				if(point_in_rectangle(_wx,_wy,x-100,y-100,x+100,y+100)) _warehouse=id;
			}
			if(_cancel || !instance_exists(_warehouse) || !warehouse_store(cargo_dragged,_warehouse)) _cancel=true;
		}
		// Units can only be transferred into the Cannon; other drops restore the pickup position.
		if (object_is_ancestor(cargo_dragged.object_index, o_friendly_units) && !cargo_dragged.cannon_loaded) _cancel = true;
		if (_cancel) { cargo_dragged.x = cargo_drag_start_x; cargo_dragged.y = cargo_drag_start_y; }
		cargo_dragged.is_being_dragged = false;
		if (_building) cargo_dragged.worker_positions_update();
		cargo_dragged = noone;
	}
	return true;
}
