/// @description Applies a corruption projectile impact to tombs and their graves.
/// @param {real} impact_x Impact world X coordinate.
/// @param {real} impact_y Impact world Y coordinate.
/// @param {real} impact_radius Explosion radius in pixels.
function tomb_corruption_impact_apply(_impact_x, _impact_y, _impact_radius)
{
	// Tombs are processed first so their initial graves stay inactive on this impact.
	var _object_types = [o_tomb_a, o_grave2];
	var _object_count = array_length(_object_types);
	var _hit_list = ds_list_create();
	for (var _object_index = 0; _object_index < _object_count; ++_object_index)
	{
		ds_list_clear(_hit_list);
		var _hit_count = collision_circle_list(_impact_x, _impact_y, _impact_radius,
			_object_types[_object_index], false, false, _hit_list, false);
		for (var _hit_index = 0; _hit_index < _hit_count; ++_hit_index)
		{
			var _target = _hit_list[| _hit_index];
			if (instance_exists(_target))
			{
				_target.on_projectile_hit(PROJECTILE_TYPE.CORRUPTION);
			}
		}
	}
	ds_list_destroy(_hit_list);
}
