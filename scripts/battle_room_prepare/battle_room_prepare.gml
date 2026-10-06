/// @description Initializes the battler after all room instances have completed their Create events.
function battle_room_prepare(_controller)
{
	if (!instance_exists(_controller) || !_controller.battle_mode_active)
	{
		return;
	}

	// Resolve editor FX depths once, before the first frame sorts scenery by Y.
	battle_effect_layers_prepare();

	// Battle setup uses the existing combat systems without starting the old day cycle.
	global.day_cycle_enabled = false;
	global.day_phase = DAY_PHASE.DAY;
	global.pause = false;
	global.fog_of_war_visible = false;
	global.tutorial_hints_enabled = false;
	global.squad_limit = BALANCE_BATTLE_ROSTER_LIMIT;
	global.cannon_projectile_queue = array_create(BALANCE_BATTLE_TAINT_SHOTS, PROJECTILE_TYPE.CORRUPTION);
	global.cannon_projectile_payload_queue = array_create(BALANCE_BATTLE_TAINT_SHOTS, noone);
	global.cannon_selected_projectile_index = 0;

	// Campaign squads retain their composition; each encounter restores their members like the old morning.
	var _map = instance_find(o_world_map, 0);
	global.squads = instance_exists(_map) ? _map.squads : battle_roster_create();
	var _squads = global.squads;
	var _squad_count = array_length(_squads);
	for (var _index = 0; _index < _squad_count; ++_index)
	{
		var _squad = _squads[_index];
		// Older roster data gains the counter once; existing totals are never reset between battles.
		if (!variable_struct_exists(_squad, "damage_dealt_total"))
		{
			_squad.damage_dealt_total = 0;
		}
		_squad.units = [];
		_squad.total_max_hp = 0;
		_squad.properties.battle_deployed = false;
		_squad.properties.battle_deployment_projectile = noone;
		_squad.properties.marker_is_dragged = false;
		_squad.properties.is_selected = false;
		_squad.properties.day_point = noone;
		_squad.properties.order_mode = SQUAD_ORDER.NONE;
		_squad.properties.march_is_active = false;
		_squad.properties.combat_guide_unit = noone;
	}

	// Vary the starting border gently while keeping every row connected to the left edge.
	var _grid = instance_find(o_corruption_grid, 0);
	if (instance_exists(_grid))
	{
		ds_grid_clear(_grid.corruption_grid, 0);
		var _base_columns = round(BALANCE_BATTLE_STARTING_TAINT_WIDTH / _grid.cell_size);
		var _variation_columns = max(1, round(BALANCE_BATTLE_STARTING_TAINT_EDGE_VARIATION / _grid.cell_size));
		var _minimum_band_rows = max(1, round(BALANCE_BATTLE_STARTING_TAINT_EDGE_MIN_HEIGHT / _grid.cell_size));
		var _maximum_band_rows = max(_minimum_band_rows, round(BALANCE_BATTLE_STARTING_TAINT_EDGE_MAX_HEIGHT / _grid.cell_size));
		var _border_offset = 0;
		var _rows_until_change = 0;
		var _row_count = _grid.grid_height;

		for (var _row = 0; _row < _row_count; ++_row)
		{
			// One-cell steps and random band heights avoid both a straight edge and isolated patches.
			if (_rows_until_change <= 0)
			{
				var _direction = choose(-1, 1);
				if (abs(_border_offset + _direction) > _variation_columns)
				{
					_direction = -_direction;
				}
				_border_offset += _direction;
				_rows_until_change = irandom_range(_minimum_band_rows, _maximum_band_rows);
			}

			var _column_count = clamp(_base_columns + _border_offset, 1, _grid.grid_width);
			ds_grid_set_region(_grid.corruption_grid, 0, _row, _column_count - 1, _row, 1);
			_rows_until_change--;
		}
	}

	// Classify editor-placed enemies by their starting positions, never by their later movement.
	var _unit_count = instance_number(o_units_parent);
	for (var _unit_index = 0; _unit_index < _unit_count; ++_unit_index)
	{
		battle_enemy_prepare(instance_find(o_units_parent, _unit_index), _controller);
	}
	battle_result_update(_controller);
}
