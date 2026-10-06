/// @description Stores an enemy's original position and timed attack zone once per battle.
function battle_enemy_prepare(_unit, _controller)
{
	if (!instance_exists(_unit) || !instance_exists(_controller)
		|| _unit.unit_faction != UNIT_FACTION.ENEMY || _unit.battle_zone >= 0)
	{
		return;
	}

	_unit.battle_controller = _controller;
	_unit.battle_home_x = _unit.x;
	_unit.battle_home_y = _unit.y;
	_unit.battle_zone = battle_enemy_zone_get(_unit.x, room_width);
	_unit.battle_attack_seconds = infinity;
	if (_unit.battle_zone == BATTLE_ZONE.FIRST_ATTACK)
	{
		_unit.battle_attack_seconds = BALANCE_BATTLE_FIRST_ATTACK_SECONDS;
	}
	else if (_unit.battle_zone == BATTLE_ZONE.SECOND_ATTACK)
	{
		_unit.battle_attack_seconds = BALANCE_BATTLE_SECOND_ATTACK_SECONDS;
	}

	// Waiting attackers also hold their starting position until their release time.
	_unit.unit_can_attack_cannon = false;
	_unit.guard_target = noone;
	_unit.target_instance = noone;
	_unit.alert_target = noone;
	_unit.is_night_attack_unit = false;
}
