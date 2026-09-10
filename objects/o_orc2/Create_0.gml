// Reuse shared friendly-unit combat, navigation, status, and damage behavior.
event_inherited();
image_yscale = 1.5
image_xscale = image_yscale;

// Orc combat stats.
max_hp = BALANCE_ORC2_MAX_HP;
hp = max_hp;
move_speed = BALANCE_ORC2_MOVE_SPEED;
armor = BALANCE_ORC2_ARMOR;
magic_resistance = BALANCE_ORC2_MAGIC_RESISTANCE;
reload_time = BALANCE_ORC2_RELOAD_TIME * room_speed;
reload_timer = 0;
damage = BALANCE_ORC2_PHYSICAL_DAMAGE;
magic_damage = 0;
attack_radius = BALANCE_ORC2_ATTACK_RADIUS;
vision_radius = BALANCE_ORCS_PIT_DEFENSE_RADIUS;
target_detection_radius = vision_radius;

// Initialize shared habitat defense and return-home behavior.
habitat_unit_initialize();
