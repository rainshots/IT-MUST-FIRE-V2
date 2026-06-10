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

// Draw unit sprite with combat-only visual offset.
draw_sprite_ext(
	sprite_index,
	image_index,
	x + visual_attack_offset_x,
	y + visual_attack_offset_y,
	image_xscale,
	image_yscale,
	image_angle,
	image_blend,
	image_alpha
);

// Corpse Armor is shown as a white defense particle over the protected unit.
if (corpse_armor_timer > 0 && sprite_exists(s_defense_particle))
{
	var _corpse_armor_pulse = 0.5 + (sin(current_time * 0.012) * 0.5);
	var _corpse_armor_alpha = 0.72 + (_corpse_armor_pulse * 0.2);
	var _corpse_armor_scale = 6.4 + (_corpse_armor_pulse * 1.2);

	draw_sprite_ext(
		s_defense_particle,
		0,
		x + visual_attack_offset_x,
		y + visual_attack_offset_y - 22,
		_corpse_armor_scale,
		_corpse_armor_scale,
		0,
		c_white,
		_corpse_armor_alpha
	);
}

// Draw carried corpses above the worker carrying them.
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

// Draw a warning when a cannon worker has no free corpse to haul.
if (variable_instance_exists(id, "cannon_no_corpse_warning_active") && cannon_no_corpse_warning_active)
{
	if (variable_global_exists("ui_font") && font_exists(global.ui_font))
	{
		draw_set_font(global.ui_font);
	}

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

// Draw short attack feedback line.
if (attack_feedback_timer > 0)
{
	var _feedback_progress = clamp(attack_feedback_timer / attack_feedback_time, 0, 1);
	var _feedback_alpha = _feedback_progress;
	var _feedback_color = COLOR_PROJECTILE_DAMAGE;
	var _target_x = attack_feedback_target_x;
	var _target_y = attack_feedback_target_y;

	if (unit_faction == UNIT_FACTION.FRIENDLY)
	{
		_feedback_color = COLOR_PROJECTILE_SUMMON;
	}

	if (instance_exists(attack_feedback_target))
	{
		_target_x = attack_feedback_target.x;
		_target_y = attack_feedback_target.y;
	}

	draw_set_alpha(_feedback_alpha);
	draw_set_color(_feedback_color);
	draw_line_width(x, y, _target_x, _target_y, attack_feedback_line_width);
}

draw_set_alpha(1);
draw_set_color(c_white);

// Draw regular unit health bars; demon bars are drawn above the world from the controller.
var _hp_progress = clamp(hp / max_hp, 0, 1);
var _is_demon_bar_drawn_by_controller = is_demon_form_unit();
var _should_draw_health_bar = !_is_demon_bar_drawn_by_controller
	&& !(unit_faction == UNIT_FACTION.ENEMY && _hp_progress >= 1);

if (_should_draw_health_bar)
{
	var _bar_x = x - (bar_width * 0.5);
	var _bar_y = y - bar_offset_y;
	var _health_bar_color = COLOR_HEALTH_BAR;

	if (unit_faction == UNIT_FACTION.ENEMY)
	{
		_health_bar_color = COLOR_STATUS_NEGATIVE_RED;
	}

	draw_set_alpha(0.75);
	draw_set_color(c_black);
	draw_rectangle(_bar_x, _bar_y, _bar_x + bar_width, _bar_y + bar_height, false);

	draw_set_alpha(1);
	draw_set_color(_health_bar_color);
	draw_rectangle(_bar_x, _bar_y, _bar_x + (bar_width * _hp_progress), _bar_y + bar_height, false);
}

// Draw stun state above the unit while it cannot act.
if (is_stunned || stun_timer > 0)
{
	if (variable_global_exists("ui_font") && font_exists(global.ui_font))
	{
		draw_set_font(global.ui_font);
	}

	var _stun_text = "STUNNED";
	var _stun_x = x;
	var _stun_y = y - stun_label_offset_y;
	var _stun_width = string_width(_stun_text) + (stun_label_padding_x * 2);
	var _stun_height = string_height(_stun_text) + (stun_label_padding_y * 2);
	var _stun_left = _stun_x - (_stun_width * 0.5);
	var _stun_top = _stun_y - (_stun_height * 0.5);
	var _stun_bar_progress = 0;
	var _stun_bar_x = _stun_x - (stun_bar_width * 0.5);
	var _stun_bar_y = _stun_top - stun_bar_gap - stun_bar_height;

	if (stun_duration > 0)
	{
		_stun_bar_progress = clamp(stun_timer / stun_duration, 0, 1);
	}

	draw_set_alpha(stun_label_background_alpha);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_rectangle(_stun_bar_x, _stun_bar_y, _stun_bar_x + stun_bar_width, _stun_bar_y + stun_bar_height, false);

	draw_set_alpha(1);
	draw_set_color(COLOR_ABILITY_POPUP);
	draw_rectangle(_stun_bar_x, _stun_bar_y, _stun_bar_x + (stun_bar_width * _stun_bar_progress), _stun_bar_y + stun_bar_height, false);

	draw_set_alpha(stun_label_background_alpha);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_roundrect(_stun_left, _stun_top, _stun_left + _stun_width, _stun_top + _stun_height, false);

	draw_set_alpha(1);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(COLOR_ABILITY_POPUP);
	draw_text(_stun_x, _stun_y, _stun_text);
}

// Restore default draw state.
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
