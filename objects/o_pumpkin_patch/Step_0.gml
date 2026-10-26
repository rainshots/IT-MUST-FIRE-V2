if (!placement_preview && !is_being_dragged && !starting_mines_planted && !global.pause)
{
	starting_mines_planted = true;
	for (var _i = 0; _i < BALANCE_PUMPKIN_START_MINES; ++_i) pumpkin_mine_spawn(id);
}
event_inherited();
