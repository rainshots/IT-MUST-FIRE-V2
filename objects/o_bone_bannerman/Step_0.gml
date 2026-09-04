// Run shared movement, squad behavior, and damage processing first.
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

bone_bannerman_aura_update_timer -= gameplay_time_scale;

if (bone_bannerman_aura_update_timer > 0)
{
	exit;
}

bone_bannerman_aura_update_timer = bone_bannerman_aura_update_interval;

var _effect_radius_squared = sqr(BALANCE_BONE_BANNERMAN_EFFECT_RADIUS);
var _buff_duration = BALANCE_BONE_BANNERMAN_BUFF_LINGER_TIME * room_speed;
var _friendly_count = instance_number(o_friendly_units);

// Refresh one non-stacking banner buff on every living player unit in range.
for (var _friendly_index = 0; _friendly_index < _friendly_count; ++_friendly_index)
{
	var _friendly_unit = instance_find(o_friendly_units, _friendly_index);

	if (!instance_exists(_friendly_unit)
		|| !variable_instance_exists(_friendly_unit, "hp")
		|| !variable_instance_exists(_friendly_unit, "bone_bannerman_buff_apply")
		|| _friendly_unit.hp <= 0)
	{
		continue;
	}

	// Automated arenas must never share an aura between separate matches.
	if (balance_test_match_id >= 0
		&& (!variable_instance_exists(_friendly_unit, "balance_test_match_id")
			|| _friendly_unit.balance_test_match_id != balance_test_match_id))
	{
		continue;
	}

	var _distance_x = _friendly_unit.x - x;
	var _distance_y = _friendly_unit.y - y;
	var _distance_squared = (_distance_x * _distance_x) + (_distance_y * _distance_y);

	if (_distance_squared <= _effect_radius_squared)
	{
		_friendly_unit.bone_bannerman_buff_apply(_buff_duration);
	}
}
