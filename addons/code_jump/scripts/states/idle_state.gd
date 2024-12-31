class_name CJIdleState
extends CJState

signal letter_plugin_activated
signal words_plugin_activated

var _letter_shortcut: Shortcut
var _words_shortcut: Shortcut

func on_enter(model: CJModel) -> void:
	_letter_shortcut = model.settings.letter_plugin_activation_shortcut
	_words_shortcut = model.settings.words_plugin_activation_shortcut

func on_exit() -> void:
	pass

func on_input(event: InputEvent, viewport: Viewport) -> void:
	if not (event is InputEventKey and event.is_pressed()):
		return

	if _letter_shortcut.matches_event(event):
		viewport.set_input_as_handled()
		letter_plugin_activated.emit()
	elif _words_shortcut.matches_event(event):
		viewport.set_input_as_handled()
		words_plugin_activated.emit()

func get_type() -> int:
	return CJStateType.IDLE
