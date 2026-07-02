// Ihor Veins are passive resource nodes used by Ihor Extractors.
sprite_index = s_ihor_vein;
image_speed = 0;
image_xscale = 1.35;
image_yscale = 1.35;
y_sort_enabled = true;
assigned_ihor_extractor = noone;
ihor_capacity = BALANCE_IHOR_VEIN_CAPACITY;
ihor_remaining = ihor_capacity;
ihor_taint_destroy_reward = 5; // Ihor gained when a Taint projectile destroys this vein.
ihor_destroyed_by_taint = false; // Prevents duplicate rewards before instance destruction finishes.
ihor_destroy_smoke_count = 50;
ihor_destroy_smoke_radius = 30;

// Depletion bar visual settings.
bar_width = 54;
bar_height = 5;
bar_offset_y = 8;
bar_background_alpha = 0.75;

// Tooltip visual settings.
tooltip_text = "Taint destroys this Ihor Vein and gives +" + string(ihor_taint_destroy_reward) + " Ihor.";
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

on_projectile_hit = function(_projectile_type)
{
	// Taint projectiles consume Ihor Veins for an immediate Ihor reward.
	if ((_projectile_type != PROJECTILE_TYPE.FEAST && _projectile_type != PROJECTILE_TYPE.CORRUPTION)
		|| ihor_destroyed_by_taint)
	{
		return;
	}

	ihor_destroyed_by_taint = true;

	if (variable_global_exists("resources"))
	{
		global.resources[RESOURCES.IHOR] += ihor_taint_destroy_reward;
		resource_popup_create(x, y - tooltip_offset_y, RESOURCES.IHOR, ihor_taint_destroy_reward);
	}

	// Cover the consumed vein with a dense smoke burst.
	for (var _smoke_index = 0; _smoke_index < ihor_destroy_smoke_count; ++_smoke_index)
	{
		var _smoke_direction = random(360);
		var _smoke_distance = sqrt(random(1)) * ihor_destroy_smoke_radius;
		var _smoke_x = x + lengthdir_x(_smoke_distance, _smoke_direction);
		var _smoke_y = y + lengthdir_y(_smoke_distance, _smoke_direction);

		instance_create_layer(_smoke_x, _smoke_y, "Instances", o_particle_smoke);
	}

	assigned_ihor_extractor = noone;
	instance_destroy();
};
