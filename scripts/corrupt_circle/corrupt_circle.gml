/// @description Applies source-owned corruption in a pixel-radius circle; later applications replace other factions.
function corrupt_circle(_center_x, _center_y, _radius, _amount, _faction = undefined)
{
	if (!instance_exists(o_corruption_grid)) return;
	if (is_undefined(_faction)) _faction = corruption_faction_get(id);
	var _grid = instance_find(o_corruption_grid, 0);
	_grid.corrupt_circle(_center_x, _center_y, _radius, _amount, _faction);
}
