/// @description Applies neutral Cannon damage to a living damageable unit or object.
function cannon_damage_apply(_target, _damage)
{
	if (!instance_exists(_target) || !variable_instance_exists(_target, "hp") || _target.hp <= 0) return;
	if (variable_instance_exists(_target, "unit_damage_receive"))
		_target.unit_damage_receive(_damage, UNIT_FACTION.NOONE);
	else _target.hp = max(0, _target.hp - _damage);
}
