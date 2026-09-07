// Holy towers only block deployment and retain their damage/destruction handling.
map_object_unit_fade_update();
if (!is_destroyed && hp <= 0)
{
	destroy_holy_tower();
}
