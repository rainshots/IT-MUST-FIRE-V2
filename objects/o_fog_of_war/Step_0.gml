// Fog updates faster only while dragging a demon so placement checks use the current revealed area.
fog_taint_reveal_cache_scan_update();
fog_starting_taint_reveal_cache_update();

var _dragged_demon_exists = instance_exists(global.dragged_cultist)
	&& variable_instance_exists(global.dragged_cultist, "demon_type")
	&& global.dragged_cultist.demon_type != DEMON_TYPE.NONE
	&& global.dragged_cultist.object_index != o_cultist;
var _update_interval = update_interval;

if (_dragged_demon_exists)
{
	_update_interval = 1;
}

update_timer++;

if (update_timer < _update_interval)
{
	exit;
}

update_timer = 0;

// Fog depends on the corruption grid, so keep all cells hidden until the grid exists.
ds_grid_clear(fog_grid, hidden_alpha);
revealed_cell_xs = [];
revealed_cell_ys = [];

if (!instance_exists(o_corruption_grid))
{
	exit;
}

// Cached fully corrupted cells reveal nearby fog in a circular cell radius.
var _taint_reveal_cell_count = array_length(taint_reveal_cell_xs);

for (var _taint_reveal_cell_index = 0; _taint_reveal_cell_index < _taint_reveal_cell_count; ++_taint_reveal_cell_index)
{
	fog_circle_reveal(
		taint_reveal_cell_xs[_taint_reveal_cell_index],
		taint_reveal_cell_ys[_taint_reveal_cell_index],
		reveal_radius_in_cells
	);
}

// Combat demon fog reveal is disabled while any demon is being dragged.
if (global.day_phase == DAY_PHASE.NIGHT && demon_reveal_radius_in_cells > 0 && !_dragged_demon_exists)
{
	var _friendly_count = instance_number(o_friendly_units);

	for (var _friendly_index = 0; _friendly_index < _friendly_count; ++_friendly_index)
	{
		var _friendly_unit = instance_find(o_friendly_units, _friendly_index);
		var _is_combat_demon = instance_exists(_friendly_unit)
			&& variable_instance_exists(_friendly_unit, "demon_type")
			&& _friendly_unit.demon_type != DEMON_TYPE.NONE
			&& (!variable_instance_exists(_friendly_unit, "hp") || _friendly_unit.hp > 0);
		var _can_reveal_fog = _is_combat_demon
			&& (!variable_instance_exists(_friendly_unit, "is_being_dragged") || !_friendly_unit.is_being_dragged);

		if (_can_reveal_fog)
		{
			var _demon_cell_x = floor(_friendly_unit.x / cell_size);
			var _demon_cell_y = floor(_friendly_unit.y / cell_size);
			var _is_inside_grid = _demon_cell_x >= 0
				&& _demon_cell_x < grid_width
				&& _demon_cell_y >= 0
				&& _demon_cell_y < grid_height;

			if (_is_inside_grid)
			{
				fog_circle_reveal(_demon_cell_x, _demon_cell_y, demon_reveal_radius_in_cells);
			}
		}
	}
}

// Captured vision towers reveal a wide circle around themselves.
if (instance_exists(o_tower_vision))
{
	var _vision_tower_count = instance_number(o_tower_vision);

	for (var _vision_tower_index = 0; _vision_tower_index < _vision_tower_count; ++_vision_tower_index)
	{
		var _vision_tower = instance_find(o_tower_vision, _vision_tower_index);
		var _tower_reveals_fog = instance_exists(_vision_tower)
			&& variable_instance_exists(_vision_tower, "is_captured")
			&& _vision_tower.is_captured;

		if (_tower_reveals_fog)
		{
			var _tower_radius = BALANCE_TOWER_VISION_RADIUS;

			if (variable_instance_exists(_vision_tower, "vision_radius"))
			{
				_tower_radius = _vision_tower.vision_radius;
			}

			var _tower_cell_x = floor(_vision_tower.x / cell_size);
			var _tower_cell_y = floor(_vision_tower.y / cell_size);
			var _tower_radius_in_cells = ceil(_tower_radius / cell_size);
			var _is_inside_grid = _tower_cell_x >= 0
				&& _tower_cell_x < grid_width
				&& _tower_cell_y >= 0
				&& _tower_cell_y < grid_height;

			if (_is_inside_grid)
			{
				fog_circle_reveal(_tower_cell_x, _tower_cell_y, _tower_radius_in_cells);
			}
		}
	}
}

// Once the player has seen an enemy tower, reveal a tiny area around it.
if (enemy_tower_reveal_radius > 0 && instance_exists(o_holy_tower))
{
	var _holy_tower_count = instance_number(o_holy_tower);

	for (var _holy_tower_index = 0; _holy_tower_index < _holy_tower_count; ++_holy_tower_index)
	{
		var _holy_tower = instance_find(o_holy_tower, _holy_tower_index);
		var _tower_can_reveal = instance_exists(_holy_tower)
			&& (!variable_instance_exists(_holy_tower, "hp") || _holy_tower.hp > 0)
			&& fog_cell_is_seen(_holy_tower.x, _holy_tower.y);

		if (_tower_can_reveal)
		{
			fog_world_circle_reveal(_holy_tower.x, _holy_tower.y, enemy_tower_reveal_radius);
		}
	}
}

// Revealed cells soften the edge by turning directly neighboring hidden cells into half-transparent fog.
var _revealed_cell_count = array_length(revealed_cell_xs);

for (var _revealed_cell_index = 0; _revealed_cell_index < _revealed_cell_count; ++_revealed_cell_index)
{
	var _cell_x = revealed_cell_xs[_revealed_cell_index];
	var _cell_y = revealed_cell_ys[_revealed_cell_index];

	for (var _offset_x = neighbor_offset_min; _offset_x <= neighbor_offset_max; ++_offset_x)
	{
		for (var _offset_y = neighbor_offset_min; _offset_y <= neighbor_offset_max; ++_offset_y)
		{
			var _is_current_cell = (_offset_x == 0 && _offset_y == 0);

			if (!_is_current_cell)
			{
				var _target_cell_x = _cell_x + _offset_x;
				var _target_cell_y = _cell_y + _offset_y;
				var _is_inside_grid = (
					_target_cell_x >= 0
					&& _target_cell_x < grid_width
					&& _target_cell_y >= 0
					&& _target_cell_y < grid_height
				);

				if (_is_inside_grid)
				{
					var _target_fog_alpha = ds_grid_get(fog_grid, _target_cell_x, _target_cell_y);

					if (_target_fog_alpha == hidden_alpha)
					{
						ds_grid_set(fog_grid, _target_cell_x, _target_cell_y, edge_alpha);
					}
				}
			}
		}
	}
}
