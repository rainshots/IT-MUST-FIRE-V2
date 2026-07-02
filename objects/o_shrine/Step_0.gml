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

if (!is_attackable)
{
	exit;
}

shrine_defender_spawner_update();
