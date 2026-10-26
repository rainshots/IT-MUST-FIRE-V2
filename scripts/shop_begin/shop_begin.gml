/// @description Rolls persistent building and permanent upgrade offers; controller context.
function shop_begin()
{
	var _pool = shop_offer_pool_get();
	shop_options = [];
	// Reserve one offer for a basic army producer, then draw the remaining unique offers.
	var _recruiters = [];
	for (var _i = 0; _i < array_length(_pool); ++_i)
		if (_pool[_i].object == o_worker_graveyard || _pool[_i].object == o_summon_circle) array_push(_recruiters, _i);
	if (array_length(_recruiters) > 0)
	{
		var _choice = _recruiters[irandom(array_length(_recruiters) - 1)];
		array_push(shop_options, _pool[_choice]);
		array_delete(_pool, _choice, 1);
	}
	for (var _i = array_length(shop_options); _i < BALANCE_SHOP_OFFER_COUNT; ++_i)
	{
		if (array_length(_pool) == 0) { array_push(shop_options, undefined); continue; }
		var _choice = irandom(array_length(_pool) - 1);
		array_push(shop_options, _pool[_choice]);
		array_delete(_pool, _choice, 1);
	}
	// Keep the guaranteed building from always occupying the first slot.
	if (array_length(shop_options) > 1)
	{
		var _swap = irandom(array_length(shop_options) - 1);
		var _first = shop_options[0];
		shop_options[0] = shop_options[_swap];
		shop_options[_swap] = _first;
	}
}
