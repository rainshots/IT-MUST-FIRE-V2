/// @description Tests living damageable targets against the blast, including large structures.
function cannon_target_in_blast(_target, _x, _y)
{
	if (!instance_exists(_target) || !variable_instance_exists(_target, "hp") || _target.hp <= 0) return false;
	var _px = _target.x;
	var _py = _target.y;
	if (!object_is_ancestor(_target.object_index, o_units_parent) && _target.sprite_index != -1)
	{
		_px = clamp(_x, _target.bbox_left, _target.bbox_right);
		_py = clamp(_y, _target.bbox_top, _target.bbox_bottom);
	}
	return point_distance(_x, _y, _px, _py) <= BALANCE_CANNON_BLAST_RADIUS;
}
