/// @description Counts the capacity occupied by surviving loaded objects; controller context.
function cargo_capacity_used()
{
	var _used = 0;
	for (var _i = array_length(cargo_contents) - 1; _i >= 0; --_i)
	{
		if (!instance_exists(cargo_contents[_i])) array_delete(cargo_contents, _i, 1);
		else _used += cargo_contents[_i].cargo_cost;
	}
	return _used;
}
