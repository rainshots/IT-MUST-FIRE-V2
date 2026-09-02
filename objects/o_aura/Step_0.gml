// Orphaned or expired aura markers remove themselves immediately.
if (!instance_exists(aura_owner))
{
	instance_destroy();
	exit;
}

// The unit remains the source of truth for position and visibility.
x = aura_owner.x + aura_offset_x;
y = aura_owner.y + aura_offset_y;
visible = aura_owner.visible
	&& variable_instance_exists(aura_owner, "hp")
	&& aura_owner.hp > 0;
