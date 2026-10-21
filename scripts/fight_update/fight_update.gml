/// @description Runs the ten-fight progression; called once per controller Step.
function fight_update()
{
	if (fight_state == FIGHT_STATE.LOST || fight_state == FIGHT_STATE.WON) return;
	if (!fight_initialized) fight_start();
	// Losing the Heart takes priority over clearing the enemy objective.
	if (!instance_exists(o_heart) || o_heart.hp <= 0)
	{
		fight_state = FIGHT_STATE.LOST;
		global.pause = true;
		return;
	}
	if (fight_state == FIGHT_STATE.CLEARED)
	{
		global.pause = true;
		if (global.focus_window != FOCUS_WINDOW.NOONE) return;
		var _rect = fight_move_on_rect_get();
		if (mouse_check_button_pressed(mb_left)
			&& point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0),
				_rect.x, _rect.y, _rect.x + _rect.width, _rect.y + _rect.height))
		{
			fight_start();
		}
		return;
	}
	if (fight_bonus_open)
	{
		global.pause = true;
		return;
	}
	if (global.pause) return;
	enemy_zone_corruption_update();
	fight_elapsed_seconds += global.gameplay_time_scale / max(1, room_speed);
	if (!instance_exists(o_base_tower) || o_base_tower.hp <= 0)
	{
		fight_complete();
		return;
	}
	if (BALANCE_ENEMY_SPAWNS_ENABLED && fight_elapsed_seconds >= fight_next_wave_seconds)
	{
		fight_wave_spawn();
	}
}
