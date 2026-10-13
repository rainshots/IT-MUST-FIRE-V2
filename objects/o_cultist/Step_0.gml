// Civilian updates stop with gameplay pause.
if (global.pause) exit;
if (hp <= 0)
{
	instance_destroy();
	exit;
}
is_walking = false;
if (is_assigned_to_building && !instance_exists(assigned_building))
{
	is_assigned_to_building = false;
	assigned_building = noone;
}

// Buildings own work ticks; unassigned civilians wander around the Cannon.
if (is_assigned_to_building) exit;
if (!is_being_dragged && instance_exists(o_game_controller))
{
	o_game_controller.worker_idle_wander_update(id);
}
