// Initialize shared friendly state.
event_inherited();

// Worker cultists replace temporary goblin workers in the settlement redesign.
var _worker_cultist_sprites = [s_cultist_01, s_cultist_02, s_cultist_03, s_cultist_04];
sprite_index = _worker_cultist_sprites[irandom(array_length(_worker_cultist_sprites) - 1)];
image_xscale = 0.7;
image_yscale = image_xscale;

// Worker cultists are laborers, not combat units.
max_hp = BALANCE_WORKER_CULTIST_HP;
hp = max_hp;
ignored_by_enemies = true;
damage = 0;
magic_damage = 0;
reload_time = room_speed;
attack_radius = 0;
move_speed = BALANCE_GOBLIN_MOVE_SPEED;
unit_can_attack_cannon = false;
target_detection_radius = 0;
vision_radius = 0;

// Worker buildings read this fixed multiplier.
worker_speed_multiplier = BALANCE_WORKER_CULTIST_WORK_SPEED_MULTIPLIER;

// Worker cultists can be dragged and assigned like goblins.
is_being_dragged = false;
drag_drop_x = x;
drag_drop_y = y;
assigned_building = noone;
is_assigned_to_building = false;

// Cannon corpse hauling state is reused by worker assignment systems.
carried_corpse = noone;
carried_corpses = [];
corpse_carry_capacity = BALANCE_CANNON_CORPSE_CARRY_CAPACITY;
reserved_corpse_id = noone;
cannon_no_corpse_warning_active = false;
cannon_no_corpse_warning_text = "There are no available corpses";
cannon_no_corpse_warning_offset_y = 34;
cannon_no_corpse_warning_padding_x = 6;
cannon_no_corpse_warning_padding_y = 3;
cannon_no_corpse_warning_background_alpha = 0.82;
cannon_loading = false;
cannon_loaded = false;

// Worker whip temporarily improves day productivity at the cost of health.
whip_timer = 0;
whip_duration = 0;
whip_work_multiplier = 1;

// Worker UI labels use the shared unit health bar and worker warning style.
bar_offset_y = -2;
idle_work_label_text = "NO WORK";
idle_work_label_offset_y = 34;
idle_work_label_padding_x = 6;
idle_work_label_padding_y = 3;
idle_work_label_background_alpha = 0.82;
resource_warning_offset_y = 18;
resource_warning_padding_x = 6;
resource_warning_padding_y = 3;
resource_warning_background_alpha = 0.82;
