/// @description Rolls persistent building and permanent upgrade offers; controller context.
function shop_begin()
{
	var _pool = shop_offer_pool_get();
	shop_options = [];
	for (var _i = 0; _i < BALANCE_SHOP_OFFER_COUNT; ++_i)
	{
		if (array_length(_pool) == 0) { array_push(shop_options, undefined); continue; }
		var _choice = irandom(array_length(_pool) - 1);
		array_push(shop_options, _pool[_choice]);
		array_delete(_pool, _choice, 1);
	}
}
