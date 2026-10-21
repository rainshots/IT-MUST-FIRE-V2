/// @description Purchases an affordable upgrade or creates an unpaid building preview; controller context.
function shop_select(_index)
{
	if(fight_state != FIGHT_STATE.ACTIVE || instance_exists(shop_preview) || _index<0 || _index>=array_length(shop_options)) return false;
	var _offer=shop_options[_index];
	if (!is_struct(_offer)) return false;
	if(global.faction_mana[global.player_faction]<_offer.cost) return false;
	// Upgrades apply immediately; building purchases still pay only on placement.
	if (_offer.kind != SHOP_OFFER_KIND.BUILDING)
	{
		switch (_offer.kind)
		{
			case SHOP_OFFER_KIND.CULTIST:

				instance_create_layer(BALANCE_BUILDING_GRID_CENTER_X, BALANCE_BUILDING_GRID_CENTER_Y + BALANCE_DAY_CANNON_REGROUP_OFFSET_Y, "Instances", o_cultist);
				break;
			case SHOP_OFFER_KIND.UNIT_CAP:
				player_unit_cap += BALANCE_SHOP_UNIT_CAP_INCREASE;
				break;
			case SHOP_OFFER_KIND.BUILDING_ZONE:
				return false;
				break;
			default: return false;
		}
		global.faction_mana[global.player_faction] -= _offer.cost;
		shop_offer_replace(_index);
		return true;
	}
	shop_preview=instance_create_layer(BALANCE_BUILDING_GRID_CENTER_X,BALANCE_BUILDING_GRID_CENTER_Y,"Instances",_offer.object);
	shop_preview.purchase_value = _offer.cost;
	shop_preview.placement_preview=true;shop_preview.is_being_dragged=true;
	shop_purchase_index = _index;
	shop_cost=_offer.cost;shop_wait_release=true;
	shop_previous_pause=global.pause;global.pause=true;cannon_aiming=false;
	return true;
}
