// Handle damage sources that modify HP directly.
if (!global.pause && hp <= 0) house_death_process();

if (!global.pause && hp > 0)
{
	house_guards_spawn();
	house_guards_regenerate(global.gameplay_time_scale / max(1, room_speed));
}
