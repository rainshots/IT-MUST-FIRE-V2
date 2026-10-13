/// @description Starts the next fight, clearing combat allies while preserving cultists and Cannon HP; controller context.
function fight_start()
{
	if (!instance_exists(o_cannon) || o_cannon.hp <= 0 || fight_number >= BALANCE_FIGHT_COUNT) return;
	// Remove the previous army directly; cultists do not inherit from this parent.
	with (o_friendly_units) instance_destroy();
	// Snapshot corpses and any dead instances are cleared before the next wave.
	with (o_units_parent)
	{
		if (hp <= 0) instance_destroy();
	}
	with (o_meat) instance_destroy();
	with (o_projectile) instance_destroy();
	corpse_draw_data = [];
	squad_destroyed_remove();
	// Every fight begins with the same half-health defense and no saved rebuilding work.
	if (instance_exists(fight_wall)) instance_destroy(fight_wall);
	fight_wall = fight_wall_create();
	// Each fight gets a fresh passive enemy objective beyond the enemy spawn line.
	with (o_base_tower) instance_destroy();
	instance_create_layer(o_cannon.x + BALANCE_FIGHT_ENEMY_OFFSET_X + BALANCE_BASE_TOWER_ENEMY_OFFSET_X,
		o_cannon.y, "Instances", o_base_tower);
	if (!instance_exists(o_foundry))
	{
		instance_create_layer(o_cannon.x + BALANCE_FIGHT_FOUNDRY_OFFSET_X, o_cannon.y, "Instances", o_foundry);
	}
	with (o_foundry) rebuild_hp = 0;
	// Start on the objective now that faction selection no longer positions the camera.
	if (!fight_initialized && instance_exists(o_camera_controller))
	{
		o_camera_controller.camera_center_on_position(o_cannon.x, o_cannon.y);
	}
	// Only the initial fight creates workers; later fights preserve their assignments.
	// The Furnace is created once beside the Cannon, independent of legacy buildings.
	if (!fight_initialized && !instance_exists(o_furnace))
	{
		instance_create_layer(o_cannon.x + BALANCE_FURNACE_OFFSET_X,
			o_cannon.y + BALANCE_FURNACE_OFFSET_Y, "Instances", o_furnace);
	}
	if (!fight_initialized && !instance_exists(o_cauldron))
	{
		instance_create_layer(o_cannon.x + BALANCE_CAULDRON_OFFSET_X,
			o_cannon.y + BALANCE_CAULDRON_OFFSET_Y, "Instances", o_cauldron);
	}
	with (o_cauldron)
	{
		mana_work_seconds = 0;
		charge_work_seconds = 0;
	}
	with (o_furnace) charge_work_seconds = 0;
	if (!instance_exists(o_forge))
	{
		instance_create_layer(o_cannon.x + BALANCE_FORGE_OFFSET_X, o_cannon.y + BALANCE_FORGE_OFFSET_Y, "Instances", o_forge);
	}
	worker_starting_spawn();
	fight_number++;
	fight_state = FIGHT_STATE.ACTIVE;
	fight_elapsed_seconds = 0;
	fight_wave_index = 0;
	fight_charge = 0;
	cannon_aiming = false;
	with (o_cannonball) instance_destroy();
	with (o_cannon_effect) instance_destroy();
	faction_mana_timer = 0;
	global.faction_mana[global.player_faction] = BALANCE_MANA_STARTING_AMOUNT;
	global.pause = false;
	player_pause_active = false;
	global.focus_window = FOCUS_WINDOW.NOONE;
	fight_initialized = true;

	// Keep the original enemy introductions and stat multipliers, with no boss-night budget dips.
	var _balance = night_attack_balance_get(fight_number);
	// Rebuild the original budget curve so both preset jumps and minimum growth are reduced equally.
	var _first_balance = night_attack_balance_get(1);
	var _base_budget = _first_balance.difficulty_budget;
	var _original_budget = _base_budget;
	for (var _fight_index = 2; _fight_index <= fight_number; ++_fight_index)
	{
		var _fight_balance = night_attack_balance_get(_fight_index);
		_original_budget = max(_fight_balance.difficulty_budget, _original_budget * BALANCE_FIGHT_BUDGET_GROWTH);
	}
	fight_enemy_budget = _base_budget + (_original_budget - _base_budget) * BALANCE_FIGHT_BUDGET_INCREASE_MULTIPLIER;
	fight_enemy_hp_multiplier = max(fight_enemy_hp_multiplier, _balance.enemy_hp_multiplier);
	fight_enemy_damage_multiplier = max(fight_enemy_damage_multiplier, _balance.enemy_damage_multiplier);
	fight_enemy_types = [];
	var _direction_count = array_length(_balance.enemy_types);
	for (var _direction_index = 0; _direction_index < _direction_count; ++_direction_index)
	{
		var _types = _balance.enemy_types[_direction_index];
		var _type_count = array_length(_types);
		for (var _type_index = 0; _type_index < _type_count; ++_type_index)
		{
			array_push(fight_enemy_types, _types[_type_index]);
		}
	}
	var _enemy_type_count = array_length(fight_enemy_types);
	fight_enemy_remaining_budgets = array_create(_enemy_type_count, fight_enemy_budget / max(1, _enemy_type_count));
	if (fight_number >= 2) fight_bonus_begin();
}
