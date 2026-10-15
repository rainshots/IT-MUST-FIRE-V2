/// @description Loads a living player unit or shell if its full cost fits; controller context.
function cargo_load(_item)
{
	if (!instance_exists(_item) || !instance_exists(o_cannon) || !variable_instance_exists(_item, "cargo_cost")) return false;
	if (_item.cannon_loaded || (variable_instance_exists(_item, "hp") && _item.hp <= 0)) return false;
	if (cargo_capacity_used() + _item.cargo_cost > cargo_capacity) return false;
	if (_item.object_index == o_exploding_shell) shell_storage_release(_item);
	array_push(cargo_contents, _item);
	_item.cannon_loaded = true;
	_item.is_being_dragged = false;
	_item.visible = false;
	_item.x = o_cannon.x;
	_item.y = o_cannon.y;
	if (variable_instance_exists(_item, "target_instance")) _item.target_instance = noone;
	return true;
}
