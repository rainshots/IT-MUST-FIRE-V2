// Display staffing and rebuilding progress above the Foundry.
event_inherited();
var _text = "Foundry\n" + string(array_length(worker_cultists)) + "/" + string(worker_max) + " workers";
_text += "\nRepair: " + string(BALANCE_FIGHT_FOUNDRY_REPAIR_SHARE_PER_SECOND * 100) + "% HP / s";
if (instance_exists(o_game_controller) && !instance_exists(o_game_controller.fight_wall))
{
	_text += "\nRebuilding: " + string(floor(100 * rebuild_hp / (BALANCE_WALL_MAX_HP * BALANCE_FIGHT_WALL_START_HP_SHARE))) + "%";
}
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_set_alpha(1);
draw_set_color(COLOR_HUD_TEXT);
draw_text_transformed(x, bbox_top, _text, 0.5, 0.5, 0);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
