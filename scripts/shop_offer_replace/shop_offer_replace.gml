/// @description Consumes a purchased offer, leaving its slot empty until refresh; controller context.
function shop_offer_replace(_index)
{
	if (_index < 0 || _index >= array_length(shop_options)) return;
	shop_options[_index] = undefined;
}
