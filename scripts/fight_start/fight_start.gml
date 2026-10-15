/// @description Starts the next fight, healing surviving units and preserving cargo, workers, and Cannon HP; controller context.
function fight_start()
{
	if (!instance_exists(o_cannon) || o_cannon.hp <= 0 || fight_number >= BALANCE_FIGHT_COUNT) return;
	// Surviving individual units persist, heal, and return to defending the Cannon.
	with (o_friendly_units)
	{
		if (hp <= 0) { instance_destroy(); continue; }
		hp = max_hp;
		cargo_launched = false;
		target_instance = noone;
		alert_target = noone;
		alert_target_timer = 0;
		if (!cannon_loaded) { x = o_cannon.x + cargo_idle_offset_x; y = o_cannon.y + cargo_idle_offset_y; }
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
	instance_create_layer(o_cannon.x + BALANCE_FIGHT_ENEMY_OFFSET_X + BALANCE_BASE_TOWER_ENEMY_OFFSET_X,
		o_cannon.y, "Instances", o_base_tower);
	fight_living_houses_spawn();
	// Start on the objective now that faction selection no longer positions the camera.
	if (!fight_initialized && instance_exists(o_camera_controller))
	{
		o_camera_controller.camera_center_on_position(o_cannon.x, o_cannon.y);
	}
	if (!fight_initialized)
	{
		with (o_worker_building_parent) instance_destroy();
		var _zone = building_zone_get();
		var _furnace = instance_create_layer(_zone.right, o_cannon.y, "Instances", o_furnace);
		_furnace.x -= sprite_get_width(_furnace.sprite_index) - sprite_get_xoffset(_furnace.sprite_index);
		var _warehouse=instance_create_layer(_zone.left+100,_zone.top+100,"Instances",o_warehouse);
		for(var _i=0;_i<3;++_i)
		{
			var _shell=instance_create_layer(_warehouse.x,_warehouse.y,"Instances",o_exploding_shell);
			warehouse_store(_shell,_warehouse);
		}
		global.faction_mana[global.player_faction]=BALANCE_STARTING_MANA;
	}
	with (o_furnace) charge_work_seconds = 0;
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
	fight_enemy_hp_multiplier = 1;
	fight_enemy_damage_multiplier = 1;
}
