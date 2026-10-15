/// @description Returns charge-scaled range, reduced linearly above half cargo capacity; controller context.
function cannon_range_get()
{
	var _load_share = clamp(cargo_capacity_used() / max(1, cargo_capacity), 0, 1);
	var _penalty_progress = clamp((_load_share - BALANCE_CARGO_RANGE_PENALTY_START) / (1 - BALANCE_CARGO_RANGE_PENALTY_START), 0, 1);
	var _load_multiplier = lerp(1, BALANCE_CARGO_FULL_RANGE_MULTIPLIER, _penalty_progress);
	return BALANCE_CARGO_MAX_RANGE * clamp(fight_charge / BALANCE_FIGHT_CHARGE_MAX, 0, 1) * _load_multiplier;
}
