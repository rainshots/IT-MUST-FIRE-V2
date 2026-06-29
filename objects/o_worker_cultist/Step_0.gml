// Pause freezes worker movement.
if (global.pause)
{
	exit;
}

// Destroy dead workers without running combat AI.
if (hp <= 0)
{
	unit_death_process();
	exit;
}

// Dragged workers wait for the controller to place them.
if (is_being_dragged)
{
	target_instance = noone;
	is_attacking_target = false;
	is_walking = false;
	visual_attack_offset_x = 0;
	visual_attack_offset_y = 0;
	update_walk_sway();
	exit;
}

// At night workers stop working and gather under the cannon.
if (global.day_phase == DAY_PHASE.NIGHT)
{
	target_instance = noone;
	is_attacking_target = false;
	is_walking = false;
	visual_attack_offset_x = 0;
	visual_attack_offset_y = 0;

	var _target_x = regroup_target_x;
	var _target_y = regroup_target_y;

	if (!regroup_is_active && instance_exists(o_cannon))
	{
		var _cannon = instance_find(o_cannon, 0);
		_target_x = _cannon.x;
		_target_y = _cannon.y + BALANCE_DAY_CANNON_REGROUP_OFFSET_Y;
	}

	var _regroup_distance = point_distance(x, y, _target_x, _target_y);

	if (_regroup_distance <= regroup_arrive_radius)
	{
		regroup_is_active = false;
		drag_drop_x = x;
		drag_drop_y = y;
	}
	else
	{
		move_towards_world_point(_target_x, _target_y);
	}

	apply_separation_push();
	update_walk_sway();
	exit;
}

// Assigned workers stay at their worker building.
if (is_assigned_to_building && instance_exists(assigned_building))
{
	target_instance = noone;
	is_attacking_target = false;
	is_walking = false;
	visual_attack_offset_x = 0;
	visual_attack_offset_y = 0;
	update_walk_sway();
	exit;
}
else if (is_assigned_to_building)
{
	assigned_building = noone;
	is_assigned_to_building = false;
}

// Temporary buffs and status labels still update while workers are alive.
status_effect_update();
soul_chain_update();

if (hp <= 0)
{
	unit_death_process();
	exit;
}

if (attack_feedback_timer > 0)
{
	attack_feedback_timer--;
}

if (soul_chain_death_flash_timer > 0)
{
	soul_chain_death_flash_timer--;
}

if (demonic_infusion_timer > 0)
{
	demonic_infusion_timer--;

	if (demonic_infusion_timer <= 0)
	{
		demonic_infusion_reload_multiplier = 1;
	}
}

target_instance = noone;
is_attacking_target = false;
is_walking = false;

// Unassigned workers wander in front of the cannon.
if (regroup_is_active)
{
	var _regroup_distance = point_distance(x, y, regroup_target_x, regroup_target_y);

	if (_regroup_distance <= regroup_arrive_radius)
	{
		regroup_is_active = false;
		drag_drop_x = x;
		drag_drop_y = y;
	}
	else
	{
		move_towards_world_point(regroup_target_x, regroup_target_y);
	}
}
else if (instance_exists(o_game_controller))
{
	var _game_controller = instance_find(o_game_controller, 0);

	if (variable_instance_exists(_game_controller, "worker_idle_wander_update"))
	{
		_game_controller.worker_idle_wander_update(id);
	}
}

apply_separation_push();
update_walk_sway();
