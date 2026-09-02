// Every unit owns at most one reusable path resource.
if (navigation_path != noone)
{
	path_delete(navigation_path);
	navigation_path = noone;
}

// Trait visuals never outlive their owning unit.
if (instance_exists(unholy_aura_instance))
{
	with (unholy_aura_instance)
	{
		instance_destroy();
	}
}
