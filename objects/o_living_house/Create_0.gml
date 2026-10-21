// Passive enemy structure: no attacks, production or faction behavior.
max_hp = BALANCE_LIVING_HOUSE_HP;
hp = max_hp;
unit_faction = UNIT_FACTION.ENEMY;
is_attackable = true;
y_sort_enabled = true;
depth = BALANCE_BUILDING_GRID_ACTOR_DEPTH - floor(y);
image_speed = 0;
reward_paid = false;
building_label = "Living House";
mana_reward = BALANCE_LIVING_HOUSE_MANA;
guards_enabled = true;
guards_spawned = false;
// Explicit combat destruction keeps room and fight cleanup from granting Mana.
house_death_process = function()
{
	if (hp > 0 || reward_paid) return;
	reward_paid = true;
	if (instance_exists(o_game_controller) && o_game_controller.fight_state == FIGHT_STATE.ACTIVE)
		global.faction_mana[global.player_faction] += mana_reward;
	instance_destroy();
};
unit_damage_receive = function(_damage_amount, _source_faction = UNIT_FACTION.NOONE, _is_critical = false, _can_trigger_soul_chain = true, _source_instance = noone, _favor_faction = FACTION.NONE)
{
	if (hp <= 0 || _damage_amount <= 0 || _source_faction == unit_faction) return 0;
	var _applied = min(hp, _damage_amount);
	hp -= _applied;
	damage_popup_create(x, y, _applied, unit_faction, _is_critical);
	if (hp <= 0) house_death_process();
	return _applied;
};


// Spawn only after zone placement has finished, using the original house guard settings.
house_guards_spawn = function()
{
	if (!guards_enabled || guards_spawned) return;
	guards_spawned = true;
	var _count = irandom_range(BALANCE_LIVING_HOUSE_GUARDS_MIN, BALANCE_LIVING_HOUSE_GUARDS_MAX);
	for (var _i = 0; _i < _count; ++_i)
	{
		var _angle = random(360);
		var _distance = random(BALANCE_HOUSE_SPAWN_RADIUS);
		var _unit = instance_create_layer(x + lengthdir_x(_distance, _angle), y + lengthdir_y(_distance, _angle), "Instances", o_enemy_peasant);
		_unit.guard_target = id;
		_unit.guard_radius = BALANCE_HOUSE_GUARD_RADIUS;
		_unit.unit_can_attack_cannon = false;
		_unit.is_night_attack_unit = false;
		_unit.ignored_for_night_end = true;
		_unit.owner_garnizon = noone;
	}
};
