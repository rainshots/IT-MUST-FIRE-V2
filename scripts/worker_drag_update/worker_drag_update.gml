/// @description Handles civilian pickup and building drops independently from army controls; controller context.
function worker_drag_update()
{
	worker_hovered = noone;
	worker_drop_building = noone;
	worker_notice_timer = max(0, worker_notice_timer - 1 / max(1, room_speed));
	var _allowed = !global.pause && fight_state == FIGHT_STATE.ACTIVE
		&& global.focus_window == FOCUS_WINDOW.NOONE && !debug_menu_open && instance_exists(o_camera_controller);
	if (!_allowed)
	{
		if (instance_exists(worker_dragged))
		{
			worker_dragged.is_being_dragged = false;
			worker_dragged.x = worker_dragged.drag_drop_x;
			worker_dragged.y = worker_dragged.drag_drop_y;
		}
		worker_dragged = noone;
		if (worker_cursor_hidden) window_set_cursor(cr_default);
		worker_cursor_hidden = false;
		return;
	}
	var _camera = o_camera_controller.camera_id;
	var _gui_x = device_mouse_x_to_gui(0);
	var _gui_y = device_mouse_y_to_gui(0);
	var _scale_x = camera_get_view_width(_camera) / max(1, display_get_gui_width());
	var _scale_y = camera_get_view_height(_camera) / max(1, display_get_gui_height());
	var _world_x = camera_get_view_x(_camera) + _gui_x * _scale_x;
	var _world_y = camera_get_view_y(_camera) + _gui_y * _scale_y;
	// The purchase row owns its screen area even when a worker is underneath it.
	var _purchase_rect = faction_summon_rect_get(0);
	var _over_hud = _gui_y >= _purchase_rect.y;
	if (!instance_exists(worker_dragged) && !_over_hud)
	{
		var _count = instance_number(o_cultist);
		var _nearest_depth = infinity;
		for (var _index = 0; _index < _count; ++_index)
		{
			var _worker = instance_find(o_cultist, _index);
			if (_worker.hp > 0 && _worker.depth < _nearest_depth
				&& point_in_rectangle(_world_x, _world_y, _worker.bbox_left, _worker.bbox_top, _worker.bbox_right, _worker.bbox_bottom))
			{
				worker_hovered = _worker;
				_nearest_depth = _worker.depth;
			}
		}
		if (instance_exists(worker_hovered) && mouse_check_button_pressed(mb_left))
		{
			worker_dragged = worker_hovered;
			worker_release(worker_dragged);
			worker_dragged.drag_drop_x = worker_dragged.x;
			worker_dragged.drag_drop_y = worker_dragged.y;
			worker_dragged.is_being_dragged = true;
		}
	}
	if (instance_exists(worker_dragged))
	{
		var _foot_offset = worker_dragged.bbox_bottom - worker_dragged.y;
		worker_dragged.x = _world_x;
		worker_dragged.y = _world_y + BALANCE_PICKUP_HAND_DRAG_OFFSET_Y * _scale_y - _foot_offset;
		var _count = instance_number(o_worker_building_parent);
		var _nearest_distance = infinity;
		for (var _index = 0; !_over_hud && _index < _count; ++_index)
		{
			var _building = instance_find(o_worker_building_parent, _index);
			var _distance = point_distance(_world_x, _world_y, _building.x, _building.y);
			var _inside = _building.sprite_index == -1
				? _distance <= _building.worker_drop_radius
				: point_in_rectangle(_world_x, _world_y, _building.bbox_left, _building.bbox_top, _building.bbox_right, _building.bbox_bottom);
			if (_inside && _distance < _nearest_distance)
			{
				worker_drop_building = _building;
				_nearest_distance = _distance;
			}
		}
		if (mouse_check_button_pressed(mb_right) || !mouse_check_button(mb_left))
		{
			var _cancelled = mouse_check_button_pressed(mb_right);
			var _assigned = !_cancelled && instance_exists(worker_drop_building)
				&& worker_assign(worker_dragged, worker_drop_building);
			if (!_assigned)
			{
				worker_dragged.x = _cancelled ? worker_dragged.drag_drop_x : clamp(_world_x, 0, room_width);
				worker_dragged.y = _cancelled ? worker_dragged.drag_drop_y : clamp(_world_y, 0, room_height);
				if (!_cancelled && instance_exists(worker_drop_building))
				{
					worker_notice = "Building unavailable or full";
					worker_notice_timer = 2;
				}
			}
			worker_dragged.is_being_dragged = false;
			worker_dragged = noone;
		}
	}
	var _hide_cursor = instance_exists(worker_dragged) || instance_exists(worker_hovered);
	if (_hide_cursor != worker_cursor_hidden) window_set_cursor(_hide_cursor ? cr_none : cr_default);
	worker_cursor_hidden = _hide_cursor;
}
