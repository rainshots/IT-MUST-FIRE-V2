/// @description Creates a floating ability name popup at a world position.
/// @param _x Popup spawn x position.
/// @param _y Popup spawn y position.
/// @param _ability Ability enum value.
function ability_popup_create(_x, _y, _ability)
{
	var _popup = instance_create_layer(_x, _y, "Instances", o_ability_popup);
	_popup.popup_text = string_upper(cultist_ability_name_get(_ability)) + "!";

	return _popup;
}
