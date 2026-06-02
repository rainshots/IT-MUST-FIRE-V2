// Cultist identity chosen by the player before the first night.
cultist_name = "";
demon_type = DEMON_TYPE.NONE;
demon_ability = DEMON_ABILITY.NONE;

// Starting active abilities are rolled before demon selection so the player can preview them.
cultist_starting_abilities = array_create(DEMON_TYPE.BRUTE + 1, DEMON_ABILITY.NONE);
cultist_starting_abilities[DEMON_TYPE.IMP] = cultist_ability_roll(DEMON_TYPE.IMP);
cultist_starting_abilities[DEMON_TYPE.WARLOCK] = cultist_ability_roll(DEMON_TYPE.WARLOCK);
cultist_starting_abilities[DEMON_TYPE.BRUTE] = cultist_ability_roll(DEMON_TYPE.BRUTE);

// Core character attributes. These persist through demon form changes.
cultist_points = cultist_points_roll();
current_exp = 0;
current_lvl = 1;
pending_level_points = 0;
pending_passive_choices = 0;
pending_active_choices = 0;
passive_choice_options = [];
active_choice_options = [];
active_abilities = [];
y_sort_enabled = true;

// Passive unlock flags are shared with demon forms and start disabled.
has_imp_blood_frenzy = false;
has_imp_hellbleed = false;
has_imp_taste_of_fear = false;
has_brute_corpse_eater = false;
has_brute_rotten_aura = false;
has_brute_cursed_flesh = false;
has_warlock_soul_harvester = false;
has_warlock_curseweaver = false;
has_warlock_demonic_infusion = false;

// Day-form health is synced with the chosen demon form after selection.
max_hp = 1;
hp = max_hp;

// Visual settings for the day form labels and shared health bar style.
name_offset_y = 8;
bar_width = 34;
bar_height = 4;
name_health_bar_gap = 8;
resource_warning_offset_y = 18;
resource_warning_padding_x = 6;
resource_warning_padding_y = 3;
resource_warning_background_alpha = 0.82;

// Drag state is controlled by o_game_controller during manual cultist repositioning.
is_being_dragged = false;
drag_drop_x = x;
drag_drop_y = y;

// Building work assignment. The game controller updates these when dropped on a building.
assigned_building = noone;
is_assigned_to_building = false;
