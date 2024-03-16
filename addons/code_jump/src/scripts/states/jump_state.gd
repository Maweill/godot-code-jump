class_name CJJumpState
extends CJState

signal jumped

func on_enter(model: CJModel) -> void:
	var text_editor := model.text_editor
	var jump_position := model.jump_position
	text_editor.grab_focus()
	text_editor.set_caret_line(jump_position.line, false)
	text_editor.set_caret_column(jump_position.column, false)
	jumped.emit()

func on_exit() -> void:
	pass

func get_type() -> int:
	return CJStateType.JUMP
