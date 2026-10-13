// Remove both sides of an assignment when a worker is destroyed or the room ends.
worker_release(id);
if (instance_exists(o_game_controller) && o_game_controller.worker_dragged == id)
{
	o_game_controller.worker_dragged = noone;
}
