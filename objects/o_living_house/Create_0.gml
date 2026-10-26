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
guard_unit_options = [o_enemy_peasant];
guard_count_min = BALANCE_LIVING_HOUSE_GUARDS_MIN;
guard_count_max = BALANCE_LIVING_HOUSE_GUARDS_MAX;
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


// Keep the initial garrison size and replace casualties one at a time.
guard_capacity = 0;
guard_replace_seconds = 0;
house_guard_spawn_one = function()
{
	var _angle = random(360);
	var _distance = random(BALANCE_HOUSE_SPAWN_RADIUS);
	var _type = guard_unit_options[irandom(array_length(guard_unit_options) - 1)];
	var _unit = instance_create_layer(x + lengthdir_x(_distance, _angle), y + lengthdir_y(_distance, _angle), "Instances", _type);
	_unit.guard_target = id;
	_unit.guard_radius = BALANCE_HOUSE_GUARD_RADIUS;
	_unit.unit_can_attack_cannon = false;
	_unit.is_night_attack_unit = false;
	_unit.ignored_for_night_end = true;
	_unit.owner_garnizon = noone;
};
house_guards_spawn = function()
{
	if (!guards_enabled || guards_spawned) return;
	// Dormant houses reveal their defenders only when a living player unit approaches.
	var _approached = false;
	with (o_friendly_units)
	{
		if (hp > 0 && point_distance(x, y, other.x, other.y) <= BALANCE_HOUSE_ACTIVATION_RADIUS)
		{
			_approached = true;
			break;
		}
	}
	if (!_approached) return;
	guards_spawned = true;
	guard_capacity = irandom_range(guard_count_min, guard_count_max) * BALANCE_ENEMY_SPAWN_COUNT_MULTIPLIER;
	for (var _i = 0; _i < guard_capacity; ++_i) house_guard_spawn_one();
};
house_guards_regenerate = function(_seconds)
{
	if (!guards_enabled || !guards_spawned) return;
	var _alive = 0;
	var _home = id;
	with (o_enemy_units) if (hp > 0 && guard_target == _home) _alive++;
	if (_alive >= guard_capacity) { guard_replace_seconds = 0; return; }
	guard_replace_seconds += _seconds;
	if (guard_replace_seconds >= BALANCE_HOUSE_GUARD_REPLACE_SECONDS)
	{
		guard_replace_seconds -= BALANCE_HOUSE_GUARD_REPLACE_SECONDS;
		house_guard_spawn_one();
	}
};
