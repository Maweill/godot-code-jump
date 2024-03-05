class_name CJIdleState
extends CJState

var _viewport: Viewport
var _text_editor: TextEdit
var _plugin_shortcut: Shortcut

func on_enter(model: CJModel) -> void:
	_viewport = model.viewport
	_text_editor = model.text_editor
	_plugin_shortcut = model.plugin_shorcut

func on_exit() -> void:
	pass

func on_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.is_pressed()):
		return
	if not _plugin_shortcut.matches_event(event):
		return

	_viewport.set_input_as_handled()
	# transition to listen_jump_letter_state

func get_type() -> int:
	return CJStateType.IDLE
