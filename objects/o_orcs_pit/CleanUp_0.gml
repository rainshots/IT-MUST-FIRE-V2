// Orcs cannot remain in the world after their owning habitat is removed.
for (var _slot_index = 0; _slot_index < array_length(owned_orcs); ++_slot_index)
{
	var _orc = owned_orcs[_slot_index];

	if (orcs_pit_unit_is_bound(_orc))
	{
		instance_destroy(_orc);
	}
}
