// Pause freezes shrine corruption checks.
if (global.pause)
{
	exit;
}

shrine_saint_source_register();

if (is_corrupted)
{
	exit;
}

shrine_day_volley_update();

if (!is_attackable)
{
	exit;
}

shrine_defender_spawner_update();
