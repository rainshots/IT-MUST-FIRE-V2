// Shared structure targeting and damage make trees destructible by enemies.
event_inherited();
source_cannon = noone;
max_hp = BALANCE_DARK_GARDEN_TREE_HP * BALANCE_GLOBAL_HP_MULTIPLIER;
hp = max_hp;
player_building_cleansed_base_max_hp = max_hp;
// Temporary plants keep their fixed health on both clean and corrupted ground.
player_building_ground_state_update = function()
{
};
building_constructed_by_shell = true;
corruption_bar_visible = false;
image_xscale = BALANCE_DARK_GARDEN_TREE_SCALE;
image_yscale = image_xscale;
image_speed = 0;
tooltip_lines = ["Dark Tree", "Spawns a stunning berry every 30 seconds. Disappears at dawn."];
// Each mature tree owns independent berry and propagation clocks.
berry_remaining = BALANCE_DARK_GARDEN_BERRY_TIME * room_speed;
propagation_remaining = random_range(BALANCE_DARK_GARDEN_PROPAGATION_MIN_TIME,
	BALANCE_DARK_GARDEN_PROPAGATION_MAX_TIME) * room_speed;
