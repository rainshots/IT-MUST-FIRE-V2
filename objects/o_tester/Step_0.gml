// Tester should not spawn objects while gameplay input is focused elsewhere.
if (global.pause || global.focus_window != FOCUS_WINDOW.NOONE)
{
	exit;
}
