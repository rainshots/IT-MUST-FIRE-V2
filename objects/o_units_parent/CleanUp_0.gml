// Every unit owns at most one reusable path resource.
if (navigation_path != noone)
{
	path_delete(navigation_path);
	navigation_path = noone;
}
