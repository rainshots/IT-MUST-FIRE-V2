/// @description Resolves the squad credited for a unit, summoned helper, or projectile.
function squad_damage_source_get(_source)
{
	if (!instance_exists(_source))
	{
		return noone;
	}
	if (variable_instance_exists(_source, "squad") && is_struct(_source.squad))
	{
		return _source.squad;
	}
	if (variable_instance_exists(_source, "damage_credit_squad") && is_struct(_source.damage_credit_squad))
	{
		return _source.damage_credit_squad;
	}
	return noone;
}
