event_inherited();
faction = FACTION.NEUTRAL;
is_neutral_building = true;
is_recovering = false;
is_attackable = true;
mana_income_bonus = 0;
corruption_bar_visible = false;
corruption_protection_radius = BALANCE_NEUTRAL_BUILDING_CORRUPTION_RADIUS;
recovery_seconds = BALANCE_NEUTRAL_BUILDING_RECOVERY_SECONDS;
recovery_smoke_timer = 0;
neutral_building_captured = function() {};
neutral_building_damage_receive = function(_amount, _attacker_faction, _source_instance = noone, _favor_faction = FACTION.NONE)
{
	if (is_recovering || _amount <= 0 || _attacker_faction == faction
		|| _attacker_faction < FACTION.ORDER || _attacker_faction > FACTION.NEUTRAL
		|| faction_is_defeated(_attacker_faction)) return;
	hp = max(0, hp - _amount);
	if (hp > 0) return;
	faction_favor_award(id, _source_instance, _favor_faction);
	faction = _attacker_faction;
	is_recovering = true;
	is_attackable = false;
	recovery_smoke_timer = 0;
	neutral_building_captured();
	if (instance_exists(o_corruption_grid))
	{
		var _grid = instance_find(o_corruption_grid, 0);
		_grid.corruption_protection_dirty = true;
		_grid.corrupt_circle(x, y, corruption_protection_radius, 1, faction);
	}
	if (instance_exists(o_fog_of_war)) o_fog_of_war.fog_visibility_update();
};
unit_damage_receive = function(_amount, _source_faction = UNIT_FACTION.NOONE, _critical = false, _chain = true, _source_instance = noone)
{
	if (!instance_exists(_source_instance) || !variable_instance_exists(_source_instance, "faction")) return;
	neutral_building_damage_receive(_amount, _source_instance.faction, _source_instance);
};
