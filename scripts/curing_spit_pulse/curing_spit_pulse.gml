/// @description Heals living allies in the field and applies its chosen pulse upgrade.
/// @param {Id.Instance} _field Active Curing Spit field with current Gaze bounds.
function curing_spit_pulse(_field)
{
	if (!instance_exists(_field) || global.day_phase != DAY_PHASE.NIGHT)
	{
		return;
	}
	// Units only: Cannon and buildings are not eligible for this healing effect.
	var _unit_count = instance_number(o_units_parent);
	for (var _unit_index = 0; _unit_index < _unit_count; ++_unit_index)
	{
		var _unit = instance_find(o_units_parent, _unit_index);
		if (!instance_exists(_unit) || _unit.hp <= 0 || !_unit.visible || _unit.is_being_dragged
			|| point_distance(_field.x, _field.y, _unit.x, _unit.y) > _field.effect_radius)
		{
			continue;
		}
		if (_unit.unit_faction == UNIT_FACTION.FRIENDLY)
		{
			var _previous_hp = _unit.hp;
			_unit.hp = min(_unit.max_hp, _unit.hp + BALANCE_CURING_SPIT_HEAL_AMOUNT);
			if (_unit.hp > _previous_hp)
			{
				heal_feedback_create(_unit, _unit.hp - _previous_hp);
			}
		}
		else if (_unit.unit_faction == UNIT_FACTION.ENEMY
			&& _field.upgrade == CURING_SPIT_UPGRADE.ROTTEN_BREATH)
		{
			// The status system refreshes duration and keeps a single non-stacking strength.
			_unit.status_effect_apply(STATUS_EFFECT.ATTACK_SLOW,
				BALANCE_CURING_SPIT_ROTTEN_BREATH_DURATION, BALANCE_CURING_SPIT_ROTTEN_BREATH_ATTACK_SLOW);
		}
	}
	// Summon independently of whether the pulse found allies or enemies; no corpse is consumed.
	if (_field.upgrade == CURING_SPIT_UPGRADE.CURE_THE_DEAD)
	{
		var _direction = random(360);
		var _distance = sqrt(random(1)) * _field.effect_radius;
		var _bonelet = instance_create_layer(_field.x + lengthdir_x(_distance, _direction),
			_field.y + lengthdir_y(_distance, _direction), "Instances", o_skeleton_bonelet);
		if (instance_exists(_bonelet))
		{
			_bonelet.squad = noone;
			_bonelet.squad_unit_index = -1;
			_bonelet.projectile_skeleton_dies_at_morning = true;
			_bonelet.regroup_is_active = false;
			_bonelet.rally_is_active = false;
			_bonelet.target_instance = noone;
			_bonelet.alert_target = noone;
		}
	}
}
