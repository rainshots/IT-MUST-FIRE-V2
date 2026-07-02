// HUD layout in GUI coordinates.
hud_margin_x = 18;
hud_margin_y = 16;
hud_sidebar_width = 431;
resource_item_width = 150;
resource_item_height = 34;
resource_item_gap = 10;
resource_icon_radius = 8;
resource_icon_size = 22;
resource_icon_text_gap = 12;
resource_text_padding = 20;
resource_sidebar_y = 48;
resource_sidebar_icon_size = 30;
resource_sidebar_first_icon_offset_x = 34;
resource_sidebar_item_gap = 94;
resource_sidebar_value_offset_x = 36;

// Cannon HP follows the wide bottom-bar concept from the HUD design.
cannon_hp_bar_width_share = 0.31875;
cannon_hp_fill_height_share = 0.0236;
cannon_hp_background_height_share = 0.01205;
cannon_hp_bottom_margin_share = 0.0185;
cannon_hp_background_offset_share = 0.006;
cannon_hp_label = "CANNON HP";
cannon_hp_label_scale = 0.5;

// First night prompt nudges the player to select the starting cultist projectile.
first_night_cultist_prompt_text = "PRESS 1";
first_night_cultist_aim_prompt_text = "AIM AND PRESS LMB";
first_night_cultist_prompt_scale = 3;
first_night_cultist_prompt_shadow_offset = 4;

// Day cycle and shrine objective display in the top-right corner.
day_phase_text_offset_x = 85;
day_phase_text_y = 83;
day_phase_bar_offset_x = 47;
day_phase_bar_y = 120;
day_phase_bar_width = 336;
day_phase_bar_height = 35;
day_phase_objective_y = 1027;
shrine_icon_size = 30;
shrine_icon_gap = 8;
shrine_icon_y_offset = 55;

// Crusade warning appears during the day when Taint has triggered next-night raids.
crusade_warning_y = 632;
crusade_warning_scale = 0.82;
crusade_warning_padding_x = 12;
crusade_warning_padding_y = 7;
crusade_warning_background_alpha = 0.78;

// Player unit counter is pinned just left of the right HUD sidebar.
unit_counter_width = 96;
unit_counter_row_height = 38;
unit_counter_gap_right = 10;
unit_counter_y = 82;
unit_counter_padding = 8;
unit_counter_row_gap = 6;
unit_counter_icon_size = 26;
unit_counter_background_alpha = 0.68;
unit_counter_row_alpha = 0.26;
unit_counter_empty_alpha = 0.36;
unit_counter_unit_objects = [
	o_cultist,
	o_imp,
	o_brute,
	o_warlock,
	o_skeleton,
	o_pitling,
	o_goblin
];
unit_counter_unit_sprites = [
	s_cultist_01,
	s_imp,
	s_brute,
	s_warlock,
	s_skeleton,
	s_demon,
	s_goblin
];

// Compact cultist status cards shown when no focus window is open.
cultist_status_card_width = 334;
cultist_status_card_height = 152;
cultist_status_card_margin_right = 48;
cultist_status_card_y = 126;
cultist_status_card_gap = 18;
cultist_status_card_slot_count = 3;
cultist_status_card_padding_x = 24;
cultist_status_card_portrait_width = 64;
cultist_status_card_portrait_height = 90;
cultist_status_card_portrait_y = 26;
cultist_status_card_level_y = 112;
cultist_status_card_text_x = 110;
cultist_status_card_name_y = 20;
cultist_status_card_name_max_characters = 14;
cultist_status_card_bar_x = 110;
cultist_status_card_bar_y = 55;
cultist_status_card_bar_width = 130;
cultist_status_card_bar_height = 18;
cultist_status_card_bar_gap = 8;
cultist_status_card_label_gap = 7;
cultist_status_card_background_alpha = 0.3;
cultist_status_card_bar_background_color = c_black;
cultist_status_card_hp_color = COLOR_HUD_CULTIST_STATUS_HP;
cultist_status_card_exp_color = COLOR_HUD_CULTIST_STATUS_EXP;
cultist_status_card_stamina_color = COLOR_HUD_CULTIST_STATUS_STAMINA;
cultist_status_card_label_color = COLOR_HUD_TEXT;

cultist_status_card_rect_get = function(_card_index)
{
	var _gui_width = display_get_gui_width();
	var _gui_height = display_get_gui_height();
	var _card_scale = clamp(_gui_height / 1080, 0.6, 1);
	var _sidebar_width = hud_sidebar_width * _card_scale;
	var _sidebar_x = _gui_width - _sidebar_width;
	var _card_width = cultist_status_card_width * _card_scale;
	var _card_height = cultist_status_card_height * _card_scale;
	var _card_gap = cultist_status_card_gap * _card_scale;
	var _card_x = _sidebar_x + ((_sidebar_width - _card_width) * 0.5);
	var _card_y = cultist_status_card_y + ((_card_height + _card_gap) * _card_index);

	return [_card_x, _card_y, _card_width, _card_height];
};

cultist_status_card_find_at_gui = function(_mouse_x, _mouse_y)
{
	if (!variable_global_exists("cultists")
		|| !variable_global_exists("focus_window")
		|| global.focus_window != FOCUS_WINDOW.NOONE
		|| (variable_global_exists("tutorial_popup_active") && global.tutorial_popup_active))
	{
		return noone;
	}

	var _gui_height = display_get_gui_height();
	var _cultist_count = array_length(global.cultists);
	var _slot_count = min(cultist_status_card_slot_count, _cultist_count);

	for (var _card_index = 0; _card_index < _slot_count; ++_card_index)
	{
		var _card_rect = cultist_status_card_rect_get(_card_index);
		var _card_x = _card_rect[0];
		var _card_y = _card_rect[1];
		var _card_width = _card_rect[2];
		var _card_height = _card_rect[3];

		if (_card_y + _card_height > _gui_height - hud_margin_y)
		{
			break;
		}

		if (_mouse_x >= _card_x
			&& _mouse_x <= _card_x + _card_width
			&& _mouse_y >= _card_y
			&& _mouse_y <= _card_y + _card_height)
		{
			var _cultist = global.cultists[_card_index];

			if (instance_exists(_cultist))
			{
				return _cultist;
			}
		}
	}

	return noone;
};

// Minimap mirrors the current battle around the cannon in the right HUD sidebar.
minimap_size = 334;
minimap_margin_right = 48;
minimap_y = 683;
minimap_world_radius = 5600;
minimap_base_size = 74;
minimap_enemy_size = 11;
minimap_cultist_width = 24;
minimap_cultist_height = 36;
minimap_cultist_bar_width = 19;
minimap_cultist_bar_height = 7;
minimap_cultist_bar_gap = 2;
minimap_shrine_size = 24;
minimap_shrine_outline_size = 30;
minimap_view_alpha = 0.2;
minimap_view_border_width = 4;
minimap_view_min_size = 10;
minimap_ground_update_interval = 15;
minimap_ground_update_timer = minimap_ground_update_interval;
minimap_ground_cell_xs = [];
minimap_ground_cell_ys = [];
minimap_ground_amounts = [];
minimap_ground_is_saint = [];

minimap_geometry_get = function()
{
	if (!instance_exists(o_cannon))
	{
		return noone;
	}

	var _gui_width = display_get_gui_width();
	var _gui_height = display_get_gui_height();
	var _minimap_scale = clamp(_gui_height / 1080, 0.6, 1);
	var _sidebar_width = hud_sidebar_width * _minimap_scale;
	var _sidebar_x = _gui_width - _sidebar_width;
	var _minimap_size = minimap_size * _minimap_scale;
	var _minimap_x = _sidebar_x + ((_sidebar_width - _minimap_size) * 0.5);
	var _minimap_y = minimap_y * _minimap_scale;
	var _minimap_cannon = instance_find(o_cannon, 0);

	return {
		x: _minimap_x,
		y: _minimap_y,
		right: _minimap_x + _minimap_size,
		bottom: _minimap_y + _minimap_size,
		center_x: _minimap_x + (_minimap_size * 0.5),
		center_y: _minimap_y + (_minimap_size * 0.5),
		size: _minimap_size,
		scale: _minimap_scale,
		world_center_x: _minimap_cannon.x,
		world_center_y: _minimap_cannon.y,
		world_to_minimap_scale: (_minimap_size * 0.5) / max(1, minimap_world_radius)
	};
};

minimap_world_position_from_gui = function(_mouse_x, _mouse_y)
{
	var _geometry = minimap_geometry_get();

	if (!is_struct(_geometry)
		|| _mouse_x < _geometry.x
		|| _mouse_x > _geometry.right
		|| _mouse_y < _geometry.y
		|| _mouse_y > _geometry.bottom)
	{
		return [false, 0, 0];
	}

	var _clamped_mouse_x = clamp(_mouse_x, _geometry.x, _geometry.right);
	var _clamped_mouse_y = clamp(_mouse_y, _geometry.y, _geometry.bottom);
	var _world_x = _geometry.world_center_x + ((_clamped_mouse_x - _geometry.center_x) / _geometry.world_to_minimap_scale);
	var _world_y = _geometry.world_center_y + ((_clamped_mouse_y - _geometry.center_y) / _geometry.world_to_minimap_scale);

	return [true, _world_x, _world_y];
};

minimap_ground_cache_update = function()
{
	minimap_ground_cell_xs = [];
	minimap_ground_cell_ys = [];
	minimap_ground_amounts = [];
	minimap_ground_is_saint = [];

	if (!instance_exists(o_cannon) || !instance_exists(o_corruption_grid))
	{
		return;
	}

	var _cannon = instance_find(o_cannon, 0);
	var _corruption_grid_object = instance_find(o_corruption_grid, 0);
	var _corruption_cell_size = _corruption_grid_object.cell_size;
	var _left_cell = clamp(floor((_cannon.x - minimap_world_radius) / _corruption_cell_size), 0, _corruption_grid_object.grid_width - 1);
	var _right_cell = clamp(floor((_cannon.x + minimap_world_radius) / _corruption_cell_size), 0, _corruption_grid_object.grid_width - 1);
	var _top_cell = clamp(floor((_cannon.y - minimap_world_radius) / _corruption_cell_size), 0, _corruption_grid_object.grid_height - 1);
	var _bottom_cell = clamp(floor((_cannon.y + minimap_world_radius) / _corruption_cell_size), 0, _corruption_grid_object.grid_height - 1);
	var _has_saint_grid = variable_instance_exists(_corruption_grid_object, "saint_grid");

	for (var _cell_x = _left_cell; _cell_x <= _right_cell; ++_cell_x)
	{
		for (var _cell_y = _top_cell; _cell_y <= _bottom_cell; ++_cell_y)
		{
			var _corruption = ds_grid_get(_corruption_grid_object.corruption_grid, _cell_x, _cell_y);
			var _saint = 0;

			if (_has_saint_grid)
			{
				_saint = ds_grid_get(_corruption_grid_object.saint_grid, _cell_x, _cell_y);
			}

			if (_saint <= 0 && _corruption < _corruption_grid_object.minimum_draw_corruption)
			{
				continue;
			}

			array_push(minimap_ground_cell_xs, _cell_x);
			array_push(minimap_ground_cell_ys, _cell_y);
			array_push(minimap_ground_amounts, max(_corruption, _saint));
			array_push(minimap_ground_is_saint, _saint > 0);
		}
	}
};

// Control hints stay visible only during unobstructed gameplay.
control_hints_x = 32;
control_hints_bottom_margin = 118;
control_hints_row_height = 28;
control_hints_row_gap = 8;
control_hints_key_min_width = 112;
control_hints_key_height = 24;
control_hints_key_padding_x = 10;
control_hints_key_text_gap = 12;
control_hints_padding_x = 12;
control_hints_padding_y = 10;
control_hints_background_alpha = 0.52;
control_hints_key_alpha = 0.18;
control_hint_keys = ["SPACE", "WASD", "MOUSE WHEEL"];
control_hint_actions = ["pause", "move camera", "zoom camera"];

// Cannon satiety is filled by hauling corpses to the cannon.
cannon_satiety_width = 460;
cannon_satiety_height = 34;
cannon_satiety_bar_offset_x = 92;
cannon_satiety_bar_width = 156;
cannon_satiety_bar_height = 8;
cannon_satiety_bar_gap = 5;
cannon_satiety_bar_label_gap = 8;
cannon_satiety_reward_icon_gap = 10;
cannon_satiety_reward_icon_radius = 7;
cannon_satiety_reward_group_gap = 18;
cannon_satiety_reward_label_gap = 3;
cannon_satiety_padding_x = 14;
cannon_satiety_label = "SATIETY";

// Wall fallen notice appears when cannon HP reaches zero, without stopping the run.
wall_fallen_notice_width = 420;
wall_fallen_notice_height = 92;
wall_fallen_notice_y = 96;
wall_fallen_notice_padding = 12;
wall_fallen_title = "THE WALL HAS FALLEN";
wall_fallen_description = "You lost, but can keep playing.";

// Objective complete notice appears when enough shrines are destroyed.
objective_complete_notice_width = 420;
objective_complete_notice_height = 92;
objective_complete_notice_y = 96;
objective_complete_notice_padding = 12;
objective_complete_title = "SHRINES CLAIMED";
objective_complete_description = "Two Shrines have fallen to the cannon.";

// Resource display order from left to right in the top-left corner.
resource_order = [
	RESOURCES.FLESH,
	RESOURCES.SOULS,
	RESOURCES.IRON,
	RESOURCES.IHOR
];

resource_colors = [
	COLOR_HUD_FLESH,
	COLOR_HUD_SOULS,
	COLOR_HUD_IRON,
	COLOR_HUD_IHOR
];

resource_icon_sprites = [
	s_flesh_icon,
	s_soul_icon,
	s_iron_icon,
	s_ihor_icon
];

// Taint display is derived from the ground corruption grid.
corruption_display_name = "TAINT";
corruption_display_value = 0;
corruption_display_percent = 0;
corruption_display_total_cells = 0;
corruption_display_decimals = 1;
corruption_update_interval = 0.25 * room_speed;
corruption_update_timer = corruption_update_interval;
corruption_display_color = COLOR_HUD_TEXT;
corruption_minimap_offset_y = 16;
corruption_minimap_label_scale = 0.8;

// Projectile queue display at the bottom center of the HUD.
projectile_queue_margin_bottom = 18;
projectile_slot_width = 86;
projectile_slot_height = 74;
projectile_slot_gap = 8;
projectile_slot_background_height = 64;
projectile_building_shell_row_offset_y = 82;
projectile_circle_radius = 13;
projectile_current_circle_radius = 17;
projectile_current_scale_padding = 5;
projectile_name_offset_y = 40;
projectile_payload_offset_y = 56;
projectile_payload_icon_size = 14;
projectile_payload_icon_gap = 4;
projectile_payload_count_gap = 2;
projectile_aim_prompt_gap = 6;
projectile_key_prompt_prefix = "Press ";
projectile_day_alpha = 0.45;
projectile_description_width = 330;
projectile_description_height = 58;
projectile_description_gap = 8;
projectile_description_line_separation = 16;

projectile_names = array_create(PROJECTILE_TYPE.COUNT, "");
projectile_names[PROJECTILE_TYPE.DAMAGE] = "DAMAGE";
projectile_names[PROJECTILE_TYPE.CORRUPTION] = "CORRUPTION";
projectile_names[PROJECTILE_TYPE.SUMMON] = "SUMMON";
projectile_names[PROJECTILE_TYPE.RALLY] = "RALLY";
projectile_names[PROJECTILE_TYPE.CULTIST] = "CULTIST";
projectile_names[PROJECTILE_TYPE.FEAST] = "TAINT";
projectile_names[PROJECTILE_TYPE.HEAL] = "HEAL";
projectile_names[PROJECTILE_TYPE.BOMB] = "BOMB";
projectile_names[PROJECTILE_TYPE.SKELETONS] = "SKELETONS";
projectile_names[PROJECTILE_TYPE.BUILDING_SHELL] = "STRUCTURE";
projectile_names[PROJECTILE_TYPE.CLEANSE] = "CLEANSE";

projectile_descriptions = array_create(PROJECTILE_TYPE.COUNT, "");
projectile_descriptions[PROJECTILE_TYPE.DAMAGE] = "Damages units and buildings inside the impact area.";
projectile_descriptions[PROJECTILE_TYPE.CORRUPTION] = "Technical corruption impact used by map systems.";
projectile_descriptions[PROJECTILE_TYPE.SUMMON] = "Summons friendly forces through valid target reactions.";
projectile_descriptions[PROJECTILE_TYPE.RALLY] = "Sends half of nearby friendly units to the impact point.";
projectile_descriptions[PROJECTILE_TYPE.CULTIST] = "Launches a cultist into battle, dealing impact damage and spawning demon form.";
projectile_descriptions[PROJECTILE_TYPE.FEAST] = "Fires corpse-fed Taint impacts that spread Taint, damage enemies, and destroy Ihor Veins for Ihor.";
projectile_descriptions[PROJECTILE_TYPE.HEAL] = "Restores " + string(BALANCE_PROJECTILE_HEAL_AMOUNT) + " health to all friendly units inside a " + string(BALANCE_PROJECTILE_HEAL_RADIUS) + " pixel radius. Payload Mastery improves it.";
projectile_descriptions[PROJECTILE_TYPE.BOMB] = "Deals " + string(BALANCE_PROJECTILE_BOMB_DAMAGE_AMOUNT) + " damage to every unit inside a " + string(BALANCE_PROJECTILE_BOMB_RADIUS) + " pixel radius. Payload Mastery improves it.";
projectile_descriptions[PROJECTILE_TYPE.SKELETONS] = "Summons " + string(BALANCE_PROJECTILE_SKELETON_COUNT) + " skeleton inside a " + string(BALANCE_PROJECTILE_SKELETON_RADIUS) + " pixel radius. Payload Mastery improves it.";
projectile_descriptions[PROJECTILE_TYPE.BUILDING_SHELL] = "Builds its stored structure where it lands. Must be fired onto tainted ground.";
projectile_descriptions[PROJECTILE_TYPE.CLEANSE] = "Enemy projectile that removes Taint where it lands.";
