// Draw inherited map object visuals.
event_inherited();

// Draw holy tower shooting radius.
draw_set_alpha(radius_alpha);
draw_set_color(COLOR_HOLY_TOWER_RADIUS);
draw_circle(x, y, shoot_radius, true);

draw_set_alpha(radius_alpha * 0.45);
draw_circle(x, y, shoot_radius, false);

// Draw short attack feedback line.
if (attack_feedback_timer > 0)
{
	var _feedback_progress = clamp(attack_feedback_timer / attack_feedback_time, 0, 1);
	var _target_x = attack_feedback_target_x;
	var _target_y = attack_feedback_target_y;

	if (instance_exists(attack_feedback_target))
	{
		_target_x = attack_feedback_target.x;
		_target_y = attack_feedback_target.y;
	}

	draw_set_alpha(_feedback_progress);
	draw_set_color(COLOR_HOLY_TOWER_RADIUS);
	draw_line_width(x, y, _target_x, _target_y, attack_feedback_line_width);
}

// Restore default draw state.
draw_set_color(c_white);
draw_set_alpha(1);
