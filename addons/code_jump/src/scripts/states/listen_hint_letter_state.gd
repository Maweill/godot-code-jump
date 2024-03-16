class_name CJListenHintLetterState
extends CJState

class JumpHint:
	var text_editor_position: CJTextPosition
	var view: Label

	func get_text() -> String:
		return view.text

	func set_position(position: Vector2) -> void:
		view.set_global_position(position)

	func destroy() -> void:
		view.queue_free()

signal jump_position_received(position: CJTextPosition)
signal cancelled()

const LATIN_LETTERS_COUNT := 25

var _jump_hint_scene: PackedScene = preload("res://addons/code_jump/src/views/jump_hint.tscn")
var _text_editor: TextEdit
var _jump_letter: String
var _jump_hints_single: Dictionary = {}
var _jump_hints_double: Dictionary = {}

func on_enter(model: CJModel) -> void:
	_text_editor = model.text_editor
	_jump_letter = model.jump_letter
	_text_editor.grab_focus()
	var highlight_from_position = CJTextPosition.new(_text_editor.get_first_visible_line(), 0)
	await _highlight_matches_async(highlight_from_position, _text_editor.get_last_full_visible_line() + 1)
	_text_editor.release_focus()

	print("listening for hint key")

func on_exit() -> void:
	_destroy_jump_hints(_jump_hints_single)
	_destroy_jump_hints(_jump_hints_double)

func on_input(event: InputEvent, viewport: Viewport) -> void:
	if not (event is InputEventKey and event.is_pressed()):
		return

	viewport.set_input_as_handled()
	var input_event_key: InputEventKey = event as InputEventKey
	if input_event_key.keycode == KEY_ESCAPE:
		cancelled.emit()
		return

	var hint_letter = input_event_key.as_text_key_label().to_lower()
	# iterate over _jump_hints_double keys, check if hint_letter is equal any of the keys` first letter
	var double_hint := _get_hint_double(hint_letter)
	if double_hint != null:
		# spawn single hints starting from the second letter of hint found
		var hint_second_letter := double_hint.get_text()[1]
		print("hint_second_letter=%s" % hint_second_letter)

		var first_double_hint_position := double_hint.text_editor_position
		var last_double_hint_position := _get_last_double_hint_position()

		# destroy all jump hints
		_destroy_jump_hints(_jump_hints_single)
		_destroy_jump_hints(_jump_hints_double)

		_highlight_matches_async(first_double_hint_position, last_double_hint_position.line)
		return

	if hint_letter not in _jump_hints_single:
		return
	var jump_hint := _jump_hints_single.get(hint_letter) as JumpHint
	var jump_hint_position: CJTextPosition = jump_hint.text_editor_position
	jump_position_received.emit(jump_hint_position)

func _get_hint_double(letter: String) -> JumpHint:
	var result_hint: JumpHint = null
	for hint: JumpHint in _jump_hints_double.values():
		if hint.get_text().begins_with(letter):
			result_hint = hint
			break
	return result_hint

func _get_last_double_hint_position() -> CJTextPosition:
	return (_jump_hints_double.values()[_jump_hints_double.values().size() - 1] as JumpHint).text_editor_position

func _highlight_matches_async(from_position: CJTextPosition, to_line: int) -> void:
	var carets := _add_carets_at_words_start(from_position, to_line)
	var timer := _create_and_start_timer(0.3)
	await timer.timeout
	var jump_hints := _spawn_jump_hints(carets)
	_jump_hints_single = jump_hints["single"]
	_jump_hints_double = jump_hints["double"]
	_text_editor.remove_secondary_carets()
	timer.queue_free()

func _add_carets_at_words_start(from_position: CJTextPosition, to_line: int) -> Dictionary:
	var carets: Dictionary = {} # caret_index (int): word_position (CJTextPosition)
	var whole_words := CJUtils.get_visible_words_starting_with_letter(_text_editor, _jump_letter, from_position.line, to_line)
	var search_start := from_position
	var main_caret_position := _text_editor.get_line_column_at_pos(_text_editor.get_caret_draw_pos())
	print("search_start=%s" % search_start)
	for word in whole_words:
		var word_position := _text_editor.search(word, 2, search_start.line, search_start.column)
		var caret_index := _text_editor.add_caret(word_position.y, word_position.x) if main_caret_position != word_position else 0
		carets[caret_index] = CJTextPosition.new(word_position.y, word_position.x)
		print("word=%s, word_position=%s" % [word, word_position])
		search_start = CJTextPosition.new(word_position.y, word_position.x + 1)
	return carets

func _spawn_jump_hints(carets: Dictionary) -> Dictionary:
	var double_letter_count := carets.size() - LATIN_LETTERS_COUNT if carets.size() > LATIN_LETTERS_COUNT else 0
	var first_letter_code := 97 # ASCII code for 'a'
	var second_letter_code := 97
	var double_letter_used := double_letter_count > 0
	print("carets count = %s" % carets.size())

	var jump_hints_single: Dictionary = {} # hint_letter (string): jump_hint (JumpHint)
	var jump_hints_double: Dictionary = {}
	for caret_index in carets:
		var caret_word_position: CJTextPosition = carets[caret_index]
		var hint_letter := ""

		if double_letter_count > 0:
			hint_letter = char(first_letter_code) + char(second_letter_code)
			second_letter_code += 1
			if second_letter_code > 122: # ASCII code for 'z'
				first_letter_code += 1
				second_letter_code = 97
			double_letter_count -= 1
		else:
			if double_letter_used:
				first_letter_code += 1
				double_letter_used = false
			hint_letter = char(first_letter_code)
			first_letter_code += 1

		var jump_hint := _create_jump_hint(caret_word_position, hint_letter)
		if hint_letter.length() == 1:
			jump_hints_single[hint_letter] = jump_hint
		elif hint_letter.length() == 2:
			jump_hints_double[hint_letter] = jump_hint
		else:
			push_error("Zero or more than two letters in hint. hint=%s" % hint_letter)
		var caret_draw_position := _text_editor.get_caret_draw_pos(caret_index)
		_position_jump_hint(_text_editor, jump_hint.view, caret_draw_position)
		_text_editor.add_child(jump_hint.view)
		print("hint_letter=%s" % hint_letter)

	return {"single": jump_hints_single, "double": jump_hints_double}

func _create_jump_hint(text_editor_position: CJTextPosition, hint_letter: String) -> JumpHint:
	var jump_hint := JumpHint.new()
	jump_hint.view = _create_jump_hint_view(hint_letter)
	jump_hint.text_editor_position = text_editor_position
	return jump_hint

func _create_jump_hint_view(hint_letter: String) -> Label:
	var jump_hint_view = _jump_hint_scene.instantiate()
	jump_hint_view.text = hint_letter

	var font_size = _get_editor_settings().get_setting("interface/editor/code_font_size")
	jump_hint_view.set("theme_override_font_sizes/font_size", font_size)

	jump_hint_view.scale *= EditorInterface.get_editor_scale()
	return jump_hint_view

func _destroy_jump_hints(hints: Dictionary) -> void:
	for hint: JumpHint in hints.values():
		hint.destroy()
	hints.clear()

func _create_and_start_timer(time_sec: float) -> Timer:
	var timer = Timer.new()
	timer.one_shot = true
	_text_editor.add_child(timer)
	timer.start(time_sec)
	return timer

func _position_jump_hint(text_editor: TextEdit, jump_hint_view: Label, caret_position: Vector2) -> void:
	caret_position.y -= text_editor.get_line_height()
	caret_position.x -= jump_hint_view.size.x / 2
	jump_hint_view.set_position(caret_position)

func _get_editor_settings() -> EditorSettings:
	return EditorInterface.get_editor_settings()

func get_type() -> int:
	return CJStateType.LISTEN_HINT_LETTER
