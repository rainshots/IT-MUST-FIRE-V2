// Ground corruption grid settings.
depth = BALANCE_CAPTURED_BUILDING_RIFT_DEPTH;
cell_size = BALANCE_GRID_CELL_SIZE;
grid_width = ceil(room_width / cell_size);
grid_height = ceil(room_height / cell_size);

// Draw Taint and Saint immediately above roads, using the current room layer depth.
var _roads_layer = layer_get_id("Roads");

if (_roads_layer != -1)
{
	var _roads_depth = layer_get_depth(_roads_layer);
	depth = _roads_depth - 1;
}

// Corruption values are stored from 0 to 1.
corruption_grid = ds_grid_create(grid_width, grid_height);
ds_grid_clear(corruption_grid, 0);

// Empty compatibility grids for legacy map-object checks; ownership lives in corruption_faction_grid.
saint_grid = ds_grid_create(grid_width, grid_height);
ds_grid_clear(saint_grid, 0);
saint_source_grid = ds_grid_create(grid_width, grid_height);
ds_grid_clear(saint_source_grid, 0);

// Passive spread makes fully corrupted cells infect their neighbors up to a limit.
full_corruption_value = 1;
passive_spread_limit = 0.5;
passive_spread_per_second = BALANCE_CORRUPTION_NEIGHBOR_SPREAD_PER_SECOND;
passive_spread_update_interval = BALANCE_CORRUPTION_NEIGHBOR_SPREAD_UPDATE_INTERVAL;
passive_spread_update_timer = 0;
neighbor_offset_min = -1;
neighbor_offset_max = 1;

// Saint grows from any linked source and fades after all sources are gone.
full_saint_value = 1;
minimum_saint_protected_amount = BALANCE_SAINT_MINIMUM_PROTECTED_AMOUNT;
saint_change_per_second = BALANCE_SAINT_CHANGE_PER_SECOND;
saint_update_interval = BALANCE_SAINT_UPDATE_INTERVAL;
saint_update_timer = 0;

// Visual settings for corrupted ground cells.
minimum_draw_corruption = 0.01;
minimum_corruption_alpha = 0.18;
maximum_corruption_alpha = 1;
maximum_saint_alpha = 0.72;
uncorrupted_color = c_black;
maximum_corruption_color = COLOR_CORRUPTION_MAX;
maximum_saint_color = COLOR_SAINT_MAX;

captured_building_rift_noise_get = function(_source_seed, _segment_index)
{
	var _noise_seed = (_source_seed * 12.9898) + (_segment_index * 78.233);
	var _noise_value = abs(sin(_noise_seed) * 43758.5453);
	return _noise_value - floor(_noise_value);
};

captured_building_rift_line_draw = function(_start_x, _start_y, _end_x, _end_y, _source_seed, _line_width, _line_alpha)
{
	var _distance = point_distance(_start_x, _start_y, _end_x, _end_y);

	if (_distance <= 1)
	{
		return;
	}

	var _segment_count = max(2, ceil(_distance / BALANCE_CAPTURED_BUILDING_RIFT_SEGMENT_LENGTH));
	var _line_direction = point_direction(_start_x, _start_y, _end_x, _end_y);
	var _normal_direction = _line_direction + 90;
	var _previous_x = _start_x;
	var _previous_y = _start_y;

	draw_set_alpha(_line_alpha);
	var _rift_faction = ground_faction_get(_start_x, _start_y);
	draw_set_color(_rift_faction == FACTION.UNDEAD || _rift_faction == FACTION.NONE
		? COLOR_CAPTURED_BUILDING_RIFT : corruption_color_get(_rift_faction));

	for (var _segment_index = 1; _segment_index <= _segment_count; ++_segment_index)
	{
		var _progress = _segment_index / _segment_count;
		var _segment_x = lerp(_start_x, _end_x, _progress);
		var _segment_y = lerp(_start_y, _end_y, _progress);

		if (_segment_index < _segment_count)
		{
			var _noise = captured_building_rift_noise_get(_source_seed, _segment_index);
			var _offset = ((_noise * 2) - 1) * BALANCE_CAPTURED_BUILDING_RIFT_JITTER;

			_segment_x += lengthdir_x(_offset, _normal_direction);
			_segment_y += lengthdir_y(_offset, _normal_direction);
		}

		draw_line_width(_previous_x, _previous_y, _segment_x, _segment_y, _line_width);

		_previous_x = _segment_x;
		_previous_y = _segment_y;
	}
};

captured_building_rifts_draw = function()
{
	if (!instance_exists(o_cannon))
	{
		return;
	}

	var _cannon = instance_find(o_cannon, 0);
	var _map_object_count = instance_number(o_map_objects_parent);

	for (var _map_object_index = 0; _map_object_index < _map_object_count; ++_map_object_index)
	{
		var _map_object = instance_find(o_map_objects_parent, _map_object_index);

		if (!instance_exists(_map_object)
			|| !variable_instance_exists(_map_object, "is_captured")
			|| !_map_object.is_captured)
		{
			continue;
		}

		var _rift_owner = corruption_faction_get(_map_object);
		if (defeated_factions[_rift_owner]) continue;
		var _draws_base_rift = false;

		if (variable_instance_exists(_map_object, "tower_capture_enabled")
			&& _map_object.tower_capture_enabled)
		{
			_draws_base_rift = true;
		}

		if (_map_object.object_index == o_grave_spire)
		{
			_draws_base_rift = true;
		}

		if (_map_object.object_index == o_ihor_extractor)
		{
			_draws_base_rift = true;
		}

		if (!_draws_base_rift)
		{
			continue;
		}

		captured_building_rift_line_draw(
			_map_object.x,
			_map_object.y,
			_cannon.x,
			_cannon.y,
			_map_object.x + (_map_object.y * 13),
			BALANCE_CAPTURED_BUILDING_RIFT_WIDTH,
			BALANCE_CAPTURED_BUILDING_RIFT_ALPHA
		);
		captured_building_rift_line_draw(
			_map_object.x,
			_map_object.y,
			_cannon.x,
			_cannon.y,
			_map_object.x + (_map_object.y * 13),
			BALANCE_CAPTURED_BUILDING_RIFT_CORE_WIDTH,
			BALANCE_CAPTURED_BUILDING_RIFT_CORE_ALPHA
		);

		if (_map_object.object_index == o_grave_spire
			&& variable_instance_exists(_map_object, "grave_spire_grave_count_get"))
		{
			_map_object.grave_spire_grave_count_get();

			var _map_object_id = _map_object.id;
			var _grave_count = instance_number(o_grave);

			for (var _grave_index = 0; _grave_index < _grave_count; ++_grave_index)
			{
				var _grave = instance_find(o_grave, _grave_index);

				if (!instance_exists(_grave)
					|| !variable_instance_exists(_grave, "assigned_grave_spire")
					|| _grave.assigned_grave_spire != _map_object_id)
				{
					continue;
				}

				var _grave_seed = _map_object.x + (_map_object.y * 13) + (_grave.x * 7) + (_grave.y * 3);

				captured_building_rift_line_draw(
					_grave.x,
					_grave.y,
					_map_object.x,
					_map_object.y,
					_grave_seed,
					BALANCE_CAPTURED_BUILDING_RIFT_WIDTH,
					BALANCE_CAPTURED_BUILDING_RIFT_ALPHA
				);
				captured_building_rift_line_draw(
					_grave.x,
					_grave.y,
					_map_object.x,
					_map_object.y,
					_grave_seed,
					BALANCE_CAPTURED_BUILDING_RIFT_CORE_WIDTH,
					BALANCE_CAPTURED_BUILDING_RIFT_CORE_ALPHA
				);
			}
		}

		if (_map_object.object_index == o_ihor_extractor
			&& variable_instance_exists(_map_object, "ihor_extractor_morning_income_get"))
		{
			_map_object.ihor_extractor_morning_income_get();

			var _extractor_object_id = _map_object.id;
			var _vein_count = instance_number(o_ihor_vein);

			for (var _vein_index = 0; _vein_index < _vein_count; ++_vein_index)
			{
				var _vein = instance_find(o_ihor_vein, _vein_index);

				if (!instance_exists(_vein)
					|| !variable_instance_exists(_vein, "assigned_ihor_extractor")
					|| _vein.assigned_ihor_extractor != _extractor_object_id)
				{
					continue;
				}

				var _vein_seed = _map_object.x + (_map_object.y * 13) + (_vein.x * 7) + (_vein.y * 3);

				captured_building_rift_line_draw(
					_vein.x,
					_vein.y,
					_map_object.x,
					_map_object.y,
					_vein_seed,
					BALANCE_CAPTURED_BUILDING_RIFT_WIDTH,
					BALANCE_CAPTURED_BUILDING_RIFT_ALPHA
				);
				captured_building_rift_line_draw(
					_vein.x,
					_vein.y,
					_map_object.x,
					_map_object.y,
					_vein_seed,
					BALANCE_CAPTURED_BUILDING_RIFT_CORE_WIDTH,
					BALANCE_CAPTURED_BUILDING_RIFT_CORE_ALPHA
				);
			}
		}
	}
};

// Each cell has exactly one owner. Legacy saint grids remain empty for old readers.
corruption_faction_grid = ds_grid_create(grid_width, grid_height);
ds_grid_clear(corruption_faction_grid, FACTION.NONE);
base_corruption_initialized = false;
defeated_factions = array_create(FACTION.WILDLINGS + 1, false);

ground_faction_get = function(_world_x, _world_y)
{
	var _cell_x = floor(_world_x / cell_size);
	var _cell_y = floor(_world_y / cell_size);
	if (_cell_x < 0 || _cell_y < 0 || _cell_x >= grid_width || _cell_y >= grid_height) return FACTION.NONE;
	if (ds_grid_get(corruption_grid, _cell_x, _cell_y) <= 0) return FACTION.NONE;
	return ds_grid_get(corruption_faction_grid, _cell_x, _cell_y);
};

corruption_protection_grid = ds_grid_create(grid_width, grid_height);
ds_grid_clear(corruption_protection_grid, 0);
corruption_protection_dirty = true;
corruption_protection_timer = 0;
corruption_protection_rebuild = function()
{
	ds_grid_clear(corruption_protection_grid, 0);
	var _groups = [o_map_objects_parent, o_v13buildings_parent];
	for (var _g = 0; _g < array_length(_groups); ++_g)
	{
		var _count = instance_number(_groups[_g]);
		for (var _i = 0; _i < _count; ++_i)
		{
			var _building = instance_find(_groups[_g], _i);
			if (!variable_instance_exists(_building, "corruption_protection_radius")) continue;
			var _owner = _building.faction;
			if (_owner < FACTION.ORDER || _owner > FACTION.NEUTRAL || faction_is_defeated(_owner)) continue;
			if (_building.hp <= 0 && !(variable_instance_exists(_building, "is_recovering") && _building.is_recovering)) continue;
			var _radius = _building.corruption_protection_radius;
			var _left = max(0, floor((_building.x - _radius) / cell_size));
			var _right = min(grid_width - 1, floor((_building.x + _radius) / cell_size));
			var _top = max(0, floor((_building.y - _radius) / cell_size));
			var _bottom = min(grid_height - 1, floor((_building.y + _radius) / cell_size));
			for (var _cx = _left; _cx <= _right; ++_cx)
			{
				for (var _cy = _top; _cy <= _bottom; ++_cy)
				{
					if (point_distance(_building.x, _building.y, (_cx + 0.5) * cell_size, (_cy + 0.5) * cell_size) > _radius) continue;
					ds_grid_set(corruption_protection_grid, _cx, _cy, ds_grid_get(corruption_protection_grid, _cx, _cy) | (1 << _owner));
				}
			}
		}
	}
	corruption_protection_dirty = false;
};
corruption_cell_is_protected = function(_cx, _cy, _faction)
{
	if (corruption_protection_dirty) corruption_protection_rebuild();
	return (ds_grid_get(corruption_protection_grid, _cx, _cy) & ~(1 << _faction)) != 0;
};
corruption_cell_apply = function(_cell_x, _cell_y, _amount, _faction, _limit = 1)
{
	if (_amount <= 0 || _faction < FACTION.ORDER || _faction > FACTION.WILDLINGS) return;
	if (defeated_factions[_faction] || corruption_cell_is_protected(_cell_x, _cell_y, _faction)) return;
	var _owner = ds_grid_get(corruption_faction_grid, _cell_x, _cell_y);
	var _current = _owner == _faction ? ds_grid_get(corruption_grid, _cell_x, _cell_y) : 0;
	ds_grid_set(corruption_faction_grid, _cell_x, _cell_y, _faction);
	ds_grid_set(corruption_grid, _cell_x, _cell_y, max(_current, min(_current + _amount, _limit)));
};

// Negative amounts cleanse; a positive application always replaces a different owner.
corrupt_circle = function(_center_x, _center_y, _radius, _amount, _faction = FACTION.UNDEAD)
{
	var _safe_radius = max(1, _radius);
	var _left = max(0, floor((_center_x - _safe_radius) / cell_size));
	var _right = min(grid_width - 1, floor((_center_x + _safe_radius) / cell_size));
	var _top = max(0, floor((_center_y - _safe_radius) / cell_size));
	var _bottom = min(grid_height - 1, floor((_center_y + _safe_radius) / cell_size));
	for (var _cx = _left; _cx <= _right; ++_cx)
	{
		for (var _cy = _top; _cy <= _bottom; ++_cy)
		{
			if (point_distance(_center_x, _center_y, (_cx + 0.5) * cell_size, (_cy + 0.5) * cell_size) > _safe_radius
				&& (_cx != floor(_center_x / cell_size) || _cy != floor(_center_y / cell_size))) continue;
			if (_amount >= 0)
			{
				corruption_cell_apply(_cx, _cy, _amount, _faction);
			}
			else
			{
				if (_faction != FACTION.NONE && corruption_cell_is_protected(_cx, _cy, _faction)) continue;
				var _remaining = max(0, ds_grid_get(corruption_grid, _cx, _cy) + _amount);
				ds_grid_set(corruption_grid, _cx, _cy, _remaining);
				if (_remaining <= 0) ds_grid_set(corruption_faction_grid, _cx, _cy, FACTION.NONE);
			}
		}
	}
};

// Legacy holy-source calls use the same faction ownership and building protection rules.
saint_source_circle_add = function(_x, _y, _radius, _faction = FACTION.ORDER)
{
	corrupt_circle(_x, _y, _radius, 1, _faction);
};
saint_source_circle_remove = function(_x, _y, _radius) {};
saint_circle_set = function(_x, _y, _radius, _amount, _faction = FACTION.ORDER)
{
	corrupt_circle(_x, _y, _radius, _amount, _faction);
};
saint_circle_clear = function(_x, _y, _radius) {};
cleanse_circle = function(_x, _y, _radius, _amount, _faction = FACTION.NONE)
{
	corrupt_circle(_x, _y, _radius, -max(0, _amount), _faction);
};
// Checks whether a world-space circle overlaps at least one visibly tainted cell.
circle_touches_corruption = function(_center_x, _center_y, _radius)
{
	var _safe_radius = max(_radius, 1);
	var _left_cell = clamp(floor((_center_x - _safe_radius) / cell_size), 0, grid_width - 1);
	var _right_cell = clamp(floor((_center_x + _safe_radius) / cell_size), 0, grid_width - 1);
	var _top_cell = clamp(floor((_center_y - _safe_radius) / cell_size), 0, grid_height - 1);
	var _bottom_cell = clamp(floor((_center_y + _safe_radius) / cell_size), 0, grid_height - 1);

	for (var _cell_x = _left_cell; _cell_x <= _right_cell; ++_cell_x)
	{
		for (var _cell_y = _top_cell; _cell_y <= _bottom_cell; ++_cell_y)
		{
			var _corruption = ds_grid_get(corruption_grid, _cell_x, _cell_y);
			var _saint = ds_grid_get(saint_grid, _cell_x, _cell_y);

			if (_corruption < minimum_draw_corruption || _saint >= minimum_draw_corruption)
			{
				continue;
			}

			// Test the circle against the nearest point of the cell rectangle.
			var _cell_left = _cell_x * cell_size;
			var _cell_top = _cell_y * cell_size;
			var _cell_right = _cell_left + cell_size;
			var _cell_bottom = _cell_top + cell_size;
			var _nearest_x = clamp(_center_x, _cell_left, _cell_right);
			var _nearest_y = clamp(_center_y, _cell_top, _cell_bottom);

			if (point_distance(_center_x, _center_y, _nearest_x, _nearest_y) <= _safe_radius)
			{
				return true;
			}
		}
	}

	return false;
};
