map_building_warning_update();

if (global.pause)
{
	exit;
}

if (is_destroyed)
{
	exit;
}

house_saint_source_register();
if (hp <= 0)
{
	house_destroy();
	exit;
}

house_visibility_check_timer++;

if (house_visibility_check_timer < house_visibility_check_interval)
{
	house_combat_spawn_update();
	exit;
}

house_visibility_check_timer = 0;

var _guards_should_be_active = house_should_keep_guards_active();

if (_guards_should_be_active)
{
	house_visible_guards_sync(house_was_visible);
}
else if (house_was_visible)
{
	house_virtualize_guards();
}

house_was_visible = _guards_should_be_active;
house_combat_spawn_update();
