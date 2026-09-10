// Tutorial popups pause gameplay and sit above every other UI layer.
depth = DEPTH_TUTORIAL_UI;
global.tutorial_popup_active = false;

popup_active = false;
popup_paused_game = false;
current_title = "";
current_body = "";
current_hint_id = "";
current_button_text = "Close";
current_icon_sprite = -1;
current_icon_sprites = [];
tutorial_queue = array_create(0);
tutorial_seen_ids = array_create(0);
// Real-time delays use current_time so they continue while gameplay is paused.
night_attack_preview_closed_time = -1;
taint_compost_tutorial_delay = 5000;
taint_compost_tutorial_triggered = false;
// These hints are temporarily disabled but remain registered for easy restoration.
tutorial_disabled_ids = [
	"construction_start",
	"buildings",
	"workers",
	"production_bonus",
	"building_upgrades",
	"cannon_workers",
	"stamina",
	"day_after_night",
	"infection"
];

// Popup layout in GUI coordinates.
popup_width = 680;
popup_height = 430;
popup_padding = 28;
popup_title_height = 36;
popup_title_icon_height = 28;
popup_title_icon_gap = 12;
popup_text_line_height = 20;
popup_button_width = 150;
popup_button_height = 42;
popup_button_margin_bottom = 26;
close_button_was_hovered = false;

// Trigger state caches prevent repeated tutorial scheduling.
construction_window_was_open = false;
previous_day_phase = global.day_phase;
tutorial_start_delay_timer = 2;

tutorial_items = [
	{
		id: "welcome",
		title: "Welcome",
		body: "Greetings, Great Pontiff! This is the prototype of IT MUST FIRE. You lead a cult that worships a possessed cannon with a demon sealed inside.\n\nYour goal: Survive "
			+ string(BALANCE_SURVIVAL_OBJECTIVE_DAYS)
			+ " days."
	},
	{
		id: "construction_start",
		title: "Summoning",
		body: "To summon a building, hover over any building pictogram in your settlement and press the left mouse button. Choose a building to create a summoning Rite requiring 1 Cultist."
	},
	{
		id: "buildings",
		title: "Buildings",
		body: "You can summon 1 building per day around the Cannon. Each building provides 1 Rite for your Cultists. The more buildings you have, the more Rites your Cultists will have!\n\nSummoning does not cost resources. Each selected building creates an Assign Rites event that requires 1 Cultist."
	},
	{
		id: "assign_rites_overview",
		title: "ASSIGN RITES",
		body: "This window shows every Rite currently available.\n\n"
			+ "Each building has its own set of Rites. Every day, each building offers one Rite to perform.\n\n"
			+ "Summoning a squad, building, trap, or tower also creates a separate Rite.",
		button_text: "OK"
	},
	{
		id: "assign_rites_cultist_spirit",
		title: "CULTIST SPIRIT",
		body: "Cultists also have a daily limit on how many Rites they can perform. Each red eye icon displayed over a Cultist allows them to perform one Rite. Spirit is restored to its maximum every morning.",
		button_text: "OK",
		icon_sprite: s_spirit_eye_red
	},
	{
		id: "assign_rites_cultist_hp",
		title: "CULTIST HP",
		body: "Cultists have HP, which is spent when performing Rites. Cultists can restore HP through Rites offered by the Blood Bath. Let's summon one. Close the Assign Rites window.",
		button_text: "OK"
	},
	{
		id: "night_attack_preview",
		title: "NIGHT ATTACKS",
		body: "Every night, the forces of the Holy Order will attack you. Their goal is to destroy the possessed Cannon.\n\n"
			+ "During the day, you can preview the directions and composition of the coming attacks.\n\n"
			+ "Close this message and find the direction of tonight's incoming attack.",
		button_text: "OK"
	},
	{
		id: "taint_compost_shell",
		title: "FIRING A TAINT COMPOST SHELL",
		body: "Every day, the Cannon can fire one Taint Compost shell during the day to spread Taint across the ground.\n\n"
			+ "On tainted ground, your troops gain advantages such as bonus movement speed, while enemy troops suffer penalties such as slowing and damage over time.",
		button_text: "OK",
		icon_sprite: s_taint_shell
	},
	{
		id: "ritual_points",
		title: "RITUAL POINTS",
		body: "The map also contains various Ritual Points that can only be activated when the ground beneath them is tainted.\n\n"
			+ "Some points summon defensive towers, some hold traps, and others contain monster dwellings.",
		button_text: "OK",
		icon_sprites: [s_point_force_disabled, s_point_force_active]
	},
	{
		id: "destroyed_player_building",
		title: "Building Destroyed",
		body: "A destroyed building will be restored the next morning with 50% HP. Each following morning, it recovers another 50% of its Max HP.\n\nWhile a building is below 100% HP, its events cost Cultists 5 additional HP."
	},
	{
		id: "cultist_recovery",
		title: "Cultist Unconscious",
		body: "A Cultist has fallen unconscious (HP <= 0). They cannot work or perform Rites while unconscious.\n\n"
			+ "Natural recovery starts on morning "
			+ string(BALANCE_EVENT_CULTIST_UNCONSCIOUS_RECOVERY_DELAY_MORNINGS + 1)
			+ " after the collapse. From then on, they regain "
			+ string(BALANCE_EVENT_CULTIST_UNCONSCIOUS_RECOVERY_HP)
			+ " HP each morning until their HP is above 0 and they can work again.\n\n"
			+ "The deeper their HP falls below 0, the longer recovery takes.",
		button_text: "OK"
	},
	{
		id: "workers",
		title: "Workers",
		body: "Every building needs at least one worker. A worker can be either a cultist or a goblin, though cultists are more efficient.\n\nTo assign a cultist or goblin to a building, hover over the unit, hold the left mouse button, drag it onto the target building, and release.\n\nUp to 3 workers can work at the same building."
	},
	{
		id: "production_bonus",
		title: "Production Bonus",
		body: "Some buildings gain work speed bonuses from specific cultist attributes. Hover over a building to inspect which attribute improves it."
	},
	{
		id: "building_upgrades",
		title: "Building Upgrades",
		body: "Some buildings can be upgraded. To upgrade a building, hover over it and press G."
	},
	{
		id: "cannon_workers",
		title: "Cannon Workers",
		body: "The cannon is hungry! Assign workers directly to the cannon so they carry corpses into it. Later, this will give you Taint at night, letting you spread Taint over much more ground."
	},
	{
		id: "stamina",
		title: "Stamina",
		body: "The yellow bar under the HP bar is cultist Stamina. It decreases while a cultist works. Assign tired cultists to the Ritual Circle to restore Stamina while they gain XP."
	},
	{
		id: "night",
		title: "Night",
		body: "At night, your combat units are swallowed by the possessed cannon. You can choose where it spits them onto the battlefield by pressing 1 and then the LMB.\n\nEach squad gets a separate volley."
	},
	{
		id: "squad_dragging",
		title: "Squad Marching",
		body: "During combat at night, drag a squad flag with LMB and release it at the destination.\n\nThe red flag means the squad is marching. Its units ignore enemies until every surviving member reaches the flag."
	},
	{
		id: "tainted_ground",
		title: "Tainted Ground",
		body: "Try to fight on tainted ground to give your troops an advantage. On tainted ground, your troops move and attack faster, while enemies take continuous damage."
	},
	{
		id: "damage_types",
		title: "Physical and Magic Damage",
		body: "There are only 2 damage types in the game: physical and magic.\n\nArmor blocks part of incoming physical damage. Magic resistance blocks part of incoming magic damage."
	},
	{
		id: "day_after_night",
		title: "Day",
		body: "After the night, your cultists return to human form. Remember to heal them before the next night arrives, for example at the Meat Bath."
	},
	{
		id: "infection",
		title: "Taint",
		body: "In addition to cultist shells, the cannon can gain Taint. Taint deals heavy damage and spreads Taint over a large area.\n\nTo gain Taint, the cannon needs corpses left after battles. Assign workers directly to the cannon to gather them."
	},
	{
		id: "cursed_buildings",
		title: "Tainted Buildings",
		body: "The map has special pictogram points. Spread Taint until it reaches one of these points, then you can summon a structure there."
	},
	{
		id: "full_moon_night",
		title: "Blood Moon",
		body: "The Blood Moon rises tonight. Enemies will attack as usual, but the night's difficulty is 20% higher.\n\nThe Blood Moon ends only after the entire attack is defeated.\n\nSurvive tonight, and tomorrow morning new Cultist will be summoned, up to your Cultist limit."
	}
];

tutorial_seen_has = function(_hint_id)
{
	var _seen_count = array_length(tutorial_seen_ids);

	for (var _seen_index = 0; _seen_index < _seen_count; ++_seen_index)
	{
		if (tutorial_seen_ids[_seen_index] == _hint_id)
		{
			return true;
		}
	}

	return false;
};

tutorial_is_disabled = function(_hint_id)
{
	var _disabled_count = array_length(tutorial_disabled_ids);

	for (var _disabled_index = 0; _disabled_index < _disabled_count; ++_disabled_index)
	{
		if (tutorial_disabled_ids[_disabled_index] == _hint_id)
		{
			return true;
		}
	}

	return false;
};

tutorial_item_find = function(_hint_id)
{
	var _item_count = array_length(tutorial_items);

	for (var _item_index = 0; _item_index < _item_count; ++_item_index)
	{
		var _item = tutorial_items[_item_index];

		if (_item.id == _hint_id)
		{
			return _item;
		}
	}

	return noone;
};

tutorial_show_next = function()
{
	var _mandatory_choice_is_open = global.focus_window == FOCUS_WINDOW.CULTIST_DEMON_SELECTION
		|| global.focus_window == FOCUS_WINDOW.CULTIST_LEVEL_UP;
	var _blood_moon_reward_is_open = variable_global_exists("blood_moon_reward_popup_active")
		&& global.blood_moon_reward_popup_active;

	if (popup_active
		|| _mandatory_choice_is_open
		|| _blood_moon_reward_is_open
		|| array_length(tutorial_queue) <= 0)
	{
		return;
	}

	var _hint_id = tutorial_queue[0];
	array_delete(tutorial_queue, 0, 1);

	var _item = tutorial_item_find(_hint_id);

	if (_item == noone)
	{
		tutorial_show_next();
		return;
	}

	current_hint_id = _item.id;
	current_title = _item.title;
	current_body = _item.body;
	current_button_text = variable_struct_exists(_item, "button_text")
		? _item.button_text
		: "Close";
	current_icon_sprite = variable_struct_exists(_item, "icon_sprite")
		? _item.icon_sprite
		: -1;
	current_icon_sprites = variable_struct_exists(_item, "icon_sprites")
		? _item.icon_sprites
		: [];

	if (array_length(current_icon_sprites) <= 0 && sprite_exists(current_icon_sprite))
	{
		current_icon_sprites = [current_icon_sprite];
	}
	popup_active = true;
	global.tutorial_popup_active = true;
	close_button_was_hovered = false;

	popup_paused_game = !global.pause;
	global.pause = true;
};

tutorial_trigger = function(_hint_id)
{
	if (tutorial_is_disabled(_hint_id) || tutorial_seen_has(_hint_id))
	{
		return;
	}

	array_push(tutorial_seen_ids, _hint_id);
	array_push(tutorial_queue, _hint_id);
	tutorial_show_next();
};

tutorial_close = function()
{
	var _closed_hint_id = current_hint_id;

	popup_active = false;
	global.tutorial_popup_active = false;

	if (popup_paused_game)
	{
		global.pause = false;
	}

	popup_paused_game = false;

	// Assign Rites owns the contextual hint that follows its overview popup.
	if (instance_exists(o_jobs_ui))
	{
		var _jobs_ui = instance_find(o_jobs_ui, 0);

		if (variable_instance_exists(_jobs_ui, "jobs_onboarding_tutorial_closed"))
		{
			_jobs_ui.jobs_onboarding_tutorial_closed(_closed_hint_id);
		}
	}

	if (_closed_hint_id == "welcome" && instance_exists(o_game_controller))
	{
		global.tutorial_welcome_closed = true;

		var _game_controller = instance_find(o_game_controller, 0);

		if (variable_instance_exists(_game_controller, "open_starting_cultist_selection"))
		{
			_game_controller.open_starting_cultist_selection();
		}

		return;
	}

	// The Blood Bath explanation follows after the player confirms the Spirit explanation.
	if (_closed_hint_id == "assign_rites_cultist_spirit")
	{
		tutorial_trigger("assign_rites_cultist_hp");
	}
	else if (_closed_hint_id == "night_attack_preview")
	{
		night_attack_preview_closed_time = current_time;
	}
	else if (_closed_hint_id == "taint_compost_shell")
	{
		tutorial_trigger("ritual_points");
	}
	else if (_closed_hint_id == "ritual_points" && instance_exists(o_jobs_ui))
	{
		var _ritual_points_jobs_ui = instance_find(o_jobs_ui, 0);

		if (variable_instance_exists(_ritual_points_jobs_ui, "jobs_taint_aim_hint_start"))
		{
			_ritual_points_jobs_ui.jobs_taint_aim_hint_start();
		}
	}

	tutorial_show_next();
};

tutorial_draw = function()
{
	if (!popup_active)
	{
		return;
	}

	var _gui_width = display_get_gui_width();
	var _gui_height = display_get_gui_height();
	var _popup_x = (_gui_width - popup_width) * 0.5;
	var _popup_y = (_gui_height - popup_height) * 0.5;
	var _button_x = _popup_x + ((popup_width - popup_button_width) * 0.5);
	var _button_y = _popup_y + popup_height - popup_button_margin_bottom - popup_button_height;
	var _mouse_x = device_mouse_x_to_gui(0);
	var _mouse_y = device_mouse_y_to_gui(0);
	var _button_hovered = _mouse_x >= _button_x
		&& _mouse_x <= _button_x + popup_button_width
		&& _mouse_y >= _button_y
		&& _mouse_y <= _button_y + popup_button_height;
	var _text_x = _popup_x + popup_padding;
	var _text_y = _popup_y + popup_padding + popup_title_height + 18;
	var _text_width = popup_width - (popup_padding * 2);

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_alpha(0.96);
	draw_set_color(COLOR_HUD_BACKGROUND);
	draw_rectangle(_popup_x, _popup_y, _popup_x + popup_width, _popup_y + popup_height, false);

	draw_set_alpha(1);
	draw_set_color(COLOR_PROJECTILE_CORRUPTION);
	draw_rectangle(_popup_x, _popup_y, _popup_x + popup_width, _popup_y + popup_height, true);

	draw_set_color(COLOR_HUD_TEXT);
	if (variable_global_exists("ui_heading_font") && font_exists(global.ui_heading_font))
	{
		draw_set_font(global.ui_heading_font);
	}

	var _title_x = _popup_x + popup_padding;

	var _title_icon_count = array_length(current_icon_sprites);

	for (var _title_icon_index = 0; _title_icon_index < _title_icon_count; ++_title_icon_index)
	{
		var _title_icon_sprite = current_icon_sprites[_title_icon_index];

		if (!sprite_exists(_title_icon_sprite))
		{
			continue;
		}

		var _icon_aspect = sprite_get_width(_title_icon_sprite)
			/ max(1, sprite_get_height(_title_icon_sprite));
		var _icon_width = popup_title_icon_height * _icon_aspect;
		var _icon_y = _popup_y + popup_padding
			+ ((popup_title_height - popup_title_icon_height) * 0.5);

		draw_set_color(c_white);
		draw_sprite_stretched(
			_title_icon_sprite,
			0,
			_title_x,
			_icon_y,
			_icon_width,
			popup_title_icon_height
		);
		_title_x += _icon_width + popup_title_icon_gap;
	}

	draw_set_color(COLOR_HUD_TEXT);
	draw_text(_title_x, _popup_y + popup_padding, current_title);

	if (variable_global_exists("ui_font") && font_exists(global.ui_font))
	{
		draw_set_font(global.ui_font);
	}

	draw_set_color(COLOR_HUD_PROJECTILE_DESCRIPTION);
	draw_text_ext(_text_x, _text_y, current_body, popup_text_line_height, _text_width);

	draw_set_color(_button_hovered ? COLOR_PROJECTILE_CORRUPTION : c_black);
	draw_rectangle(_button_x, _button_y, _button_x + popup_button_width, _button_y + popup_button_height, false);

	draw_set_color(COLOR_HUD_TEXT);
	draw_rectangle(_button_x, _button_y, _button_x + popup_button_width, _button_y + popup_button_height, true);

	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_text(
		_button_x + (popup_button_width * 0.5),
		_button_y + (popup_button_height * 0.5),
		current_button_text
	);

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
};

tutorial_current_day_get = function()
{
	if (!instance_exists(o_game_controller))
	{
		return 1;
	}

	var _game_controller = instance_find(o_game_controller, 0);

	if (variable_instance_exists(_game_controller, "night_attack_night_index"))
	{
		return max(1, _game_controller.night_attack_night_index);
	}

	return 1;
};

global.tutorial_hint_trigger = function(_hint_id)
{
	if (variable_global_exists("tutorial_hints_enabled") && !global.tutorial_hints_enabled)
	{
		return;
	}

	if (!instance_exists(o_tutorial_controller))
	{
		return;
	}

	var _tutorial_controller = instance_find(o_tutorial_controller, 0);

	if (variable_instance_exists(_tutorial_controller, "tutorial_trigger"))
	{
		_tutorial_controller.tutorial_trigger(_hint_id);
	}
};
