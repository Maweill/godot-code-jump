class_name CJIdleState
extends CJState

signal plugin_activated

var _plugin_shortcut: Shortcut


func on_enter(model: CJModel) -> void:
	_plugin_shortcut = model.plugin_shortcut


func on_exit() -> void:
	pass


func on_input(event: InputEvent, viewport: Viewport) -> void:
	if not (event is InputEventKey and event.is_pressed()):
		return
	if not _plugin_shortcut.matches_event(event):
		return

	viewport.set_input_as_handled()
	plugin_activated.emit()


func get_type() -> int:
	return CJStateType.IDLE
