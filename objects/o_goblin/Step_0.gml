// Pause freezes goblin movement.
if (global.pause)
{
	exit;
}

// Destroy dead goblins without running combat AI.
if (hp <= 0)
{
	unit_death_process();
	exit;
}

// Dragged goblins wait for the controller to place them.
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

// Cannon corpse workers return inside the wall at night instead of freezing at the cannon.
if (is_assigned_to_building
	&& instance_exists(assigned_building)
	&& assigned_building.object_index == o_cannon
	&& global.day_phase == DAY_PHASE.NIGHT
	&& regroup_is_active)
{
	target_instance = noone;
	is_attacking_target = false;
	is_walking = false;
	visual_attack_offset_x = 0;
	visual_attack_offset_y = 0;

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

	apply_separation_push();
	update_walk_sway();
	exit;
}

// Assigned goblins stay at their worker building.
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

// Temporary buffs and stun labels still update while goblins are alive.
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

// Unassigned goblins drift back to the cannon inner area.
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
else if (instance_exists(o_cannon))
{
	var _cannon = instance_find(o_cannon, 0);
	var _distance_to_cannon = point_distance(x, y, _cannon.x, _cannon.y);

	if (_distance_to_cannon > cannon_guard_radius)
	{
		move_towards_world_point(_cannon.x, _cannon.y);
	}
}

apply_separation_push();
update_walk_sway();
