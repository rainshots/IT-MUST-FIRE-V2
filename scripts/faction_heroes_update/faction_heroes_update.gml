/// @description Paints living heroes' ground and respawns fallen heroes after sixty unpaused simulation seconds.
function faction_heroes_update()
{
	if (!faction_match_started || faction_match_finished || global.pause) return;
	var _elapsed = global.gameplay_time_scale / max(1, room_speed);
	for (var _index = 0; _index < array_length(faction_heroes); ++_index)
	{
		var _hero = faction_heroes[_index];
		var _state = _hero.match_state;
		var _squad = _hero.squad;
		_squad.hero_respawn_enabled = !_state.defeated && instance_exists(_state.base) && _state.base.hp > 0;
		if (instance_exists(_hero.unit) && _hero.unit.hp > 0)
		{
			corrupt_circle(_hero.unit.x, _hero.unit.y, BALANCE_HERO_CORRUPTION_RADIUS, 1, _hero.faction);
			continue;
		}
		if (!_squad.hero_respawn_enabled)
		{
			_squad.hero_respawn_remaining = 0;
			continue;
		}
		if (!_hero.waiting_to_respawn)
		{
			_hero.waiting_to_respawn = true;
			_squad.hero_respawn_remaining = BALANCE_HERO_RESPAWN_SECONDS;
			_squad.ai_target = noone;
			squad_order_clear(_squad);
			squad_march_end(_squad);
			continue;
		}
		_squad.hero_respawn_remaining = max(0, _squad.hero_respawn_remaining - _elapsed);
		if (_squad.hero_respawn_remaining <= 0.000001) faction_hero_spawn(_hero);
	}
}
