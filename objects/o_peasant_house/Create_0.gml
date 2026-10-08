event_inherited();
max_hp = BALANCE_HOUSE_MAX_HP / 2;
hp = max_hp;
mana_income_bonus = BALANCE_PEASANT_HOUSE_MANA_INCOME;
house_unit_limit = BALANCE_HOUSE_INITIAL_UNIT_LIMIT;
house_spawn_timer = 0;
house_garrison_initialized = false;
tooltip_lines = ["Peasant House", "Provides +" + string(mana_income_bonus) + " Mana every 5 seconds after recovery.", "Defended by peasants. Capture it by reducing its HP to zero.", "Inactive and invulnerable during the 30-second recovery."];
house_guards_destroy = function()
{
	with (o_unit_neutral_peasant)
	{
		if (owner_house == other.id) instance_destroy();
	}
};
neutral_building_captured = function()
{
	house_guards_destroy();
	house_spawn_timer = 0;	house_garrison_initialized = false;
};
house_guard_call_for_help = function(_guard, _attacker)
{
	if (is_recovering) return;
	with (o_unit_neutral_peasant)
	{
		if (owner_house == other.id && target_can_be_attacked(_attacker)) alert_target = _attacker;
	}
};
house_guards_spawn = function(_limit)
{
	var _count = 0;
	with (o_unit_neutral_peasant)
	{
		if (owner_house == other.id && hp > 0) _count++;
	}
	var _amount = min(_limit, house_unit_limit - _count);
	for (var _i = 0; _i < _amount; ++_i)
	{
		var _angle = random(360);
		var _unit = instance_create_layer(x + lengthdir_x(BALANCE_HOUSE_SPAWN_RADIUS, _angle), y + lengthdir_y(BALANCE_HOUSE_SPAWN_RADIUS, _angle), "Instances", o_unit_neutral_peasant);
		_unit.faction = faction;
		_unit.owner_house = id;
		_unit.guard_target = id;
		_unit.guard_radius = BALANCE_HOUSE_GUARD_RADIUS;
		_unit.unit_can_attack_cannon = false;
	}
};
