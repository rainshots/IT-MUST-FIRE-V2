// Linked graves cannot outlive the tomb that owns them.
var _linked_count = array_length(linked_graves);
for (var _grave_index = 0; _grave_index < _linked_count; ++_grave_index)
{
	var _grave = linked_graves[_grave_index];
	if (instance_exists(_grave))
	{
		instance_destroy(_grave);
	}
}
linked_graves = [];
