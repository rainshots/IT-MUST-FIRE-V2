// Free corruption grid memory.
if (ds_exists(corruption_grid, ds_type_grid))
{
	ds_grid_destroy(corruption_grid);
}

if (ds_exists(saint_grid, ds_type_grid))
{
	ds_grid_destroy(saint_grid);
}

if (ds_exists(saint_source_grid, ds_type_grid))
{
	ds_grid_destroy(saint_source_grid);
}
