/// @description Rolls persistent building and permanent upgrade offers; controller context.
function shop_begin()
{
	var _pool = shop_offer_pool_get();
	shop_options = [];
	for (var _i = 0; _i < BALANCE_SHOP_OFFER_COUNT; ++_i)
	{
		array_push(shop_options, _pool[irandom(array_length(_pool) - 1)]);
	}
}
