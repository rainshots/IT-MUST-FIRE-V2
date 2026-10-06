/// @description Starts combat immediately without the old automatic waves or squad loading into the cannon.
function battle_start(_controller)
{
	if (!instance_exists(_controller) || _controller.battle_phase != BATTLE_PHASE.PREPARATION) return false;

	// Check current ground rather than the delayed capture flag; this includes both child point types.
	with (o_cursed_point)
	{
		if (!cursed_point_interaction_is_blocked()
			&& !ground_area_is_tainted(x, y, capture_ground_radius))
		{
			if (structure_selection_open)
			{
				cursed_point_structure_selection_close();
			}
			instance_destroy();
		}
	}

	_controller.battle_phase = BATTLE_PHASE.BATTLE;
	_controller.battle_elapsed_seconds = 0;
	_controller.battle_holy_cannon_next_seconds = BALANCE_BATTLE_HOLY_CANNON_FIRST_SHOT_SECONDS;
	_controller.battle_dragged_squad = noone;
	_controller.battle_preview_positions = [];
	global.day_phase = DAY_PHASE.NIGHT;
	global.focus_window = FOCUS_WINDOW.NOONE;
	global.pause = false;
	global.cannon_target_exists = false;
	_controller.hellcow_aim_is_dragging = false;
	_controller.night_fast_forward_set(false);

	// Start a random night track from the beginning when preparation ends.
	if (instance_exists(o_music_controller))
	{
		var _music_controller = instance_find(o_music_controller, 0);
		_music_controller.music_night_random_start();
	}

	// Replace preparation ammunition with a fresh finite loadout, keeping the original slot order.
	_controller.clear_cannon_projectile_queues();
	var _shell_stock = [
		{ projectile_type: PROJECTILE_TYPE.BOMB, count: BALANCE_BATTLE_HELLCOW_SHOTS },
		{ projectile_type: PROJECTILE_TYPE.HEAL, count: BALANCE_BATTLE_HEAL_SHOTS },
		{ projectile_type: PROJECTILE_TYPE.DOOM_BELL, count: BALANCE_BATTLE_DOOM_BELL_SHOTS }
	];
	var _shell_type_count = array_length(_shell_stock);
	for (var _type_index = 0; _type_index < _shell_type_count; ++_type_index)
	{
		var _stock = _shell_stock[_type_index];
		for (var _shell_index = 0; _shell_index < _stock.count; ++_shell_index)
		{
			_controller.cannon_projectile_queue_add(_stock.projectile_type);
		}
	}
	_controller.cannon_projectile_night_slots_capture();
	if (instance_exists(o_cannon))
	{
		var _cannon = instance_find(o_cannon, 0);
		_cannon.cannon_reload_night_reset();
		_cannon.cannon_reload_timer = 0;
		_cannon.cannon_night_damage_tracking_start();
		_cannon.cannon_opening_barrage_night_start();
	}
	squad_night_icon_sprites_capture();
	return true;
}
