// Temporary summoned skeletons expire after their lifetime.
if (variable_instance_exists(id, "life_timer"))
{
	var _time_scale = variable_global_exists("gameplay_time_scale") ? global.gameplay_time_scale : 1;
	life_timer -= _time_scale;

	if (life_timer <= 0)
	{
		if (instance_exists(o_game_controller))
		{
			var _game_controller = instance_find(o_game_controller, 0);

			if (variable_instance_exists(_game_controller, "cannon_corpse_worker_drop"))
			{
				_game_controller.cannon_corpse_worker_drop(id);
			}
		}

		if (variable_instance_exists(id, "unit_corpse_snapshot_create"))
		{
			unit_corpse_snapshot_create();
		}

		if (variable_instance_exists(id, "unit_death_sound_play"))
		{
			unit_death_sound_play();
		}

		instance_destroy();
		exit;
	}
}

// Run shared unit behavior.
event_inherited();

if (unholy_savage_leap_active)
{
	exit;
}
