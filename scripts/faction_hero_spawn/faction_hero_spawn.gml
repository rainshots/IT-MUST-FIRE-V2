/// @description Creates a fully healed hero at its saved origin and restores its existing squad membership.
function faction_hero_spawn(_hero)
{
	if (instance_exists(_hero.unit) && _hero.unit.hp > 0) return;
	var _squad = _hero.squad;
	squad_order_clear(_squad);
	squad_march_end(_squad);
	_squad.ai_target = noone;
	_squad.ai_target_retry_timer = 0;
	_squad.hero_respawn_remaining = 0;
	var _unit = instance_create_layer(_hero.spawn_x, _hero.spawn_y, "Instances", _hero.unit_object);
	_unit.faction = _hero.faction;
	_unit.squad = _squad;
	_unit.squad_unit_index = 0;
	_unit.foundry_permanent_bonuses_pending = false;
	squad_unit_permanent_bonuses_apply(_squad, _unit);
	_unit.hp = _unit.max_hp;
	_squad.units = [_unit];
	_squad.total_max_hp = _unit.max_hp;
	_hero.unit = _unit;
	_hero.waiting_to_respawn = false;
	squad_marker_position_update(_squad);
	corrupt_circle(_unit.x, _unit.y, BALANCE_HERO_CORRUPTION_RADIUS, 1, _hero.faction);
}
