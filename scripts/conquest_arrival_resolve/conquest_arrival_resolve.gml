/// @description Reinforces a friendly destination or resolves combat against its current owner.
function conquest_arrival_resolve(_controller, _army)
{
	if (!instance_exists(_controller)) return;
	var _target = _controller.nodes[_army.target];
	if (_target.owner == _army.owner)
	{
		// Reinforcements may exceed capacity; capacity only stops automatic recruitment.
		_target.garrison += _army.count;
		return;
	}
	var _attack = conquest_strength_get(_controller, _army.owner);
	var _defense = conquest_strength_get(_controller, _target.owner);
	if (_target.kind == CONQUEST_BUILDING.TOWER) _defense *= 1 + _target.level * 0.15;
	var _remaining_strength = _army.count * _attack - _target.garrison * _defense;
	if (_remaining_strength > 0)
	{
		_target.owner = _army.owner;
		_target.garrison = max(1, _remaining_strength / _attack);
		_target.level = max(1, _target.level - 1);
		_target.upgrade_remaining = 0;
		_target.capture_flash = 0.7;
		if (_army.owner == CONQUEST_OWNER.PLAYER)
		{
			_controller.feedback = "Building captured. Its garrison now fights for you.";
			_controller.feedback_timer = 3;
		}
	}
	else
	{
		// A tie empties the garrison but retains ownership until another attacker arrives.
		_target.garrison = max(0, -_remaining_strength / _defense);
	}
}
