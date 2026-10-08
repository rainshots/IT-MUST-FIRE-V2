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
if (global.player_faction != FACTION.NONE
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

// Gameplay time can slow independently from rendering, input, and camera movement.
gameplay_time_scale = variable_global_exists("gameplay_time_scale")
	? global.gameplay_time_scale
	: 1;
image_speed = gameplay_time_scale;

// Fog visibility keeps updating while paused because the fog layer is a visual system.
unit_is_hidden_by_fog();

// Pause freezes unit AI and combat.
if (global.pause)
{
	exit;
}

// Child Create events set their final reload time after the parent Create has finished.
if (initial_attack_reload_pending)
{
	reload_timer = max(1, reload_time * unit_attack_reload_multiplier_get());
	initial_attack_reload_pending = false;
}

// Timed Roar effects and all visual trait markers share one lightweight update.
unholy_abyss_effects_update();
unholy_trait_aura_update();

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

// Squad loading is a visual run; its projectile is already available in the cannon queue.
if (cannon_loading || cannon_loaded)
{
	target_instance = noone;
	alert_target = noone;
	forced_attack_target = noone;
	forced_attack_target_timer = 0;
	is_attacking_target = false;
	visual_attack_offset_x = 0;
	visual_attack_offset_y = 0;
	is_walking = cannon_loading;
	update_walk_sway();
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

// Capturable-house peasants defend locally and return if combat pulls them too far away.
if (instance_exists(owner_house) && variable_instance_exists(owner_house, "is_neutral_building")
	&& point_distance(x, y, owner_house.x, owner_house.y) > guard_radius * 2)
{
	target_instance = noone;
	alert_target = noone;
	forced_attack_target = noone;
	is_attacking_target = false;
	move_towards_world_point(owner_house.x, owner_house.y);
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

// Funeral Pause stasis freezes every action while its owning bell remains intact.
if (doom_bell_stasis_is_active())
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

// Holy ground slowly restores enemy units standing on it.
enemy_saint_ground_heal_update();

// The day-three upgrade slowly restores player units standing on Taint.
friendly_tainted_ground_heal_update();

// Taint Treatment heals only while this unit is safe on corrupted ground.
unholy_taint_treatment_update();

// Savage Leap owns movement and sprite offset throughout its short flight.
if (unholy_savage_leap_update())
{
	update_walk_sway();
	exit;
}

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

// System 2 may own movement, or prepare one nearby target for the normal combat code below.
if (squad_order_unit_update(id))
{
	update_walk_sway();
	exit;
}

// System 1 marching squad members run to their flag and ignore every combat target.
var _squad_march_is_active = squad_is_player_owned(squad)
	&& global.player_faction != FACTION.NONE
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
	var _march_move_speed = squad_march_unit_speed_get(id);
	move_towards_world_point(squad.properties.marker_x, squad.properties.marker_y, _march_move_speed);
	apply_separation_push();
	update_walk_sway();
	exit;
}

// Every unit encounters opponents by faction, regardless of its original object family.
is_attacking_target = false;
is_walking = false;
var _is_enemy_unit = faction != global.player_faction;
var _special_behavior_handled = unit_special_behavior_update();
update_separation_push();
enemy_march_update();
var _had_target = target_instance != noone;
var _valid_target = target_can_be_attacked(target_instance);
if (!_valid_target) target_instance = noone;
target_search_update_timer += gameplay_time_scale;
var _should_search = target_search_update_timer >= target_search_update_interval
	|| (_had_target && !_valid_target);
if (!_special_behavior_handled && !squad_order_in_combat)
{
	if (target_can_be_attacked(forced_attack_target)) target_instance = forced_attack_target;
	else if (faction == global.player_faction && target_can_be_attacked(manual_structure_target)) target_instance = manual_structure_target;
	else if (_should_search)
	{
		target_search_update_timer = 0;
		target_instance = find_nearest_faction_target(vision_radius);
		if (!instance_exists(target_instance) && target_can_be_attacked(alert_target)) target_instance = alert_target;
		if (!instance_exists(target_instance) && is_struct(squad) && !squad_is_player_owned(squad)
			&& faction_building_is_targetable(faction, squad.ai_target))
		{
			target_instance = squad.ai_target;
		}
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
// Separation and visual sway run for both player and AI squads.
apply_separation_push();
update_walk_sway();
