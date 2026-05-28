/// @description Creates a floating resource change popup at a world position.
/// @param _x Popup spawn x position.
/// @param _y Popup spawn y position.
/// @param _resource_type Resource enum value.
/// @param _amount Resource amount changed.
function resource_popup_create(_x, _y, _resource_type, _amount)
{
	var _resource_color = c_white;
	var _resource_icon = noone;

	// Match popup icon and color to the gained resource type.
	if (_resource_type == RESOURCES.FLESH)
	{
		_resource_color = COLOR_HUD_FLESH;
		_resource_icon = s_flesh_icon;
	}
	else if (_resource_type == RESOURCES.SOULS)
	{
		_resource_color = COLOR_HUD_SOULS;
		_resource_icon = s_soul_icon;
	}
	else if (_resource_type == RESOURCES.IRON)
	{
		_resource_color = COLOR_HUD_IRON;
		_resource_icon = s_iron_icon;
	}

	var _popup = instance_create_layer(_x, _y, "Instances", o_resource_popup);
	var _change_sign = "";

	if (_amount > 0)
	{
		_change_sign = "+";
	}

	_popup.popup_text = _change_sign + string(_amount);
	_popup.popup_color = _resource_color;
	_popup.popup_icon = _resource_icon;

	return _popup;
}
