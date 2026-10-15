/// @description Deploys a surviving unit or detonates an enemy-only shell at a landing point.
function cargo_land(_item, _x, _y, _activate = true)
{
	if (!instance_exists(_item)) return;
	_item.x = _x; _item.y = _y;
	_item.cannon_loaded = false;
	_item.visible = true;
	if (_item.object_index == o_exploding_shell && _activate)
	{
		if (_item.corruption_shell)
		{
			if (!instance_exists(o_corruption_grid)) instance_create_layer(0, 0, "Instances", o_corruption_grid);
			o_corruption_grid.corrupt_circle(_x, _y, BALANCE_CORRUPTION_SHELL_RADIUS, 1);
		}
		var _targets = [];
		with (all)
		{
			if (variable_instance_exists(id, "unit_faction") && unit_faction == UNIT_FACTION.ENEMY
				&& cannon_target_in_blast(id, _x, _y)) array_push(_targets, id);
		}
		for (var _i = 0; _i < array_length(_targets); ++_i)
		{
			var _target=_targets[_i];
			cannon_damage_apply(_target,(_item.corruption_shell ? BALANCE_CORRUPTION_SHELL_DAMAGE : BALANCE_CANNON_NORMAL_DAMAGE*(_item.hell_shell ? BALANCE_HELL_SHELL_DAMAGE_MULTIPLIER : 1)));
			if(_item.hell_shell && instance_exists(_target) && _target.hp>0)
			{
				var _burn=instance_create_layer(_target.x,_target.y,"Instances",o_cannon_effect);
				_burn.effect_type=CANNONBALL_TYPE.FIRE;_burn.burn_target=_target;_burn.remaining_seconds=BALANCE_CANNON_BURN_SECONDS;
			}
		}
		var _flash = instance_create_layer(_x, _y, "Instances", o_particle_explosion);
		_flash.end_radius = BALANCE_CANNON_BLAST_RADIUS;
		instance_destroy(_item);
	}
	else if (_item.object_index == o_exploding_shell) warehouse_store(_item);
	else if (variable_instance_exists(_item, "cargo_launched")) _item.cargo_launched = _activate;
}
