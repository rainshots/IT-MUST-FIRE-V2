// Destroyed towers are inert landmarks without combat bars or ranges.
if (is_destroyed)
{
	draw_self();
	exit;
}

// Draw inherited map object visuals.
event_inherited();

// Show deployment barriers while aiming a squad shell or hovering this tower.
var _aiming_squad_shell = false;
if (global.focus_window == FOCUS_WINDOW.TARGET_SELECTION && instance_exists(o_game_controller))
{
	var _controller = instance_find(o_game_controller, 0);
	_aiming_squad_shell = _controller.target_selection_projectile_type == PROJECTILE_TYPE.CULTIST;
}

if (deployment_block_radius > 0 && (_aiming_squad_shell || map_object_is_hovered()))
{
	draw_set_alpha(radius_alpha);
	draw_set_color(COLOR_HOLY_TOWER_RADIUS);

	for (var _radius_line_index = 0; _radius_line_index < radius_line_width; ++_radius_line_index)
	{
		draw_circle(x, y, deployment_block_radius + _radius_line_index, true);
	}
	draw_set_alpha(1);
	draw_set_color(c_white);
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
	var _attack_origin_y = y - sprite_get_height(sprite_index) + attack_origin_top_offset;
	draw_line_width(x, _attack_origin_y, _target_x, _target_y, attack_feedback_line_width);
}

// Restore default draw state.
draw_set_color(c_white);
draw_set_alpha(1);
