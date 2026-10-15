/// @description Draws a shared progress bar beneath a staffed-work building; building context.
function building_work_progress_draw()
{
	if (!building_accepts_workers || placement_preview || is_being_dragged) return;
	if (!is_defense_building && object_index != o_furnace && !variable_instance_exists(id, "production_kind")) return;
	var _work = building_work_progress_get();
	var _width = BALANCE_BUILDING_WORK_BAR_WIDTH;
	var _height = BALANCE_BUILDING_WORK_BAR_HEIGHT;
	var _left = x - _width * 0.5;
	var _top = (is_defense_building ? y + placement_size * 0.5 : bbox_bottom) + BALANCE_BUILDING_WORK_BAR_OFFSET;
	draw_set_alpha(1);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_rectangle(_left, _top, _left + _width, _top + _height, false);
	draw_set_color(COLOR_PROJECTILE_SUMMON);
	draw_rectangle(_left, _top, _left + _width * _work.progress, _top + _height, false);
	draw_set_color(COLOR_HUD_TEXT);
	draw_rectangle(_left, _top, _left + _width, _top + _height, true);
	draw_set_halign(fa_center);
	draw_set_valign(fa_top);
	draw_text_transformed(x, _top + _height + 3, _work.status, 0.4, 0.4, 0);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
}
