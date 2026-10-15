/// @description Replaces a purchased offer, preferring options absent from the Shop; controller context.
function shop_offer_replace(_index)
{
	if (_index < 0 || _index >= array_length(shop_options)) return;
	var _purchased = shop_options[_index];
	var _pool = shop_offer_pool_get();
	var _preferred = [];
	var _fallback = [];
	for (var _i = 0; _i < array_length(_pool); ++_i)
	{
		var _candidate = _pool[_i];
		// Never replace a purchase with the same building or upgrade type.
		if (_candidate.kind == _purchased.kind && _candidate.object == _purchased.object) continue;
		array_push(_fallback, _candidate);
		var _present = false;
		for (var _slot = 0; _slot < array_length(shop_options); ++_slot)
		{
			var _current = shop_options[_slot];
			if (_current.kind == _candidate.kind && _current.object == _candidate.object)
			{
				_present = true;
				break;
			}
		}
		if (!_present) array_push(_preferred, _candidate);
	}
	var _choices = array_length(_preferred) > 0 ? _preferred : _fallback;
	if (array_length(_choices) > 0) shop_options[_index] = _choices[irandom(array_length(_choices) - 1)];
}
