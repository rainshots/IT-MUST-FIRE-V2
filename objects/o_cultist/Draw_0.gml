// Draw the landing shadow while the player is carrying this cultist.
if (is_being_dragged)
{
	draw_set_alpha(0.35);
	draw_set_color(c_black);
	draw_ellipse(
		drag_drop_x - (global.cultist_drag_shadow_width * 0.5),
		drag_drop_y - (global.cultist_drag_shadow_height * 0.5),
		drag_drop_x + (global.cultist_drag_shadow_width * 0.5),
		drag_drop_y + (global.cultist_drag_shadow_height * 0.5),
		false
	);
	draw_set_alpha(1);
	draw_set_color(c_white);
}

// Draw day cultist sprite.
draw_self();

// Draw carried corpses above the cultist hauling them to the cannon.
if (variable_instance_exists(id, "carried_corpses") && array_length(carried_corpses) > 0)
{
	var _carried_count = array_length(carried_corpses);

	for (var _corpse_index = 0; _corpse_index < _carried_count; ++_corpse_index)
	{
		var _carried_corpse = carried_corpses[_corpse_index];

		if (sprite_exists(_carried_corpse.sprite_index))
		{
			var _corpse_draw_x = x + ((_corpse_index - ((_carried_count - 1) * 0.5)) * 18);
			var _corpse_draw_y = y - BALANCE_CANNON_CORPSE_CARRY_OFFSET_Y - (_corpse_index * 16);

			draw_sprite_ext(
				_carried_corpse.sprite_index,
				_carried_corpse.image_index,
				_corpse_draw_x,
				_corpse_draw_y,
				_carried_corpse.image_xscale,
				_carried_corpse.image_yscale,
				_carried_corpse.image_angle,
				_carried_corpse.image_blend,
				_carried_corpse.image_alpha
			);
		}
	}
}
else if (variable_instance_exists(id, "carried_corpse") && is_struct(carried_corpse))
{
	var _carried_corpse = carried_corpse;

	if (sprite_exists(_carried_corpse.sprite_index))
	{
		draw_sprite_ext(
			_carried_corpse.sprite_index,
			_carried_corpse.image_index,
			x,
			y - BALANCE_CANNON_CORPSE_CARRY_OFFSET_Y,
			_carried_corpse.image_xscale,
			_carried_corpse.image_yscale,
			_carried_corpse.image_angle,
			_carried_corpse.image_blend,
			_carried_corpse.image_alpha
		);
	}
}

if (variable_global_exists("ui_font") && font_exists(global.ui_font))
{
	draw_set_font(global.ui_font);
}

// Draw a warning when a cannon worker has no free corpse to haul.
if (variable_instance_exists(id, "cannon_no_corpse_warning_active") && cannon_no_corpse_warning_active)
{
	var _corpse_warning_text = cannon_no_corpse_warning_text;
	var _corpse_warning_x = x;
	var _corpse_warning_y = bbox_top - cannon_no_corpse_warning_offset_y;
	var _corpse_warning_width = string_width(_corpse_warning_text) + (cannon_no_corpse_warning_padding_x * 2);
	var _corpse_warning_height = string_height(_corpse_warning_text) + (cannon_no_corpse_warning_padding_y * 2);
	var _corpse_warning_left = _corpse_warning_x - (_corpse_warning_width * 0.5);
	var _corpse_warning_top = _corpse_warning_y - (_corpse_warning_height * 0.5);

	draw_set_alpha(cannon_no_corpse_warning_background_alpha);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_roundrect(
		_corpse_warning_left,
		_corpse_warning_top,
		_corpse_warning_left + _corpse_warning_width,
		_corpse_warning_top + _corpse_warning_height,
		false
	);

	draw_set_alpha(1);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(COLOR_STATUS_NEGATIVE_RED);
	draw_text(_corpse_warning_x, _corpse_warning_y, _corpse_warning_text);
}

// Draw a resource warning when the assigned building cannot spend its resource.
if (is_assigned_to_building
	&& instance_exists(assigned_building)
	&& variable_instance_exists(assigned_building, "missing_work_resource")
	&& assigned_building.missing_work_resource != noone)
{
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

// Draw the assigned name or an unnamed placeholder below the cultist.
var _name_text = cultist_name;

if (_name_text == "")
{
	_name_text = "Unnamed";
}

// Color the name by the cultist's strongest attribute.
var _name_color = COLOR_CULTIST_BODY;
var _body_points = cultist_points[CULTIST_STAT.BODY];
var _spirit_points = cultist_points[CULTIST_STAT.SPIRIT];
var _fervor_points = cultist_points[CULTIST_STAT.FERVOR];

if (_spirit_points > _body_points && _spirit_points >= _fervor_points)
{
	_name_color = COLOR_CULTIST_SPIRIT;
}
else if (_fervor_points > _body_points && _fervor_points > _spirit_points)
{
	_name_color = COLOR_CULTIST_FERVOR;
}

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(_name_color);
draw_text(x, y + name_offset_y, _name_text);

// Draw the same health bar style used by demon forms under the day-form name.
if (max_hp > 0)
{
	var _bar_x = x - (bar_width * 0.5);
	var _bar_y = y + name_offset_y + name_health_bar_gap;
	var _hp_progress = clamp(hp / max_hp, 0, 1);

	draw_set_alpha(0.75);
	draw_set_color(c_black);
	draw_rectangle(_bar_x, _bar_y, _bar_x + bar_width, _bar_y + bar_height, false);

	draw_set_alpha(1);
	draw_set_color(COLOR_HEALTH_BAR);
	draw_rectangle(_bar_x, _bar_y, _bar_x + (bar_width * _hp_progress), _bar_y + bar_height, false);
}

// Restore default draw state.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
