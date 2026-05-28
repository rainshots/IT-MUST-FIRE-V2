// Draw global resources in the top-left HUD.
if (!variable_global_exists("resources"))
{
	exit;
}

draw_set_halign(fa_left);
draw_set_valign(fa_middle);

var _resource_count = array_length(resource_order);

for (var _resource_index = 0; _resource_index < _resource_count; ++_resource_index)
{
	var _resource = resource_order[_resource_index];
	var _draw_x = hud_margin_x + ((resource_item_width + resource_item_gap) * _resource_index);
	var _draw_y = hud_margin_y;
	var _value = global.resources[_resource];
	var _icon_x = _draw_x + resource_text_padding;
	var _icon_y = _draw_y + (resource_item_height * 0.5);
	var _icon_sprite = resource_icon_sprites[_resource];
	var _text_x = _icon_x + (resource_icon_size * 0.5) + resource_icon_text_gap;
	var _text_y = _icon_y;

	// Draw resource panel background.
	draw_set_alpha(0.72);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_rectangle(_draw_x, _draw_y, _draw_x + resource_item_width, _draw_y + resource_item_height, false);

	// Draw resource icon, falling back to a color dot if the sprite is unavailable.
	draw_set_alpha(1);
	if (sprite_exists(_icon_sprite))
	{
		var _icon_left = _icon_x - (resource_icon_size * 0.5);
		var _icon_top = _icon_y - (resource_icon_size * 0.5);

		draw_sprite_stretched_ext(_icon_sprite, 0, _icon_left, _icon_top, resource_icon_size, resource_icon_size, c_white, 1);
	}
	else
	{
		draw_set_color(resource_colors[_resource]);
		draw_circle(_icon_x, _icon_y, resource_icon_radius, false);
	}

	draw_set_color(COLOR_HUD_TEXT);
	draw_text(_text_x, _text_y, string(_value));
}

// Draw derived ground corruption after regular resources.
var _corruption_index = _resource_count;
var _corruption_x = hud_margin_x + ((resource_item_width + resource_item_gap) * _corruption_index);
var _corruption_y = hud_margin_y;
var _corruption_value = string_format(corruption_display_value, 0, corruption_display_decimals);
var _corruption_label = corruption_display_name + ": " + _corruption_value;
var _corruption_icon_x = _corruption_x + resource_text_padding;
var _corruption_icon_y = _corruption_y + (resource_item_height * 0.5);
var _corruption_text_x = _corruption_x + (resource_text_padding * 1.8);
var _corruption_text_y = _corruption_icon_y;

draw_set_alpha(0.72);
draw_set_color(COLOR_HUD_BACKGROUND);
draw_rectangle(_corruption_x, _corruption_y, _corruption_x + resource_item_width, _corruption_y + resource_item_height, false);

draw_set_alpha(1);
draw_set_color(corruption_display_color);
draw_circle(_corruption_icon_x, _corruption_icon_y, resource_icon_radius, false);

draw_set_color(COLOR_HUD_TEXT);
draw_text(_corruption_text_x, _corruption_text_y, _corruption_label);

// Draw day phase in the top-right HUD.
if (variable_global_exists("day_phase"))
{
	var _gui_width = display_get_gui_width();
	var _phase_x = _gui_width - day_phase_margin_right - day_phase_item_width;
	var _phase_y = hud_margin_y;
	var _phase_text = "DAY: " + string(ceil(global.day_timer / room_speed));

	if (variable_global_exists("day_cycle_enabled") && !global.day_cycle_enabled)
	{
		_phase_text = "DAY";
	}
	else if (global.day_phase == DAY_PHASE.NIGHT)
	{
		_phase_text = "NIGHT: " + string(global.night_attack_unit_count);
	}

	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);
	draw_set_alpha(0.72);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_rectangle(_phase_x, _phase_y, _phase_x + day_phase_item_width, _phase_y + day_phase_item_height, false);

	draw_set_alpha(1);
	draw_set_color(COLOR_HUD_TEXT);
	draw_text(_phase_x + day_phase_text_padding, _phase_y + (day_phase_item_height * 0.5), _phase_text);
}

// Draw queued cannon projectiles in the bottom-left HUD.
if (variable_global_exists("cannon_projectile_queue"))
{
	var _projectile_queue_count = array_length(global.cannon_projectile_queue);
	var _projectile_mouse_x = device_mouse_x_to_gui(0);
	var _projectile_mouse_y = device_mouse_y_to_gui(0);
	var _gui_height = display_get_gui_height();
	var _projectile_base_y = _gui_height - projectile_queue_margin_bottom - projectile_slot_height;
	var _hovered_projectile_index = -1;

	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);

	for (var _projectile_index = 0; _projectile_index < _projectile_queue_count; ++_projectile_index)
	{
		var _projectile_type = global.cannon_projectile_queue[_projectile_index];
		var _slot_x = projectile_queue_margin_x + ((projectile_slot_width + projectile_slot_gap) * _projectile_index);
		var _slot_y = _projectile_base_y;
		var _slot_width = projectile_slot_width;
		var _slot_height = projectile_slot_background_height;
		var _is_current_projectile = _projectile_index == 0;
		var _projectile_color = COLOR_PROJECTILE_DAMAGE;
		var _circle_radius = projectile_circle_radius;

		if (_projectile_type == PROJECTILE_TYPE.CORRUPTION)
		{
			_projectile_color = COLOR_PROJECTILE_CORRUPTION;
		}
		else if (_projectile_type == PROJECTILE_TYPE.SUMMON)
		{
			_projectile_color = COLOR_PROJECTILE_SUMMON;
		}
		else if (_projectile_type == PROJECTILE_TYPE.RALLY)
		{
			_projectile_color = COLOR_PROJECTILE_RALLY;
		}

		if (_is_current_projectile)
		{
			_slot_x -= projectile_current_scale_padding;
			_slot_y -= projectile_current_scale_padding;
			_slot_width += projectile_current_scale_padding * 2;
			_slot_height += projectile_current_scale_padding * 2;
			_circle_radius = projectile_current_circle_radius;
		}

		if (_projectile_mouse_x >= _slot_x && _projectile_mouse_x <= _slot_x + _slot_width
			&& _projectile_mouse_y >= _slot_y && _projectile_mouse_y <= _slot_y + _slot_height)
		{
			_hovered_projectile_index = _projectile_index;
		}

		draw_set_alpha(0.76);
		draw_set_color(COLOR_HUD_BACKGROUND);
		draw_rectangle(_slot_x, _slot_y, _slot_x + _slot_width, _slot_y + _slot_height, false);

		if (_is_current_projectile)
		{
			draw_set_alpha(1);
			draw_set_color(COLOR_HUD_PROJECTILE_SELECTED);
			draw_rectangle(_slot_x, _slot_y, _slot_x + _slot_width, _slot_y + _slot_height, true);
		}

		draw_set_alpha(1);
		draw_set_color(_projectile_color);
		draw_circle(_slot_x + (_slot_width * 0.5), _slot_y + 22, _circle_radius, false);

		draw_set_color(COLOR_HUD_TEXT);
		draw_text(_slot_x + (_slot_width * 0.5), _slot_y + projectile_name_offset_y, projectile_names[_projectile_type]);
	}

	var _description_projectile_index = _hovered_projectile_index;

	if (_description_projectile_index < 0 && _projectile_queue_count > 0)
	{
		_description_projectile_index = 0;
	}

	if (_description_projectile_index >= 0)
	{
		var _description_type = global.cannon_projectile_queue[_description_projectile_index];
		var _description_x = projectile_queue_margin_x;
		var _description_y = _projectile_base_y - projectile_description_height - projectile_description_gap;

		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_alpha(0.84);
		draw_set_color(COLOR_HUD_BACKGROUND);
		draw_rectangle(
			_description_x,
			_description_y,
			_description_x + projectile_description_width,
			_description_y + projectile_description_height,
			false
		);

		draw_set_alpha(1);
		draw_set_color(COLOR_HUD_TEXT);
		draw_text(_description_x + 10, _description_y + 8, projectile_names[_description_type]);

		draw_set_color(COLOR_HUD_PROJECTILE_DESCRIPTION);
		draw_text_ext(
			_description_x + 10,
			_description_y + 28,
			projectile_descriptions[_description_type],
			projectile_description_line_separation,
			projectile_description_width - 20
		);
	}
}

// Restore default draw state.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
