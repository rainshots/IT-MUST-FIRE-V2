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

// Draw unit sprite with combat offset and a small whip panic shake while boosted.
var _whip_shake_x = 0;

if (variable_instance_exists(id, "whip_timer") && whip_timer > 0)
{
	_whip_shake_x = sin(current_time * BALANCE_WORKER_WHIP_SHAKE_SPEED) * BALANCE_WORKER_WHIP_SHAKE_OFFSET;
}

if (sprite_exists(sprite_index))
{
	var _damage_flash_is_active = damage_flash_timer > 0;

	if (_damage_flash_is_active)
	{
		shader_set(sh_unit_damage_flash);
	}

	draw_sprite_ext(
		sprite_index,
		image_index,
		x + visual_attack_offset_x + _whip_shake_x,
		y + visual_attack_offset_y,
		image_xscale,
		image_yscale,
		image_angle,
		image_blend,
		image_alpha
	);

	if (_damage_flash_is_active)
	{
		shader_reset();
	}
}

// Friendly support effects draw animated motes and a label above the target.
var _support_label_y = y + visual_attack_offset_y - 44;

if (array_length(support_buff_effects) > 0)
{
	for (var _particle_index = 0; _particle_index < 3; ++_particle_index)
	{
		var _particle_angle = (current_time * 0.18) + (_particle_index * 120);
		draw_set_color(COLOR_SUPPORT_BUFF);
		draw_circle(x + lengthdir_x(13, _particle_angle), y - 16 + lengthdir_y(6, _particle_angle), 2, false);
	}

	draw_set_halign(fa_center);
	draw_set_valign(fa_bottom);
	draw_text(x, _support_label_y, "Buffed");
	_support_label_y -= 16;
}

if (array_length(support_heal_effects) > 0)
{
	for (var _particle_index = 0; _particle_index < 3; ++_particle_index)
	{
		var _particle_angle = (-current_time * 0.15) + (_particle_index * 120);
		draw_set_color(COLOR_SUPPORT_HEAL);
		draw_circle(x + lengthdir_x(11, _particle_angle), y - 18 + lengthdir_y(7, _particle_angle), 2, false);
	}

	draw_set_halign(fa_center);
	draw_set_valign(fa_bottom);
	draw_text(x, _support_label_y, "Heal");
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);

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

// Mark available day worker summons that are not assigned to any work.
if (object_index == o_goblin
	&& global.day_phase == DAY_PHASE.DAY
	&& hp > 0
	&& !is_assigned_to_building
	&& !is_being_dragged)
{
	if (variable_global_exists("ui_font") && font_exists(global.ui_font))
	{
		draw_set_font(global.ui_font);
	}

	var _idle_label_text = idle_work_label_text;

	var _idle_label_x = x;
	var _idle_label_y = bbox_top - idle_work_label_offset_y;
	var _idle_label_width = string_width(_idle_label_text) + (idle_work_label_padding_x * 2);
	var _idle_label_height = string_height(_idle_label_text) + (idle_work_label_padding_y * 2);
	var _idle_label_left = _idle_label_x - (_idle_label_width * 0.5);
	var _idle_label_top = _idle_label_y - (_idle_label_height * 0.5);

	draw_set_alpha(idle_work_label_background_alpha);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_roundrect(
		_idle_label_left,
		_idle_label_top,
		_idle_label_left + _idle_label_width,
		_idle_label_top + _idle_label_height,
		false
	);

	draw_set_alpha(1);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(COLOR_STATUS_NEGATIVE_RED);
	draw_text(_idle_label_x, _idle_label_y, _idle_label_text);
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

// Draw knockout recovery state instead of regular combat bars.
if (is_knocked_out)
{
	if (variable_global_exists("ui_font") && font_exists(global.ui_font))
	{
		draw_set_font(global.ui_font);
	}

	var _knockout_x = x;
	var _knockout_y = y - knockout_label_offset_y;
	var _knockout_width = string_width(knockout_label_text) + (knockout_label_padding_x * 2);
	var _knockout_height = string_height(knockout_label_text) + (knockout_label_padding_y * 2);
	var _knockout_left = _knockout_x - (_knockout_width * 0.5);
	var _knockout_top = _knockout_y - (_knockout_height * 0.5);
	var _knockout_progress = 1 - clamp(knockout_timer / max(1, knockout_duration), 0, 1);
	var _knockout_bar_x = _knockout_x - (knockout_bar_width * 0.5);
	var _knockout_bar_y = _knockout_top - knockout_bar_gap - knockout_bar_height;

	draw_set_alpha(knockout_label_background_alpha);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_rectangle(_knockout_bar_x, _knockout_bar_y, _knockout_bar_x + knockout_bar_width, _knockout_bar_y + knockout_bar_height, false);

	draw_set_alpha(1);
	draw_set_color(COLOR_HEALTH_BAR);
	draw_rectangle(_knockout_bar_x, _knockout_bar_y, _knockout_bar_x + (knockout_bar_width * _knockout_progress), _knockout_bar_y + knockout_bar_height, false);

	draw_set_alpha(knockout_label_background_alpha);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_roundrect(_knockout_left, _knockout_top, _knockout_left + _knockout_width, _knockout_top + _knockout_height, false);

	draw_set_alpha(1);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(COLOR_HUD_TEXT);
	draw_text(_knockout_x, _knockout_y, knockout_label_text);

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
	exit;
}

// Draw regular unit health bars; demon bars are drawn above the world from the controller.
var _hp_progress = clamp(hp / max_hp, 0, 1);
var _is_demon_bar_drawn_by_controller = is_demon_form_unit() && !health_bar_world_draw_forced;
var _is_day_garrison_unit = global.day_phase == DAY_PHASE.DAY
	&& variable_instance_exists(id, "settlement_garrison_unit")
	&& settlement_garrison_unit;
var _should_draw_health_bar = !_is_demon_bar_drawn_by_controller
	&& !(_is_day_garrison_unit && _hp_progress >= 1);

if (_should_draw_health_bar)
{
	var _health_bar_width = health_bar_width_get(bar_width, max_hp);
	var _bar_x = x - (_health_bar_width * 0.5);
	var _bar_y = y - bar_offset_y;
	var _health_bar_color = COLOR_HEALTH_BAR;

	if (unit_faction == UNIT_FACTION.ENEMY)
	{
		_health_bar_color = COLOR_STATUS_NEGATIVE_RED;
	}

	draw_set_alpha(0.75);
	draw_set_color(c_black);
	draw_rectangle(_bar_x, _bar_y, _bar_x + _health_bar_width, _bar_y + bar_height, false);

	draw_set_alpha(1);
	draw_set_color(_health_bar_color);
	draw_rectangle(_bar_x, _bar_y, _bar_x + (_health_bar_width * _hp_progress), _bar_y + bar_height, false);
	draw_set_color(c_black);
	health_bar_segments_draw(_bar_x, _bar_y, _health_bar_width, bar_height, max_hp);

	var _status_bar_gap = 2;

	if (variable_instance_exists(id, "stamina_bar_gap"))
	{
		_status_bar_gap = stamina_bar_gap;
	}

	var _next_status_bar_y = _bar_y + bar_height + _status_bar_gap;

	if (variable_instance_exists(id, "whip_timer") && whip_timer > 0 && whip_duration > 0)
	{
		var _whip_progress = clamp(whip_timer / whip_duration, 0, 1);
		var _whip_bar_height = 3;
		var _whip_bar_y = _next_status_bar_y;

		draw_set_alpha(0.75);
		draw_set_color(c_black);
		draw_rectangle(_bar_x, _whip_bar_y, _bar_x + _health_bar_width, _whip_bar_y + _whip_bar_height, false);

		draw_set_alpha(1);
		draw_set_color(COLOR_CULTIST_FERVOR);
		draw_rectangle(_bar_x, _whip_bar_y, _bar_x + (_health_bar_width * _whip_progress), _whip_bar_y + _whip_bar_height, false);
	}
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
