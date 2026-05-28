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

// Draw unit health bar.
var _bar_x = x - (bar_width * 0.5);
var _bar_y = y - bar_offset_y;
var _hp_progress = clamp(hp / max_hp, 0, 1);

draw_set_alpha(0.75);
draw_set_color(c_black);
draw_rectangle(_bar_x, _bar_y, _bar_x + bar_width, _bar_y + bar_height, false);

draw_set_alpha(1);
draw_set_color(COLOR_HEALTH_BAR);
draw_rectangle(_bar_x, _bar_y, _bar_x + (bar_width * _hp_progress), _bar_y + bar_height, false);

// Restore default draw state.
draw_set_color(c_white);
draw_set_alpha(1);
