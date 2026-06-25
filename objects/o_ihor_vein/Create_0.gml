// Ihor Veins are passive resource nodes used by Ihor Extractors.
sprite_index = s_ihor_vein;
image_speed = 0;
image_xscale = 1.35;
image_yscale = 1.35;
y_sort_enabled = true;
assigned_ihor_extractor = noone;
ihor_capacity = BALANCE_IHOR_VEIN_CAPACITY;
ihor_remaining = ihor_capacity;

// Depletion bar visual settings.
bar_width = 54;
bar_height = 5;
bar_offset_y = 8;
bar_background_alpha = 0.75;

// Tooltip visual settings.
var _full_vein_speed_text = string(BALANCE_IHOR_EXTRACTOR_FULL_VEIN_SPEED);
var _empty_vein_speed_text = string(BALANCE_IHOR_EXTRACTOR_EMPTY_VEIN_SPEED);
tooltip_text = "Ihor Vein\nGives +" + _full_vein_speed_text + " extraction speed to a nearby Ihor Extractor.\nWhen depleted, it still gives +" + _empty_vein_speed_text + " speed.\nA Vein can feed only one Ihor Extractor.";
tooltip_width = 360;
tooltip_padding = 10;
tooltip_line_height = 18;
tooltip_offset_y = 72;

ihor_vein_has_ihor = function()
{
	return ihor_remaining > 0;
};

ihor_vein_consume = function(_amount)
{
	var _consumed_amount = min(max(_amount, 0), ihor_remaining);
	ihor_remaining = max(ihor_remaining - _consumed_amount, 0);

	if (ihor_remaining <= 0)
	{
		assigned_ihor_extractor = noone;
	}

	return _consumed_amount;
};

ihor_vein_is_hovered = function()
{
	if (!instance_exists(o_camera_controller)
		|| (variable_global_exists("tutorial_popup_active") && global.tutorial_popup_active)
		|| (variable_global_exists("focus_window") && global.focus_window != FOCUS_WINDOW.NOONE))
	{
		return false;
	}

	var _camera_controller = instance_find(o_camera_controller, 0);
	var _mouse_gui_x = device_mouse_x_to_gui(0);
	var _mouse_gui_y = device_mouse_y_to_gui(0);
	var _camera_x = camera_get_view_x(_camera_controller.camera_id);
	var _camera_y = camera_get_view_y(_camera_controller.camera_id);
	var _camera_width = camera_get_view_width(_camera_controller.camera_id);
	var _camera_height = camera_get_view_height(_camera_controller.camera_id);
	var _mouse_world_x = _camera_x + ((_mouse_gui_x / _camera_controller.base_view_width) * _camera_width);
	var _mouse_world_y = _camera_y + ((_mouse_gui_y / _camera_controller.base_view_height) * _camera_height);

	return _mouse_world_x >= bbox_left
		&& _mouse_world_x <= bbox_right
		&& _mouse_world_y >= bbox_top
		&& _mouse_world_y <= bbox_bottom;
};
