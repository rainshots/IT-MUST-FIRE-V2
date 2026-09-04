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

provocateur_taunt_timer -= gameplay_time_scale;

if (provocateur_taunt_timer <= 0)
{
	provocateur_taunt_timer = BALANCE_PROVOCATEUR_TAUNT_INTERVAL * room_speed;
	provocateur_taunt_apply();
}
