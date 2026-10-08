// The map starts explored; this grid tracks current faction visibility only.
depth = BALANCE_FOG_OF_WAR_DEPTH;
cell_size = BALANCE_GRID_CELL_SIZE;
grid_width = ceil(room_width / cell_size);
grid_height = ceil(room_height / cell_size);
hidden_state = FOG_STATE.HIDDEN; // Compatibility for callers; no cell enters this state.
explored_state = FOG_STATE.EXPLORED;
revealed_state = FOG_STATE.REVEALED;
fog_grid = ds_grid_create(grid_width, grid_height);
ds_grid_clear(fog_grid, explored_state);

// Unseen terrain is dimmed, never covered by opaque black fog.
explored_alpha = 0.5;
revealed_alpha = 0;
fog_color = c_black;
update_interval = max(1, room_speed * BALANCE_FACTION_VISION_UPDATE_SECONDS);
update_timer = update_interval;
vision_source_objects = [o_units_parent, o_v13buildings_parent, o_map_objects_parent];

// Reveal world-space circles directly, including areas far from the starting base.
fog_world_circle_reveal = function(_world_x, _world_y, _radius)
{
	if (_radius <= 0) return;
	var _left_cell = clamp(floor((_world_x - _radius) / cell_size), 0, grid_width - 1);
	var _right_cell = clamp(floor((_world_x + _radius) / cell_size), 0, grid_width - 1);
	var _top_cell = clamp(floor((_world_y - _radius) / cell_size), 0, grid_height - 1);
	var _bottom_cell = clamp(floor((_world_y + _radius) / cell_size), 0, grid_height - 1);
	var _center_cell_x = floor(_world_x / cell_size);
	var _center_cell_y = floor(_world_y / cell_size);
	var _radius_squared = _radius * _radius;
	for (var _cell_x = _left_cell; _cell_x <= _right_cell; ++_cell_x)
	{
		for (var _cell_y = _top_cell; _cell_y <= _bottom_cell; ++_cell_y)
		{
			var _distance_x = ((_cell_x + 0.5) * cell_size) - _world_x;
			var _distance_y = ((_cell_y + 0.5) * cell_size) - _world_y;
			var _distance_squared = (_distance_x * _distance_x) + (_distance_y * _distance_y);
			if (_distance_squared <= _radius_squared
				|| (_cell_x == _center_cell_x && _cell_y == _center_cell_y))
			{
				ds_grid_set(fog_grid, _cell_x, _cell_y, revealed_state);
			}
		}
	}
};

// Sight is current, so moving away or destroying a source removes its reveal.
fog_visibility_update = function()
{
	ds_grid_clear(fog_grid, explored_state);
	var _player_faction = global.player_faction;
	if (_player_faction == FACTION.NONE) return;
	var _object_count = array_length(vision_source_objects);
	for (var _object_index = 0; _object_index < _object_count; ++_object_index)
	{
		var _object = vision_source_objects[_object_index];
		var _source_count = instance_number(_object);
		for (var _source_index = 0; _source_index < _source_count; ++_source_index)
		{
			var _source = instance_find(_object, _source_index);
			if (!instance_exists(_source) || _source.faction != _player_faction) continue;
			// Captured buildings grant sight immediately, including their zero-HP recovery frame.
			var _recovering_building = _object != o_units_parent
				&& variable_instance_exists(_source, "is_recovering") && _source.is_recovering;
			if (_source.hp <= 0 && !_recovering_building)
			{
				continue;
			}
			// Carried or undeployed units do not scout from a temporary visual position.
			if ((variable_instance_exists(_source, "is_being_dragged") && _source.is_being_dragged)
				|| (variable_instance_exists(_source, "cannon_loaded") && _source.cannon_loaded)
				|| (variable_instance_exists(_source, "cultist_projectile_deploy_waiting")
					&& _source.cultist_projectile_deploy_waiting))
			{
				continue;
			}
			fog_world_circle_reveal(_source.x, _source.y, _source.vision_radius);
		}
	}
};

// Callers use this for enemy visibility and information that requires live sight.
fog_cell_is_seen = function(_world_x, _world_y)
{
	var _cell_x = floor(_world_x / cell_size);
	var _cell_y = floor(_world_y / cell_size);
	if (_cell_x < 0 || _cell_x >= grid_width || _cell_y < 0 || _cell_y >= grid_height)
	{
		return false;
	}
	return ds_grid_get(fog_grid, _cell_x, _cell_y) == revealed_state;
};
