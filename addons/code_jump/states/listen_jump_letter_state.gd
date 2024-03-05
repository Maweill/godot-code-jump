class_name CJListenJumpLetterState
extends CJState

signal jump_letter_received(letter: String)

var _text_editor: TextEdit

func on_enter(model: CJModel) -> void:
	_text_editor = model.text_editor

	_text_editor.release_focus()
	print("listening for jump key")

func on_exit() -> void:
	pass

func on_input(event: InputEvent, viewport: Viewport) -> void:
	if not (event is InputEventKey and event.is_pressed()):
		return

	viewport.set_input_as_handled()
	var jump_letter = (event as InputEventKey).as_text_key_label()
	jump_letter_received.emit(jump_letter)

func get_type() -> int:
	return CJStateType.LISTEN_JUMP_LETTER
