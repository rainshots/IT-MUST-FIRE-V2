/// @description Rolls three distinct eligible permanent bonuses and pauses the new fight; controller context.
function fight_bonus_begin()
{
	var _pool = [FIGHT_BONUS.SQUAD, FIGHT_BONUS.AMMO, FIGHT_BONUS.CULTIST];
	if (!is_undefined(fight_bonus_building_position_get(o_forge))) array_push(_pool, FIGHT_BONUS.FORGE);
	if (!is_undefined(fight_bonus_building_position_get(o_furnace))) array_push(_pool, FIGHT_BONUS.FURNACE);
	if (!is_undefined(fight_bonus_building_position_get(o_cauldron))) array_push(_pool, FIGHT_BONUS.CAULDRON);
	if (!cannon_necro_unlocked) array_push(_pool, FIGHT_BONUS.NECRO);
	fight_bonus_options = [];
	for (var _index = 0; _index < BALANCE_BONUS_CHOICE_COUNT; ++_index)
	{
		var _choice = irandom(array_length(_pool) - 1);
		array_push(fight_bonus_options, _pool[_choice]);
		array_delete(_pool, _choice, 1);
	}
	fight_bonus_open = true;
	fight_bonus_wait_release = true;
	fight_bonus_notice = "";
	cannon_aiming = false;
	worker_hovered = noone;
	if (worker_cursor_hidden) window_set_cursor(cr_default);
	worker_cursor_hidden = false;
	global.pause = true;
}
