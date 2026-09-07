// Release the optional RAID planning path as well as the normal movement path.
if (raid_assault_path != noone)
{
	path_delete(raid_assault_path);
	raid_assault_path = noone;
}

// Release the reusable movement path resource.
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
