/// @description Creates a floating resource gain popup at a world position.
/// @param _x Popup spawn x position.
/// @param _y Popup spawn y position.
/// @param _resource_type Resource enum value.
/// @param _amount Resource amount gained.
function resource_popup_create(_x, _y, _resource_type, _amount)
{
	var _resource_name = "resource";
	var _resource_color = c_white;

	// Match popup text and color to the gained resource type.
	if (_resource_type == RESOURCES.SOULS)
	{
		_resource_name = "soul";
		_resource_color = COLOR_HUD_SOULS;
	}
	else if (_resource_type == RESOURCES.IRON)
	{
		_resource_name = "iron";
		_resource_color = COLOR_HUD_IRON;
	}
	else if (_resource_type == RESOURCES.CULTISTS)
	{
		_resource_name = "cultist";
		_resource_color = COLOR_HUD_CULTISTS;
	}

	// Add plural suffix for countable resources.
	var _plural_suffix = "";
	if (_amount != 1 && _resource_type != RESOURCES.IRON)
	{
		_plural_suffix = "s";
	}

	var _popup = instance_create_layer(_x, _y, "Instances", o_resource_popup);
	_popup.popup_text = "+" + string(_amount) + " " + _resource_name + _plural_suffix;
	_popup.popup_color = _resource_color;

	return _popup;
}
