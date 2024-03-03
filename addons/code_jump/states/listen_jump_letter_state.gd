class_name CJListenJumpLetterState
extends CJState

signal jump_letter_received(letter: String)

var _viewport: Viewport
var _text_editor: TextEdit

func _init(viewport: Viewport, text_editor: TextEdit) -> void:
	_viewport = viewport
	_text_editor = text_editor

func on_enter() -> void:
	_text_editor.release_focus()
	print("listening for jump key")

func on_exit() -> void:
	pass

func on_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.is_pressed()):
		return

	_viewport.set_input_as_handled()
	var jump_letter = (event as InputEventKey).as_text_key_label()
	jump_letter_received.emit(jump_letter)
