map_building_warning_update();

if (global.pause)
{
	exit;
}

house_saint_source_register();
house_combat_spawn_update();

if (hp <= 0)
{
	house_destroy();
	exit;
}

house_visibility_check_timer++;

if (house_visibility_check_timer < house_visibility_check_interval)
{
	exit;
}

house_visibility_check_timer = 0;

var _is_visible = house_is_visible_by_fog();

if (_is_visible)
{
	house_visible_guards_sync(house_was_visible);
}
else if (house_was_visible)
{
	house_virtualize_guards();
}

house_was_visible = _is_visible;
