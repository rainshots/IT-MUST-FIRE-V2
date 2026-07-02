// Destroyed towers are inert landmarks without combat bars or ranges.
if (is_destroyed)
{
	draw_self();
	exit;
}

// Draw inherited map object visuals.
event_inherited();

// Draw holy tower Saint radius as an outline only.
draw_set_alpha(radius_alpha);
draw_set_color(COLOR_HOLY_TOWER_RADIUS);

for (var _radius_line_index = 0; _radius_line_index < radius_line_width; ++_radius_line_index)
{
	draw_circle(x, y, saint_radius + _radius_line_index, true);
}

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
