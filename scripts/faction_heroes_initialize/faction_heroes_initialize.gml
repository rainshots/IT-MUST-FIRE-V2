/// @description Creates one hero squad per surviving faction after faction selection; called by o_game_controller.
function faction_heroes_initialize()
{
	if (faction_heroes_initialized || !instance_exists(o_cannon)) return;
	faction_heroes_initialized = true;
	var _cannon = instance_find(o_cannon, 0);
	var _objects = [o_unit_order_hero, o_unit_undead_warlock, o_unit_demons_imp, o_unit_wildlings_brute];
	var _names = ["Order Hero", "Undead Warlock", "Demons Imp", "Wildlings Brute"];
	for (var _index = 0; _index < array_length(faction_match_states); ++_index)
	{
		var _state = faction_match_states[_index];
		if (_state.defeated || !instance_exists(_state.base) || _state.base.hp <= 0) continue;
		var _faction = _state.faction;
		var _base = _state.base;
		var _direction = point_direction(_base.x, _base.y, _cannon.x, _cannon.y);
		var _squad = new squad_constructor(SQUAD_TYPE.HERO, _objects[_faction], 1, _faction);
		_squad.name = _names[_faction];
		_squad.is_hero = true;
		_squad.hero_respawn_enabled = true;
		array_push(global.squads, _squad);
		var _hero = {
			faction: _faction,
			match_state: _state,
			unit_object: _objects[_faction],
			spawn_x: _base.x + lengthdir_x(BALANCE_HERO_SPAWN_DISTANCE, _direction),
			spawn_y: _base.y + lengthdir_y(BALANCE_HERO_SPAWN_DISTANCE, _direction),
			unit: noone,
			squad: _squad,
			waiting_to_respawn: false
		};
		array_push(faction_heroes, _hero);
		faction_hero_spawn(_hero);
	}
}
