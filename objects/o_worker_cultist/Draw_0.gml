// Draw shared unit visuals first.
event_inherited();

// Draw a resource warning when the assigned building cannot spend its resource.
if (is_assigned_to_building
	&& instance_exists(assigned_building)
	&& variable_instance_exists(assigned_building, "missing_work_resource")
	&& assigned_building.missing_work_resource != noone)
{
	if (variable_global_exists("ui_font") && font_exists(global.ui_font))
	{
		draw_set_font(global.ui_font);
	}

	var _resource_warning_text = "Not enough " + assigned_building.missing_work_resource_name;
	var _resource_warning_x = x;
	var _resource_warning_y = bbox_top - resource_warning_offset_y;
	var _resource_warning_width = string_width(_resource_warning_text) + (resource_warning_padding_x * 2);
	var _resource_warning_height = string_height(_resource_warning_text) + (resource_warning_padding_y * 2);
	var _resource_warning_left = _resource_warning_x - (_resource_warning_width * 0.5);
	var _resource_warning_top = _resource_warning_y - (_resource_warning_height * 0.5);

	draw_set_alpha(resource_warning_background_alpha);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_roundrect(
		_resource_warning_left,
		_resource_warning_top,
		_resource_warning_left + _resource_warning_width,
		_resource_warning_top + _resource_warning_height,
		false
	);

	draw_set_alpha(1);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(assigned_building.missing_work_resource_color);
	draw_text(_resource_warning_x, _resource_warning_y, _resource_warning_text);
}

// Restore default draw state.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
