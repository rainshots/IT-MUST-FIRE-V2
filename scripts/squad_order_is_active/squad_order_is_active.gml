/// @description Returns whether a squad has a pending Flag System 2 order.
function squad_order_is_active(_squad)
{
	return is_struct(_squad)
		&& variable_struct_exists(_squad.properties, "order_mode")
		&& _squad.properties.order_mode != SQUAD_ORDER.NONE;
}
