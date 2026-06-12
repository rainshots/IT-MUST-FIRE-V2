/// @description Creates healing number feedback and green plus particles.
/// @param _target Unit instance that received healing.
/// @param _heal_amount Actual amount of restored HP.
function heal_feedback_create(_target, _heal_amount)
{
	if (!instance_exists(_target) || _heal_amount <= 0)
	{
		return noone;
	}

	if (!variable_instance_exists(_target, "heal_feedback_pending_amount"))
	{
		_target.heal_feedback_pending_amount = 0;
	}

	if (!variable_instance_exists(_target, "heal_feedback_next_popup_time"))
	{
		_target.heal_feedback_next_popup_time = 0;
	}

	_target.heal_feedback_pending_amount += _heal_amount;

	if (current_time < _target.heal_feedback_next_popup_time)
	{
		return noone;
	}

	if (_target.heal_feedback_pending_amount < BALANCE_HEAL_FEEDBACK_MIN_POPUP_AMOUNT)
	{
		return noone;
	}

	var _feedback_x = _target.x;
	var _feedback_y = _target.bbox_top;
	var _display_amount = _target.heal_feedback_pending_amount;

	_target.heal_feedback_pending_amount = 0;
	_target.heal_feedback_next_popup_time = current_time + (BALANCE_HEAL_FEEDBACK_COOLDOWN_TIME * 1000);

	var _popup = instance_create_layer(_feedback_x, _feedback_y, "Instances", o_damage_popup);
	_popup.popup_text = "+" + string(ceil(_display_amount));
	_popup.popup_color = COLOR_HEAL_POPUP;
	_popup.is_critical = false;

	// Spawn tinted plus sprites around the healed unit.
	if (variable_global_exists("particle_system_effects")
		&& global.particle_system_effects != noone
		&& variable_global_exists("particle_type_heal")
		&& global.particle_type_heal != noone)
	{
		for (var _particle_index = 0; _particle_index < BALANCE_HEAL_FEEDBACK_PARTICLE_COUNT; ++_particle_index)
		{
			var _particle_distance = random(BALANCE_HEAL_FEEDBACK_PARTICLE_RADIUS);
			var _particle_direction = random(360);
			var _particle_x = _target.x + lengthdir_x(_particle_distance, _particle_direction);
			var _particle_y = _target.y + lengthdir_y(_particle_distance * 0.7, _particle_direction);

			part_particles_create(global.particle_system_effects, _particle_x, _particle_y, global.particle_type_heal, 1);
		}
	}

	return _popup;
}
