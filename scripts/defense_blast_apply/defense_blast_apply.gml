/// @description Damages living enemies inside a defense explosion.
function defense_blast_apply(_x, _y, _radius, _damage)
{
	var _flash = instance_create_layer(_x, _y, "Instances", o_defense_projectile);
	_flash.exploded = true;
	_flash.blast_radius = _radius;
	_flash.remaining_seconds = BALANCE_DEFENSE_BLAST_VISUAL_SECONDS;
	var _targets = [];
	with (o_enemy_units)
	{
		if (hp > 0 && point_distance(x, y, _x, _y) <= _radius) array_push(_targets, id);
	}
	for (var _i = 0; _i < array_length(_targets); ++_i) cannon_damage_apply(_targets[_i], _damage);
}
