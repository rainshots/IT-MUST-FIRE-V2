/// @description Resolves a manual Cannon projectile at its landing point.
function cannonball_impact(_type, _x, _y)
{
	if (_type == CANNONBALL_TYPE.NECRO)
	{
		for (var _index = 0; _index < BALANCE_CANNON_BONELET_COUNT; ++_index)
		{
			var _angle = _index * 360 / BALANCE_CANNON_BONELET_COUNT;
			var _unit = instance_create_layer(_x + lengthdir_x(BALANCE_CANNON_BONELET_SPACING, _angle),
				_y + lengthdir_y(BALANCE_CANNON_BONELET_SPACING, _angle), "Instances", o_skeleton_bonelet);
			if (instance_exists(o_base_tower)) _unit.target_instance = instance_find(o_base_tower, 0);
		}
		return;
	}
	if (_type == CANNONBALL_TYPE.POISON)
	{
		instance_create_layer(_x, _y, "Instances", o_cannon_effect);
		return;
	}
	var _flash = instance_create_layer(_x, _y, "Instances", o_particle_explosion);
	_flash.end_radius = BALANCE_CANNON_BLAST_RADIUS;
	// Collect targets before damage destroys instances or creates visual effects.
	var _targets = [];
	with (all)
	{
		if (cannon_target_in_blast(id, _x, _y)) array_push(_targets, id);
	}
	for (var _index = 0; _index < array_length(_targets); ++_index)
	{
		var _target = _targets[_index];
		cannon_damage_apply(_target, _type == CANNONBALL_TYPE.FIRE ? BALANCE_CANNON_FIRE_DAMAGE : BALANCE_CANNON_NORMAL_DAMAGE);
		if (_type != CANNONBALL_TYPE.FIRE || !instance_exists(_target) || _target.hp <= 0) continue;
		var _burn = noone;
		with (o_cannon_effect)
		{
			if (effect_type == CANNONBALL_TYPE.FIRE && burn_target == _target) _burn = id;
		}
		if (!instance_exists(_burn)) _burn = instance_create_layer(_target.x, _target.y, "Instances", o_cannon_effect);
		_burn.effect_type = CANNONBALL_TYPE.FIRE;
		_burn.burn_target = _target;
		_burn.remaining_seconds = BALANCE_CANNON_BURN_SECONDS;
	}
}
