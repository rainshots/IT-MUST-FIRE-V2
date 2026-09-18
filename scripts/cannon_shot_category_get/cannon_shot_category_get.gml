/// @description Separates immediate aimed effects from shots that launch projectiles.
/// @param {PROJECTILE_TYPE} _shot_type Shot identity to classify.
function cannon_shot_category_get(_shot_type)
{
	switch (_shot_type)
	{
		case PROJECTILE_TYPE.CURING_SPIT:
		case PROJECTILE_TYPE.DARK_GARDEN:
		case PROJECTILE_TYPE.QUICKSAND:
			return CANNON_SHOT_CATEGORY.PROJECTILE_UNTARGETED;

		case PROJECTILE_TYPE.ABSORPTION:
			return CANNON_SHOT_CATEGORY.INSTANT_UNTARGETED;

		case PROJECTILE_TYPE.LOOK_OVER_THERE:
			return CANNON_SHOT_CATEGORY.INSTANT;
	}
	return CANNON_SHOT_CATEGORY.PROJECTILE;
}
