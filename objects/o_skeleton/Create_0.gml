// Initialize shared unit state.
event_inherited();

// Skeleton combat stats.
max_hp = BALANCE_SKELETON_HP;
hp = max_hp;
damage = 0;
magic_damage = BALANCE_SKELETON_DAMAGE;
reload_time = BALANCE_SKELETON_RELOAD_TIME * room_speed;
attack_radius = BALANCE_SKELETON_ATTACK_RADIUS;
move_speed = 1.35;

// Skeleton health is drawn near the sprite pivot instead of above the head.
bar_offset_y = -2;

// Summoned skeletons survive long enough to regroup at the cannon during daytime.
summon_nights_remaining = BALANCE_SKELETON_NIGHT_LIFE;

// Skeleton hits can make most enemies briefly panic and run while the skeleton gives chase.
unit_attack_landed = function(_target, _is_critical_hit = false, _target_was_killed = false)
{
	if (_target_was_killed
		|| !instance_exists(_target)
		|| _target.object_index == o_enemy_knight
		|| !variable_instance_exists(_target, "unit_faction")
		|| _target.unit_faction != UNIT_FACTION.ENEMY
		|| random(1) >= BALANCE_SKELETON_PANIC_ON_HIT_CHANCE
		|| !variable_instance_exists(_target, "panic_flee_apply"))
	{
		return;
	}

	if (_target.panic_flee_apply(
		id,
		BALANCE_SKELETON_PANIC_ON_HIT_DURATION,
		BALANCE_SKELETON_PANIC_ON_HIT_COOLDOWN,
		BALANCE_SKELETON_PANIC_ON_HIT_FLEE_SPEED_MULTIPLIER
	))
	{
		forced_attack_target = _target;
		forced_attack_target_timer = (BALANCE_SKELETON_PANIC_ON_HIT_DURATION + 0.4) * room_speed;
	}
};
