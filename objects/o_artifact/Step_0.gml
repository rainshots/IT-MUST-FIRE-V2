if (!instance_exists(o_camera_controller))
{
	exit;
}

var _camera_controller = instance_find(o_camera_controller, 0);
var _mouse_gui_x = device_mouse_x_to_gui(0);
var _mouse_gui_y = device_mouse_y_to_gui(0);
var _camera_x = camera_get_view_x(_camera_controller.camera_id);
var _camera_y = camera_get_view_y(_camera_controller.camera_id);
var _camera_width = camera_get_view_width(_camera_controller.camera_id);
var _camera_height = camera_get_view_height(_camera_controller.camera_id);
var _gui_width = max(1, display_get_gui_width());
var _gui_height = max(1, display_get_gui_height());
var _mouse_world_x = _camera_x + ((_mouse_gui_x / _gui_width) * _camera_width);
var _mouse_world_y = _camera_y + ((_mouse_gui_y / _gui_height) * _camera_height);
var _is_mouse_inside = _mouse_world_x >= bbox_left
	&& _mouse_world_x <= bbox_right
	&& _mouse_world_y >= bbox_top
	&& _mouse_world_y <= bbox_bottom;
var _distance_to_mouse = point_distance(_mouse_world_x, _mouse_world_y, x, y);

artifact_is_hovered = (_is_mouse_inside || _distance_to_mouse <= artifact_pickup_radius)
	&& global.focus_window == FOCUS_WINDOW.NOONE
	&& !instance_exists(global.dragged_cultist)
	&& (!variable_global_exists("dragged_artifact") || !instance_exists(global.dragged_artifact) || global.dragged_artifact == id);

if (artifact_is_dragged)
{
	x = _mouse_world_x + artifact_drag_offset_x;
	y = _mouse_world_y + artifact_drag_offset_y;
	artifact_target_cultist = artifact_cultist_find_at_position(_mouse_world_x, _mouse_world_y);

	if (!mouse_check_button(mb_left))
	{
		if (artifact_apply_to_archdemon(artifact_target_cultist))
		{
			if (variable_global_exists("dragged_artifact") && global.dragged_artifact == id)
			{
				global.dragged_artifact = noone;
			}

			exit;
		}

		artifact_is_dragged = false;
		artifact_target_cultist = noone;

		if (variable_global_exists("dragged_artifact") && global.dragged_artifact == id)
		{
			global.dragged_artifact = noone;
		}
	}

	exit;
}

if (global.focus_window != FOCUS_WINDOW.NOONE
	|| instance_exists(global.dragged_cultist)
	|| (variable_global_exists("dragged_artifact") && instance_exists(global.dragged_artifact)))
{
	exit;
}

if (mouse_check_button_pressed(mb_left)
	&& (_is_mouse_inside || _distance_to_mouse <= artifact_pickup_radius))
{
	artifact_is_dragged = true;
	artifact_drag_offset_x = x - _mouse_world_x;
	artifact_drag_offset_y = y - _mouse_world_y;

	if (variable_global_exists("dragged_artifact"))
	{
		global.dragged_artifact = id;
	}
}
