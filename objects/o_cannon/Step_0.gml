// Resolve lethal damage immediately, even on the charge-completion frame.
if (hp <= 0)
{
	if (instance_exists(o_game_controller))
	{
		o_game_controller.fight_state = FIGHT_STATE.LOST;
		global.pause = true;
	}
	instance_destroy();
}
