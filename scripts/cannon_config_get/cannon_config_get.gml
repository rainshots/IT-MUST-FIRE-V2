/// @description Gets active cannon settings, including during room Create event initialization.
function cannon_config_get()
{
	// Prefer the live Cannon so UI and events follow its identity.
	if (instance_exists(o_cannon))
	{
		var _cannon = instance_find(o_cannon, 0);
		if (variable_instance_exists(_cannon, "cannon_config"))
		{
			return _cannon.cannon_config;
		}
	}

	if (instance_exists(o_game_controller))
	{
		var _controller = instance_find(o_game_controller, 0);
		if (variable_instance_exists(_controller, "cannon_config"))
		{
			return _controller.cannon_config;
		}
	}

	// Rooms can create the Cannon before the controller.
	return cannon_config_create(DEFAULT_CANNON);
}
