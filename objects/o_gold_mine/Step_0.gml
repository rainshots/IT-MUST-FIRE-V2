// Transform into a cursed mine when the ground under it is infected.
if (global.pause)
{
	exit;
}

if (is_on_corrupted_ground())
{
	transform_into(o_gold_mine_cursed);
}
