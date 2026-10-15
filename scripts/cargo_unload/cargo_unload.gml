/// @description Returns one loaded object below the Cannon without replacing its instance.
function cargo_unload(_index)
{
	if (_index < 0 || _index >= array_length(cargo_contents) || !instance_exists(o_cannon)) return false;
	var _item = cargo_contents[_index];
	if (instance_exists(_item) && _item.object_index == o_exploding_shell)
	{
		if (!warehouse_store(_item)) { cargo_notice="No free Warehouse slots.";cargo_notice_timer=3;return false; }
		array_delete(cargo_contents,_index,1);_item.cannon_loaded=false;_item.visible=true;return true;
	}
	array_delete(cargo_contents, _index, 1);
	if (!instance_exists(_item)) return false;
	_item.cannon_loaded = false;
	_item.visible = true;
	_item.x = o_cannon.x + random_range(-100, 100);
	_item.y = o_cannon.y + random_range(BALANCE_CARGO_RETURN_MIN_Y, BALANCE_CARGO_RETURN_MAX_Y);
	if (variable_instance_exists(_item, "cargo_launched")) _item.cargo_launched = false;
	return true;
}
