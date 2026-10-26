/// @description Starts the next fight, healing surviving units and preserving cargo, workers, and Cannon HP; controller context.
function fight_start()
{
	if (fight_number >= BALANCE_FIGHT_COUNT) return;
	if (fight_initialized && (!instance_exists(o_heart) || o_heart.hp <= 0)) return;
	// Surviving individual units persist, heal, and return to defending the Cannon.
	with (o_friendly_units)
	{
		if (hp <= 0) { instance_destroy(); continue; }
		hp = max_hp;
		cargo_launched = (other.player_unit_mode == PLAYER_UNIT_MODE.ATTACK);
		defense_returning = false;
		target_instance = noone;
		alert_target = noone;
		alert_target_timer = 0;
		if (!cannon_loaded) { x = BALANCE_BUILDING_GRID_CENTER_X + cargo_idle_offset_x; y = BALANCE_BUILDING_GRID_CENTER_Y + cargo_idle_offset_y; }
	}
	// Snapshot corpses and any dead instances are cleared before the next wave.
	with (o_units_parent)
	{
		if (hp <= 0) instance_destroy();
	}
	with (o_meat) instance_destroy();
	with (o_projectile) instance_destroy();
	corpse_draw_data = [];
	squad_destroyed_remove();
	if (instance_exists(fight_wall)) instance_destroy(fight_wall);
	fight_wall = noone;
	with (o_base_tower) instance_destroy();
	if (!instance_exists(o_building_grid)) instance_create_layer(BALANCE_BUILDING_GRID_CENTER_X, BALANCE_BUILDING_GRID_CENTER_Y, "Instances", o_building_grid);
	var _zones = o_building_grid.enemy_zones;
	var _last_zone = _zones[array_length(_zones) - 1];
	var _tower = instance_create_layer(_last_zone.right, (_last_zone.top + _last_zone.bottom) * 0.5, "Instances", o_base_tower);
	// Keep the entire tower sprite inside the right end of its zone.
	_tower.x -= sprite_get_width(_tower.sprite_index) - sprite_get_xoffset(_tower.sprite_index) + BALANCE_ENEMY_ZONE_BUILDING_MARGIN;
	fight_living_houses_spawn();
	o_building_grid.enemy_zone_corrupted = [false, false, false];
	// Start on the objective now that faction selection no longer positions the camera.
	if (!fight_initialized && instance_exists(o_camera_controller))
	{
		o_camera_controller.camera_center_on_position(BALANCE_BUILDING_GRID_CENTER_X, BALANCE_BUILDING_GRID_CENTER_Y);
	}
	if (!fight_initialized)
	{
		with (o_worker_building_parent) instance_destroy();
		with (o_patch_mine) instance_destroy();
		if (!instance_exists(o_building_grid)) instance_create_layer(BALANCE_BUILDING_GRID_CENTER_X, BALANCE_BUILDING_GRID_CENTER_Y, "Instances", o_building_grid);
		with (o_cannon) instance_destroy();
		with (o_furnace) instance_destroy();
		with (o_warehouse) instance_destroy();
		with (o_exploding_shell) instance_destroy();
		instance_create_layer(BALANCE_BUILDING_GRID_CENTER_X, BALANCE_BUILDING_GRID_CENTER_Y, "Instances", o_heart);
		building_grid_trash_spawn();
		heart_corruption_seed();
		// Deploy the initial army beside the original grid, using the same side as recruited units.
		var _grid = building_grid_bounds_get();
		var _starting_types = [o_mawling, o_skeleton_archer];
		var _starting_counts = [BALANCE_STARTING_MAWLINGS, BALANCE_STARTING_ARCHERS];
		for (var _type = 0; _type < array_length(_starting_types); ++_type)
		{
			for (var _unit = 0; _unit < _starting_counts[_type]; ++_unit)
			{
				instance_create_layer(_grid.right + BALANCE_BUILDING_GRID_CELL_SIZE,
					BALANCE_BUILDING_GRID_CENTER_Y + random_range(-BALANCE_CARGO_IDLE_HALF_HEIGHT, BALANCE_CARGO_IDLE_HALF_HEIGHT),
					"Instances", _starting_types[_type]);
			}
		}
		global.faction_mana[global.player_faction]=BALANCE_STARTING_MANA;
	}
	fight_bonus_open = false;
	if (array_length(shop_options) == 0) shop_begin();
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

	global.pause = false;
	player_pause_active = false;
	global.focus_window = FOCUS_WINDOW.NOONE;
	fight_initialized = true;

	// Each fight begins with the same two-minute preparation and opening wave.
	fight_next_wave_seconds = BALANCE_WAVE_FIRST_DELAY;
	fight_wave_countdown_started = 0;
	fight_enemy_hp_multiplier = 1;
	fight_enemy_damage_multiplier = 1;
}
