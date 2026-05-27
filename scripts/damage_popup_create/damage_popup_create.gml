/// @description Creates a floating damage number popup at a world position.
/// @param _x Popup spawn x position.
/// @param _y Popup spawn y position.
/// @param _amount Damage amount to display.
/// @param _target_faction Faction of the damaged unit.
/// @param _is_critical Optional. Whether the damage was critical.
function damage_popup_create(_x, _y, _amount, _target_faction, _is_critical = false)
{
	var _popup_color = COLOR_DAMAGE_ENEMY;
	var _popup_text = string(ceil(_amount));

	if (_target_faction == UNIT_FACTION.FRIENDLY)
	{
		_popup_color = COLOR_DAMAGE_FRIENDLY;
	}

	if (_is_critical)
	{
		_popup_text += "!";
	}

	var _popup = instance_create_layer(_x, _y, "Instances", o_damage_popup);
	_popup.popup_text = _popup_text;
	_popup.popup_color = _popup_color;
	_popup.is_critical = _is_critical;

	// Damage numbers and blood are part of the same hit feedback.
	blood_particles_create(_x, _y);

	return _popup;
}
