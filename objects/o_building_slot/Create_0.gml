// Empty slots become usable while the ground cell under their origin contains Taint.
is_active = false;
construction_event_pending = false; // Prevent duplicate construction cards for this slot.
sprite_index = s_building_slot_empty;
image_index = 0;
image_speed = 0;
mask_index = s_building_slot; // Keep interaction bounds stable when the sprite changes.

// Draw GUI explains how to activate an untainted slot when the cursor hovers over it.
tooltip_text = "Taint the ground under this point to build a building here.";
tooltip_width = 360;
tooltip_padding = 12;
tooltip_line_height = 18;
tooltip_cursor_offset = 18;
tooltip_background_alpha = 0.86;

// Read the current grid for both visual state and construction validation.
building_slot_is_active = function()
{
	if (!instance_exists(o_corruption_grid))
	{
		return false;
	}

	var _corruption_grid_object = instance_find(o_corruption_grid, 0);
	var _cell_x = floor(x / _corruption_grid_object.cell_size);
	var _cell_y = floor(y / _corruption_grid_object.cell_size);

	if (_cell_x < 0 || _cell_x >= _corruption_grid_object.grid_width
		|| _cell_y < 0 || _cell_y >= _corruption_grid_object.grid_height)
	{
		return false;
	}

	// Saint-covered ground cannot activate construction even if Taint remains in the grid.
	return ds_grid_get(_corruption_grid_object.corruption_grid, _cell_x, _cell_y) > 0
		&& ds_grid_get(_corruption_grid_object.saint_grid, _cell_x, _cell_y) <= 0;
};
