// Pause freezes habitat presentation and destruction handling.
map_building_warning_update();
map_object_unit_fade_update();

if (global.pause)
{
	exit;
}

// Handle damage sources that set HP directly instead of using unit_damage_receive().
if (hp <= 0)
{
	player_building_destroy_effect_create();
	player_building_restore_point_create();
	instance_destroy();
	exit;
}
