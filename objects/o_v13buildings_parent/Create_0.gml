// Base production building state.
production_resource = noone;
production_resource_name = "";
production_resource_icon = noone;
production_resource_color = c_white;
production_bonus_stat = noone;
production_bonus_stat_name = "";
production_bonus_stat_color = COLOR_HUD_TEXT;
production_progress = 0;
production_duration = BALANCE_RESOURCE_BUILDING_PRODUCTION_TIME;
production_amount = BALANCE_RESOURCE_BUILDING_PRODUCTION_AMOUNT;
production_speed_multiplier = 0;
building_accepts_workers = false;
summon_unit_object = noone;
summon_progress = 0;
summon_duration = 0;
summon_has_paid_cost = false;
worker_cultists = array_create(0);
worker_max = BALANCE_RESOURCE_BUILDING_WORKER_MAX;
worker_stand_offset_y = 12;
worker_stand_spacing = 36;
y_sort_enabled = true;

// Production bar visual settings.
production_bar_width = 62;
production_bar_height = 6;
production_bar_offset_y = 125;
production_bar_outline_alpha = 0.85;
production_bar_background_alpha = 0.72;
production_icon_size = 18;
production_icon_gap = 8;
production_multiplier_gap = 10;
assignment_preview_padding = 5;
assignment_preview_alpha = 0.22;
assignment_preview_outline_alpha = 0.95;
production_tooltip_padding = 8;
production_tooltip_line_height = 16;
production_tooltip_width = 270;
production_tooltip_offset_y = 148;
building_tooltip_title = "";
building_tooltip_description = "";
building_tooltip_detail = "";
building_tooltip_detail_color = COLOR_HUD_TEXT;

// Meat Bath stores paid healing here so one Flesh restores a fixed amount over time.
meat_bath_heal_pool = 0;

// Ritual Circle stores paid base XP here before applying XP Gain to workers.
ritual_circle_exp_pool = 0;

// Configure the first resource production buildings by object type.
if (object_index == o_slaughter_table)
{
	building_accepts_workers = true;
	production_resource = RESOURCES.FLESH;
	production_resource_name = "Flesh";
	production_resource_icon = s_flesh_icon;
	production_resource_color = COLOR_HUD_FLESH;
	production_bonus_stat = CULTIST_STAT.FERVOR;
	production_bonus_stat_name = "FERVOR";
	production_bonus_stat_color = COLOR_CULTIST_FERVOR;
	building_tooltip_title = "Production";
	building_tooltip_description = "Produces Flesh";
	building_tooltip_detail = "Bonus: " + production_bonus_stat_name + " +" + string(BALANCE_RESOURCE_BUILDING_STAT_SPEED_BONUS) + "x per point";
	building_tooltip_detail_color = production_bonus_stat_color;
}
else if (object_index == o_quarry)
{
	building_accepts_workers = true;
	production_resource = RESOURCES.IRON;
	production_resource_name = "Iron";
	production_resource_icon = s_iron_icon;
	production_resource_color = COLOR_HUD_IRON;
	production_bonus_stat = CULTIST_STAT.BODY;
	production_bonus_stat_name = "BODY";
	production_bonus_stat_color = COLOR_CULTIST_BODY;
	building_tooltip_title = "Production";
	building_tooltip_description = "Produces Iron";
	building_tooltip_detail = "Bonus: " + production_bonus_stat_name + " +" + string(BALANCE_RESOURCE_BUILDING_STAT_SPEED_BONUS) + "x per point";
	building_tooltip_detail_color = production_bonus_stat_color;
}
else if (object_index == o_souls_well)
{
	building_accepts_workers = true;
	production_resource = RESOURCES.SOULS;
	production_resource_name = "Souls";
	production_resource_icon = s_soul_icon;
	production_resource_color = COLOR_HUD_SOULS;
	production_bonus_stat = CULTIST_STAT.SPIRIT;
	production_bonus_stat_name = "SPIRIT";
	production_bonus_stat_color = COLOR_CULTIST_SPIRIT;
	building_tooltip_title = "Production";
	building_tooltip_description = "Produces Souls";
	building_tooltip_detail = "Bonus: " + production_bonus_stat_name + " +" + string(BALANCE_RESOURCE_BUILDING_STAT_SPEED_BONUS) + "x per point";
	building_tooltip_detail_color = production_bonus_stat_color;
}
else if (object_index == o_meat_bath)
{
	building_accepts_workers = true;
	production_resource_icon = s_flesh_icon;
	production_resource_color = COLOR_HUD_FLESH;
	building_tooltip_title = "Healing";
	building_tooltip_description = "Heals assigned cultists";
	building_tooltip_detail = "Uses 1 Flesh for " + string(BALANCE_MEAT_BATH_FLESH_HEAL_AMOUNT) + " HP";
	building_tooltip_detail_color = COLOR_HUD_FLESH;
}
else if (object_index == o_ritual_circle)
{
	building_accepts_workers = true;
	production_resource_icon = s_soul_icon;
	production_resource_color = COLOR_HUD_SOULS;
	building_tooltip_title = "Training";
	building_tooltip_description = "Gives assigned cultists XP";
	building_tooltip_detail = "Uses 1 Soul for " + string(BALANCE_RITUAL_CIRCLE_SOUL_EXP_AMOUNT) + " XP";
	building_tooltip_detail_color = COLOR_HUD_SOULS;
}
else if (object_index == o_graveyardv13)
{
	building_accepts_workers = true;
	production_resource_icon = s_soul_icon;
	production_resource_color = COLOR_HUD_SOULS;
	production_bonus_stat = CULTIST_STAT.SPIRIT;
	production_bonus_stat_name = "SPIRIT";
	production_bonus_stat_color = COLOR_CULTIST_SPIRIT;
	summon_unit_object = o_skeleton;
	summon_duration = BALANCE_GRAVEYARD_SKELETON_PRODUCTION_TIME;
	building_tooltip_title = "Summoning";
	building_tooltip_description = "Summons Skeletons";
	building_tooltip_detail = "Bonus: " + production_bonus_stat_name + " +" + string(BALANCE_RESOURCE_BUILDING_STAT_SPEED_BONUS) + "x per point";
	building_tooltip_detail_color = production_bonus_stat_color;
}
else if (object_index == o_hell_pit)
{
	building_accepts_workers = true;
	production_resource_icon = s_soul_icon;
	production_resource_color = COLOR_HUD_SOULS;
	production_bonus_stat = CULTIST_STAT.FERVOR;
	production_bonus_stat_name = "FERVOR";
	production_bonus_stat_color = COLOR_CULTIST_FERVOR;
	summon_unit_object = o_pitling;
	summon_duration = BALANCE_HELL_PIT_PITLING_PRODUCTION_TIME;
	building_tooltip_title = "Summoning";
	building_tooltip_description = "Summons Pitlings";
	building_tooltip_detail = "Bonus: " + production_bonus_stat_name + " +" + string(BALANCE_RESOURCE_BUILDING_STAT_SPEED_BONUS) + "x per point";
	building_tooltip_detail_color = production_bonus_stat_color;
}

recalculate_production_speed_multiplier = function()
{
	var _total_speed_multiplier = 0;
	var _worker_count = array_length(worker_cultists);

	for (var _worker_index = 0; _worker_index < _worker_count; ++_worker_index)
	{
		var _worker = worker_cultists[_worker_index];

		if (!instance_exists(_worker) || _worker.object_index != o_cultist)
		{
			continue;
		}

		var _worker_speed_multiplier = 1;

		if (production_bonus_stat != noone && variable_instance_exists(_worker, "cultist_points"))
		{
			var _stat_points = _worker.cultist_points[production_bonus_stat];
			_worker_speed_multiplier += _stat_points * BALANCE_RESOURCE_BUILDING_STAT_SPEED_BONUS;
		}

		_total_speed_multiplier += _worker_speed_multiplier;
	}

	production_speed_multiplier = _total_speed_multiplier * BALANCE_RESOURCE_BUILDING_PRODUCTION_SPEED_MULTIPLIER;
};
