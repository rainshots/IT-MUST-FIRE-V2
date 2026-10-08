/// @description Credits one defeat to the killing unit's faction; optional faction preserves projectile attribution after its source dies.
function faction_favor_award(_target, _source = noone, _credit_faction = FACTION.NONE)
{
	if (!instance_exists(_target) || !variable_instance_exists(_target, "defeat_value")) return;
	if (_credit_faction == FACTION.NONE && instance_exists(_source)
		&& variable_instance_exists(_source, "unit_faction") && variable_instance_exists(_source, "faction"))
	{
		_credit_faction = _source.faction;
	}
	if (_credit_faction < FACTION.ORDER || _credit_faction > FACTION.WILDLINGS
		|| !faction_target_is_hostile(_credit_faction, _target) || faction_is_defeated(_credit_faction)) return;
	if (!instance_exists(o_game_controller)) return;
	var _controller = instance_find(o_game_controller, 0);
	if (!_controller.faction_match_started || _controller.faction_match_finished) return;
	if (variable_instance_exists(_target, "favor_defeat_awarded") && _target.favor_defeat_awarded) return;
	_target.favor_defeat_awarded = true;
	global.faction_favor[_credit_faction] += max(0, _target.defeat_value);
}
