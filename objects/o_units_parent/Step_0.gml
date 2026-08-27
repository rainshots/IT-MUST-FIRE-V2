// Directly spawned friendly units receive persistent Foundry bonuses after child Create events.
if (foundry_permanent_bonuses_pending)
{
	foundry_unit_permanent_bonuses_apply(id);
	foundry_permanent_bonuses_pending = false;
}

// The balance controller owns every simulation tick so x1 and accelerated runs stay identical.
if (variable_global_exists("balance_test_active")
	&& global.balance_test_active
	&& (!variable_global_exists("balance_test_manual_tick_active")
		|| !global.balance_test_manual_tick_active))
{
	exit;
}

if (balance_test_simulation_finished)
{
	is_walking = false;
	is_attacking_target = false;
	exit;
}

// The squad selected by Hell Takes the Weakest remains undeployed for this night.
if (global.day_phase == DAY_PHASE.NIGHT
	&& global.ritual_hell_weakest_active
	&& variable_instance_exists(id, "squad")
	&& is_struct(squad)
	&& squad == global.ritual_hell_weakest_squad)
{
	is_walking = false;
	is_attacking_target = false;
	visible = false;
	exit;
}

// Pause freezes unit AI and combat.
if (global.pause)
{
	exit;
}

// Gameplay time can slow independently from rendering, input, and camera movement.
gameplay_time_scale = variable_global_exists("gameplay_time_scale")
	? global.gameplay_time_scale
	: 1;
image_speed = gameplay_time_scale;

if (navigation_retry_timer > 0)
{
	navigation_retry_timer = max(0, navigation_retry_timer - gameplay_time_scale);
}

if (damage_flash_timer > 0)
{
	damage_flash_timer -= gameplay_time_scale;
}

// Visual attack offset returns even while the unit has no target this frame.
update_attack_lunge();
is_stunned = false;

// Knocked out cultists stay on the battlefield until they recover.
if (is_knocked_out)
{
	if (knockout_update())
	{
		exit;
	}
}

// Destroy dead units.
if (hp <= 0)
{
	unit_death_process();
	exit;
}

// Units reserved for cultist projectiles wait hidden until the impact deploys them.
if (cultist_projectile_deploy_assigned || cultist_projectile_deploy_waiting)
{
	target_instance = noone;
	alert_target = noone;
	is_attacking_target = false;
	is_walking = false;
	visual_attack_offset_x = 0;
	visual_attack_offset_y = 0;
	update_walk_sway();
	exit;
}

// Periodic recovery catches invalid positions caused by legacy teleports or external effects.
navigation_recovery_update();

// Night-spawned tower reinforcements wait through the day and attack next night.
if (global.day_phase == DAY_PHASE.DAY
	&& holy_tower_reinforcement_waits_for_night
	&& !forced_retreat_active)
{
	target_instance = noone;
	alert_target = noone;
	forced_attack_target = noone;
	forced_attack_target_timer = 0;
	is_attacking_target = false;
	is_walking = false;
	visual_attack_offset_x = 0;
	visual_attack_offset_y = 0;
	update_walk_sway();
	exit;
}

// House guards return to their home during the day instead of chasing player structures.
if (global.day_phase == DAY_PHASE.DAY
	&& variable_instance_exists(id, "owner_house")
	&& instance_exists(owner_house))
{
	var _house_guard_return_distance = point_distance(x, y, owner_house.x, owner_house.y);
	var _house_guard_wait_radius = max(8, guard_radius * 0.5);

	target_instance = noone;
	alert_target = noone;
	is_attacking_target = false;
	visual_attack_offset_x = 0;
	visual_attack_offset_y = 0;

	if (_house_guard_return_distance <= _house_guard_wait_radius)
	{
		is_walking = false;
		update_walk_sway();
	}
	else
	{
		move_towards_world_point(owner_house.x, owner_house.y);
	}

	exit;
}

// Settlement garrison units move to their daytime rally point before waiting.
if (global.day_phase == DAY_PHASE.DAY
	&& variable_instance_exists(id, "settlement_garrison_unit")
	&& settlement_garrison_unit
	&& regroup_is_active)
{
	var _garrison_regroup_distance = point_distance(x, y, regroup_target_x, regroup_target_y);

	target_instance = noone;
	alert_target = noone;
	is_attacking_target = false;
	visual_attack_offset_x = 0;
	visual_attack_offset_y = 0;

	if (_garrison_regroup_distance <= regroup_arrive_radius)
	{
		regroup_is_active = false;
		drag_drop_x = x;
		drag_drop_y = y;
		is_walking = false;
		update_walk_sway();
	}
	else
	{
		move_towards_world_point(regroup_target_x, regroup_target_y);
	}

	exit;
}

// Settlement garrison units wait inside the settlement during the day.
if (global.day_phase == DAY_PHASE.DAY
	&& variable_instance_exists(id, "settlement_garrison_unit")
	&& settlement_garrison_unit)
{
	target_instance = noone;
	alert_target = noone;
	is_attacking_target = false;
	is_walking = false;
	visual_attack_offset_x = 0;
	visual_attack_offset_y = 0;
	update_walk_sway();
	exit;
}

// Dragged units cannot move, attack, or progress abilities until released.
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

// Assigned friendly workers stay at buildings instead of running combat AI.
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

// Status effects can damage, slow, mark, curse, or stun this unit.
status_effect_update();
support_effects_update();
soul_chain_update();

if (hp <= 0)
{
	unit_death_process();
	exit;
}

// Holy ground slowly restores enemy units standing on it.
enemy_saint_ground_heal_update();

// The day-three upgrade slowly restores player units standing on Taint.
friendly_tainted_ground_heal_update();

// Stunned units stay vulnerable but cannot move, attack, or progress timers.
if (is_stunned)
{
	target_instance = noone;
	is_attacking_target = false;
	is_walking = false;
	visual_attack_offset_x = 0;
	visual_attack_offset_y = 0;
	update_walk_sway();
	exit;
}

// Update short attack feedback lifetime.
if (attack_feedback_timer > 0)
{
	attack_feedback_timer -= gameplay_time_scale;
}

// Soul Chain death effects leave a short visual pulse.
if (soul_chain_death_flash_timer > 0)
{
	soul_chain_death_flash_timer -= gameplay_time_scale;
}

// Update temporary armor debuffs.
if (armor_debuff_timer > 0)
{
	armor_debuff_timer -= gameplay_time_scale;

	if (armor_debuff_timer <= 0)
	{
		armor_debuff_multiplier = 1;
	}
}

// Panic cooldown prevents the same unit from chain-fleeing every hit.
if (panic_flee_cooldown_timer > 0)
{
	panic_flee_cooldown_timer -= gameplay_time_scale;
}

// Demonic Infusion is refreshed by nearby Warlocks.
if (demonic_infusion_timer > 0)
{
	demonic_infusion_timer -= gameplay_time_scale;

	if (demonic_infusion_timer <= 0)
	{
		demonic_infusion_reload_multiplier = 1;
	}
}

// Corpse Armor adds temporary armor and cleans up the bonus when it expires.
if (corpse_armor_timer > 0)
{
	corpse_armor_timer -= gameplay_time_scale;

	if (corpse_armor_timer <= 0)
	{
		armor -= corpse_armor_bonus;
		corpse_armor_bonus = 0;
		corpse_armor_retaliation_damage = 0;
	}
}

// Forget shared threat after a short time.
if (alert_target_timer > 0)
{
	alert_target_timer -= gameplay_time_scale;

	if (!instance_exists(alert_target))
	{
		alert_target = noone;
		alert_target_timer = 0;
	}
}
else
{
	alert_target = noone;
}

// Forced targets are used by taunts and pulls.
if (forced_attack_target_timer > 0)
{
	forced_attack_target_timer -= gameplay_time_scale;

	if (!target_can_be_attacked(forced_attack_target))
	{
		forced_attack_target = noone;
		forced_attack_target_timer = 0;
	}
}
else
{
	forced_attack_target = noone;
}

// Marching squad members run to their flag and ignore every combat target.
var _squad_march_is_active = unit_faction == UNIT_FACTION.FRIENDLY
	&& global.day_phase == DAY_PHASE.NIGHT
	&& is_struct(squad)
	&& squad_is_marching(squad)
	&& variable_struct_exists(squad.properties, "marker_x")
	&& variable_struct_exists(squad.properties, "marker_y");

if (_squad_march_is_active)
{
	target_instance = noone;
	alert_target = noone;
	alert_target_timer = 0;
	forced_attack_target = noone;
	forced_attack_target_timer = 0;
	cached_follow_target = noone;
	is_attacking_target = false;
	visual_attack_offset_x = 0;
	visual_attack_offset_y = 0;

	update_separation_push();
	move_towards_world_point(squad.properties.marker_x, squad.properties.marker_y);
	apply_separation_push();
	update_walk_sway();
	exit;
}

// Enemy units remain passive throughout Unholy Night, even when fired upon.
if (unit_faction == UNIT_FACTION.ENEMY
	&& variable_global_exists("unholy_night_active")
	&& global.unholy_night_active)
{
	target_instance = noone;
	alert_target = noone;
	forced_attack_target = noone;
	is_attacking_target = false;
	is_walking = false;
	visual_attack_offset_x = 0;
	visual_attack_offset_y = 0;
	update_walk_sway();
	exit;
}

// Choose target by faction.
is_attacking_target = false;
is_walking = false;

var _is_enemy_unit = (unit_faction == UNIT_FACTION.ENEMY);
var _is_friendly_unit = (unit_faction == UNIT_FACTION.FRIENDLY);
var _friendly_follow_target = noone;
var _is_cultist_demon_unit = variable_instance_exists(id, "demon_type")
	&& demon_type != DEMON_TYPE.NONE;
var _had_target = instance_exists(target_instance);
var _current_target_is_valid = target_can_be_attacked(target_instance);

// Update lightweight separation vector before movement.
update_separation_push();

// March state is updated before any normal, panic, or retreat movement uses its multiplier.
enemy_march_update();

var _special_behavior_handled = unit_special_behavior_update();
var _has_forced_target = target_can_be_attacked(forced_attack_target);
var _should_search_target = false;

target_search_update_timer += gameplay_time_scale;

if (target_search_update_timer >= target_search_update_interval
	|| (_had_target && !_current_target_is_valid)
	|| _has_forced_target
	|| instance_exists(alert_target))
{
	_should_search_target = true;
	target_search_update_timer = 0;
}

if (!_current_target_is_valid)
{
	target_instance = noone;
}

if (instance_exists(manual_structure_target) && !target_can_be_attacked(manual_structure_target))
{
	manual_structure_target = noone;
}

if (!_special_behavior_handled && _has_forced_target)
{
	target_instance = forced_attack_target;
}
else if (!_special_behavior_handled && _should_search_target && _is_enemy_unit)
{
	// Nearby player units take priority over distant units, structures, and the cannon.
	var _nearest_player_unit = find_nearest_player_unit_target(target_detection_radius);

	if (instance_exists(_nearest_player_unit))
	{
		target_instance = _nearest_player_unit;
	}
	else
	{
		// Stop chasing a player unit that has left the detection radius.
		if (target_is_player_unit(target_instance))
		{
			target_instance = noone;
		}

		var _has_alert_target = false;

		if (instance_exists(alert_target))
		{
			if (target_can_be_attacked(alert_target))
			{
				target_instance = alert_target;
				_has_alert_target = true;
			}
			else
			{
				alert_target = noone;
				alert_target_timer = 0;
			}
		}

		// Without a combat alert, attack the first player building that physically blocks the cannon route.
		if (!_has_alert_target && unit_can_attack_cannon)
		{
			var _blocking_building = find_player_building_on_cannon_path();

			if (instance_exists(_blocking_building))
			{
				target_instance = _blocking_building;
			}
			else if (player_structure_can_be_targeted(target_instance))
			{
				target_instance = noone;
			}
		}
	}

	if (!instance_exists(target_instance) && !unit_can_attack_cannon && instance_exists(guard_target))
	{
		var _distance_to_guard = point_distance(x, y, guard_target.x, guard_target.y);

		if (_distance_to_guard > guard_radius)
		{
			target_instance = guard_target;
		}
	}

	if (!instance_exists(target_instance) && unit_can_attack_cannon && instance_exists(o_cannon))
	{
		target_instance = instance_find(o_cannon, 0);
	}
}
else if (!_special_behavior_handled && _should_search_target && _is_friendly_unit)
{
	if (instance_exists(alert_target))
	{
		if (target_can_be_attacked(alert_target))
		{
			target_instance = alert_target;
		}
		else
		{
			alert_target = noone;
			alert_target_timer = 0;
		}
	}

	if (_is_cultist_demon_unit && target_can_be_attacked(manual_structure_target))
	{
		target_instance = manual_structure_target;
	}
	else if (_is_cultist_demon_unit)
	{
		var _nearest_enemy_unit = find_nearest_target(o_enemy_units, vision_radius);

		if (instance_exists(_nearest_enemy_unit))
		{
			target_instance = _nearest_enemy_unit;
		}
		else
		{
			target_instance = find_nearest_enemy_object(vision_radius);
		}
	}
	else if (!_is_cultist_demon_unit)
	{
		var _priority_target = noone;

		if (!instance_exists(alert_target))
		{
			_priority_target = friendly_priority_target_find(vision_radius);
		}

		if (instance_exists(_priority_target))
		{
			target_instance = _priority_target;
		}
		else
		{
			var _nearest_enemy_unit = find_nearest_enemy_unit_target(vision_radius);

			if (instance_exists(_nearest_enemy_unit))
			{
				target_instance = _nearest_enemy_unit;
			}
		}
	}

	if (!_is_cultist_demon_unit && !instance_exists(target_instance))
	{
		target_instance = find_nearest_enemy_object(vision_radius);
	}

	if (!instance_exists(target_instance)
		&& global.day_phase == DAY_PHASE.NIGHT
		&& !regroup_is_active
		&& !rally_is_active
		&& (object_index == o_skeleton
			|| object_index == o_pitling))
	{
		_friendly_follow_target = find_nearest_visible_cultist();
	}

	cached_follow_target = _friendly_follow_target;

	if (!instance_exists(target_instance))
	{
		if (!instance_exists(_friendly_follow_target))
		{
			target_instance = find_nearest_cannon_attacker();
		}
	}

	// Inaccessible enemies are skipped; enemy walls are attacked only when no reachable enemy remains.
	var _target_is_manual_structure = _is_cultist_demon_unit
		&& target_instance == manual_structure_target;

	if (!_has_forced_target && !_target_is_manual_structure)
	{
		if (instance_exists(target_instance)
			&& target_instance.object_index != o_cannon
			&& !navigation_target_prepare(target_instance, attack_radius))
		{
			target_instance = noone;
		}

		if (!instance_exists(target_instance))
		{
			target_instance = find_nearest_reachable_enemy_target(vision_radius);
		}

		if (!instance_exists(target_instance))
		{
			target_instance = find_nearest_reachable_enemy_wall(vision_radius);
		}
	}

	if (!instance_exists(target_instance) && instance_exists(o_cannon))
	{
		var _cannon = instance_find(o_cannon, 0);
		var _distance_to_cannon = point_distance(x, y, _cannon.x, _cannon.y);

		if (friendly_guard_cannon_enabled
			&& !instance_exists(_friendly_follow_target)
			&& !regroup_is_active
			&& !rally_is_active
			&& _distance_to_cannon > cannon_guard_radius)
		{
			target_instance = _cannon;
		}
	}
}

if (!_should_search_target && _is_friendly_unit && target_can_be_attacked(cached_follow_target))
{
	_friendly_follow_target = cached_follow_target;
}

if (!_special_behavior_handled && instance_exists(target_instance) && !target_can_be_attacked(target_instance))
{
	target_instance = noone;
}

// Idle squad members follow a teammate who is already engaging an enemy.
var _squad_combat_guide = noone;

if (!_special_behavior_handled
	&& _is_friendly_unit
	&& !squad_unit_is_in_combat(id)
	&& is_struct(squad))
{
	_squad_combat_guide = squad_combat_guide_get(squad, id);

	if (instance_exists(_squad_combat_guide))
	{
		target_instance = noone;
		_friendly_follow_target = _squad_combat_guide;
	}
}

// Enemies keep attacking the cannon only while no player units are visible.
if (!_special_behavior_handled
	&& _is_enemy_unit
	&& instance_exists(target_instance)
	&& target_instance.object_index == o_cannon)
{
	var _visible_friendly_target = find_nearest_player_unit_target(target_detection_radius);

	if (instance_exists(_visible_friendly_target))
	{
		target_instance = _visible_friendly_target;
	}
}

// Move to target or attack it when close enough.
if (!_special_behavior_handled && instance_exists(target_instance))
{
	var _target_distance = point_distance(x, y, target_instance.x, target_instance.y);
	var _direct_target_distance = _target_distance;
	var _current_attack_radius = attack_radius;
	var _use_attack_ring = false;
	var _attack_move_x = target_instance.x;
	var _attack_move_y = target_instance.y;
	var _target_is_wall = variable_instance_exists(target_instance, "is_wall")
		&& target_instance.is_wall;
	var _target_is_player_building = variable_instance_exists(
		target_instance,
		"player_building_distance_to_point"
	);
	var _target_is_cannon = target_instance.object_index == o_cannon
		&& variable_instance_exists(target_instance, "combat_radius");

	if (_target_is_wall)
	{
		_target_distance = target_instance.wall_distance_to_point(x, y);
		_direct_target_distance = _target_distance;
	}
	else if (_target_is_player_building)
	{
		_target_distance = target_instance.player_building_distance_to_point(x, y);
		_direct_target_distance = _target_distance;
	}
	else if (_target_is_cannon)
	{
		_target_distance = max(0, _target_distance - target_instance.combat_radius);
		_direct_target_distance = _target_distance;
	}

	face_world_x(target_instance.x);

	if (target_instance == guard_target)
	{
		_current_attack_radius = guard_radius;
	}

	_use_attack_ring = attack_ring_should_use(target_instance, _current_attack_radius);

	if (_use_attack_ring)
	{
		var _attack_ring_point = attack_ring_point_get(target_instance, _current_attack_radius);
		_attack_move_x = _attack_ring_point[0];
		_attack_move_y = _attack_ring_point[1];
		_target_distance = point_distance(x, y, _attack_move_x, _attack_move_y);
	}

	if (_direct_target_distance <= _current_attack_radius
		|| (_use_attack_ring && _target_distance <= BALANCE_UNIT_ATTACK_RING_ARRIVE_RADIUS))
	{
		if (target_instance == guard_target)
		{
			is_attacking_target = true;
		}
		else if (target_instance.object_index != o_cannon || _is_enemy_unit)
		{
			is_attacking_target = true;
			attack_target(target_instance);
		}
	}
	else
	{
		if (_use_attack_ring
			&& navigation_target_prepare(target_instance, _current_attack_radius)
			&& !navigation_has_path)
		{
			move_towards_world_point(_attack_move_x, _attack_move_y);
		}
		else
		{
			move_towards_target(target_instance, _current_attack_radius);
		}
	}
}
else if (!_special_behavior_handled && _is_friendly_unit && instance_exists(_friendly_follow_target))
{
	var _follow_distance = point_distance(x, y, _friendly_follow_target.x, _friendly_follow_target.y);
	var _follow_arrive_radius = _friendly_follow_target == _squad_combat_guide
		? BALANCE_SQUAD_COMBAT_ASSIST_ARRIVE_RADIUS
		: regroup_arrive_radius;

	if (_follow_distance > _follow_arrive_radius)
	{
		move_towards_world_point(_friendly_follow_target.x, _friendly_follow_target.y);
	}
	else
	{
		face_world_x(_friendly_follow_target.x);
	}
}
else if (!_special_behavior_handled && _is_friendly_unit && regroup_is_active)
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
else if (!_special_behavior_handled && _is_friendly_unit && rally_is_active)
{
	if (rally_is_returning)
	{
		var _return_distance = point_distance(x, y, rally_home_x, rally_home_y);

		if (_return_distance <= cannon_guard_radius)
		{
			rally_is_active = false;
			rally_is_returning = false;
			rally_has_arrived = false;
			rally_group_id = 0;
		}
		else
		{
			move_towards_world_point(rally_home_x, rally_home_y);
		}
	}
	else
	{
		var _rally_distance = point_distance(x, y, rally_target_x, rally_target_y);

		if (_rally_distance <= rally_arrive_radius)
		{
			rally_has_arrived = true;
		}
		else
		{
			rally_has_arrived = false;
			move_towards_world_point(rally_target_x, rally_target_y);
		}

		if (rally_has_arrived && rally_group_ready_to_return())
		{
			rally_group_start_returning();
		}
	}
}

// Apply separation after main AI movement so units do not stack.
apply_separation_push();

// Add a simple sprite sway while the unit is walking.
update_walk_sway();
