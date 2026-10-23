if (global.pause) exit;
if (hp <= 0 && !building_accepts_workers) idol_break();
event_inherited();
if (hp <= 0)
{
	smoke_seconds -= global.gameplay_time_scale / max(1, room_speed);
	if (smoke_seconds <= 0)
	{
		building_smoke_create(id);
		smoke_seconds = BALANCE_IDOL_SMOKE_SECONDS;
	}
}
