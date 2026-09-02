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

support_buff_cooldown_timer -= gameplay_time_scale;

if (support_buff_cooldown_timer <= 0)
{
	var _buff_target = demon_wizard_buff_target_find(BALANCE_DEMON_WIZARD_BUFF_RADIUS);

	if (instance_exists(_buff_target)
		&& _buff_target.support_buff_add(id, BALANCE_DEMON_WIZARD_BUFF_DURATION * room_speed, BALANCE_DEMON_WIZARD_BUFF_MULTIPLIER))
	{
		support_buff_cooldown_timer = BALANCE_DEMON_WIZARD_BUFF_COOLDOWN * room_speed;
	}
}
