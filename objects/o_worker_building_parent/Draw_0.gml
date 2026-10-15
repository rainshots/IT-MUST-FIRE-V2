// A future child supplies its sprite; this parent has no production-building appearance.
if (sprite_index != -1) draw_self();

if(building_label!="Building")
{
	draw_set_color(COLOR_HUD_TEXT);draw_set_halign(fa_center);draw_set_valign(fa_bottom);
	draw_text_transformed(x,bbox_top,building_label+"\n"+string(array_length(worker_cultists))+" / "+string(worker_max)+" workers",0.5,0.5,0);
	draw_set_halign(fa_left);draw_set_valign(fa_top);draw_set_color(c_white);
}

// Production children and the Furnace share actual progress and blocked-state feedback.
building_work_progress_draw();
