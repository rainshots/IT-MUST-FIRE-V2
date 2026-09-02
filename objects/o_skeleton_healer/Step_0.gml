// Run shared movement and combat first.
event_inherited();

var _balance_test_tick_is_blocked = variable_global_exists("balance_test_active")
	&& global.balance_test_active
	&& (!variable_global_exists("balance_test_manual_tick_active")
		|| !global.balance_test_manual_tick_active);

if (unholy_savage_leap_active
	|| _balance_test_tick_is_blocked
	|| global.pause
	|| cannon_loading
	|| cannon_loaded
	|| hp <= 0)
{
	exit;
}

support_heal_cooldown_timer -= gameplay_time_scale;

if (support_heal_cooldown_timer <= 0)
{
	var _heal_target = skeleton_healer_target_find(BALANCE_SKELETON_HEALER_HEAL_RADIUS);

	if (instance_exists(_heal_target)
		&& _heal_target.support_heal_add(
			id,
			BALANCE_SKELETON_HEALER_HEAL_DURATION * room_speed,
			BALANCE_SKELETON_HEALER_HEAL_INTERVAL * room_speed,
			BALANCE_SKELETON_HEALER_HEAL_AMOUNT
		))
	{
		support_heal_cooldown_timer = BALANCE_SKELETON_HEALER_HEAL_COOLDOWN * room_speed;
	}
}
