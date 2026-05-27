// Temporary summoned skeletons expire after their lifetime.
if (variable_instance_exists(id, "life_timer"))
{
	life_timer--;

	if (life_timer <= 0)
	{
		instance_destroy();
		exit;
	}
}

// Run shared unit behavior.
event_inherited();
