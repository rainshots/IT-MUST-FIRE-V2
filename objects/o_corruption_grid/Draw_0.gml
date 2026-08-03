// Skip drawing if the camera is not ready yet.
if (!instance_exists(o_camera_controller))
{
	exit;
}

var _camera_controller = instance_find(o_camera_controller, 0);
var _camera_x = camera_get_view_x(_camera_controller.camera_id);
var _camera_y = camera_get_view_y(_camera_controller.camera_id);
var _camera_width = camera_get_view_width(_camera_controller.camera_id);
var _camera_height = camera_get_view_height(_camera_controller.camera_id);
var _left_cell = clamp(floor(_camera_x / cell_size), 0, grid_width - 1);
var _right_cell = clamp(floor((_camera_x + _camera_width) / cell_size), 0, grid_width - 1);
var _top_cell = clamp(floor(_camera_y / cell_size), 0, grid_height - 1);
var _bottom_cell = clamp(floor((_camera_y + _camera_height) / cell_size), 0, grid_height - 1);

// Draw only cells visible inside the current camera view.
for (var _cell_x = _left_cell; _cell_x <= _right_cell; ++_cell_x)
{
	for (var _cell_y = _top_cell; _cell_y <= _bottom_cell; ++_cell_y)
	{
		var _corruption = ds_grid_get(corruption_grid, _cell_x, _cell_y);
		var _saint = ds_grid_get(saint_grid, _cell_x, _cell_y);
		var _is_corrupted = _corruption >= minimum_draw_corruption && _saint < minimum_draw_corruption;

		if (_is_corrupted)
		{
			var _draw_x = _cell_x * cell_size;
			var _draw_y = _cell_y * cell_size;

			draw_set_color(maximum_corruption_color);
			draw_set_alpha(maximum_corruption_alpha);
			draw_rectangle(_draw_x, _draw_y, _draw_x + cell_size, _draw_y + cell_size, false);
		}

		if (_saint >= minimum_draw_corruption)
		{
			var _saint_draw_x = _cell_x * cell_size;
			var _saint_draw_y = _cell_y * cell_size;
			var _saint_cell_color = merge_colour(uncorrupted_color, maximum_saint_color, _saint);
			var _saint_cell_alpha = lerp(minimum_corruption_alpha, maximum_saint_alpha, _saint);

			draw_set_color(_saint_cell_color);
			draw_set_alpha(_saint_cell_alpha);
			draw_rectangle(_saint_draw_x, _saint_draw_y, _saint_draw_x + cell_size, _saint_draw_y + cell_size, false);
		}
	}
}

// Draw blood lines only along visible outer edges of corrupted ground.
var _blood_line_scale = cell_size / sprite_get_height(s_blood_line);

draw_set_color(c_white);
draw_set_alpha(1);

for (var _edge_cell_x = _left_cell; _edge_cell_x <= _right_cell; ++_edge_cell_x)
{
	for (var _edge_cell_y = _top_cell; _edge_cell_y <= _bottom_cell; ++_edge_cell_y)
	{
		var _edge_corruption = ds_grid_get(corruption_grid, _edge_cell_x, _edge_cell_y);
		var _edge_saint = ds_grid_get(saint_grid, _edge_cell_x, _edge_cell_y);
		var _is_edge_cell_corrupted = _edge_corruption >= minimum_draw_corruption
			&& _edge_saint < minimum_draw_corruption;

		if (!_is_edge_cell_corrupted)
		{
			continue;
		}

		var _edge_x = _edge_cell_x * cell_size;
		var _edge_y = _edge_cell_y * cell_size;
		var _has_top_neighbor = false;
		var _has_right_neighbor = false;
		var _has_bottom_neighbor = false;
		var _has_left_neighbor = false;

		// Check whether each side touches another visibly corrupted cell.
		if (_edge_cell_y > 0)
		{
			var _top_corruption = ds_grid_get(corruption_grid, _edge_cell_x, _edge_cell_y - 1);
			var _top_saint = ds_grid_get(saint_grid, _edge_cell_x, _edge_cell_y - 1);
			_has_top_neighbor = _top_corruption >= minimum_draw_corruption
				&& _top_saint < minimum_draw_corruption;
		}

		if (_edge_cell_x < grid_width - 1)
		{
			var _right_corruption = ds_grid_get(corruption_grid, _edge_cell_x + 1, _edge_cell_y);
			var _right_saint = ds_grid_get(saint_grid, _edge_cell_x + 1, _edge_cell_y);
			_has_right_neighbor = _right_corruption >= minimum_draw_corruption
				&& _right_saint < minimum_draw_corruption;
		}

		if (_edge_cell_y < grid_height - 1)
		{
			var _bottom_corruption = ds_grid_get(corruption_grid, _edge_cell_x, _edge_cell_y + 1);
			var _bottom_saint = ds_grid_get(saint_grid, _edge_cell_x, _edge_cell_y + 1);
			_has_bottom_neighbor = _bottom_corruption >= minimum_draw_corruption
				&& _bottom_saint < minimum_draw_corruption;
		}

		if (_edge_cell_x > 0)
		{
			var _left_corruption = ds_grid_get(corruption_grid, _edge_cell_x - 1, _edge_cell_y);
			var _left_saint = ds_grid_get(saint_grid, _edge_cell_x - 1, _edge_cell_y);
			_has_left_neighbor = _left_corruption >= minimum_draw_corruption
				&& _left_saint < minimum_draw_corruption;
		}

		// The source sprite is authored as a right edge; rotate it around its edge origin.
		if (!_has_top_neighbor)
		{
			draw_sprite_ext(s_blood_line, 0, _edge_x, _edge_y, _blood_line_scale, _blood_line_scale, 90, c_white, 1);
		}

		if (!_has_right_neighbor)
		{
			draw_sprite_ext(s_blood_line, 0, _edge_x + cell_size, _edge_y, _blood_line_scale, _blood_line_scale, 0, c_white, 1);
		}

		if (!_has_bottom_neighbor)
		{
			draw_sprite_ext(s_blood_line, 0, _edge_x + cell_size, _edge_y + cell_size, _blood_line_scale, _blood_line_scale, 270, c_white, 1);
		}

		if (!_has_left_neighbor)
		{
			draw_sprite_ext(s_blood_line, 0, _edge_x, _edge_y + cell_size, _blood_line_scale, _blood_line_scale, 180, c_white, 1);
		}
	}
}

// Captured map buildings draw ground rifts toward the cannon under world assets.
captured_building_rifts_draw();

// Restore default draw state.
draw_set_color(c_white);
draw_set_alpha(1);
