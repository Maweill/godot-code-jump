class_name CJListenHintLetterState
extends CJState

class JumpHint:
	var text_editor_position: CJTextPosition
	var view: Label

	#TODO Сделать getter-ом
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

var _jump_hints: Array[JumpHint] = []

func on_enter(model: CJModel) -> void:
	_text_editor = model.text_editor
	_jump_letter = model.jump_letter
	_text_editor.grab_focus()
	var highlight_from_position = CJTextPosition.new(_text_editor.get_first_visible_line(), 0)
	await _highlight_matches_async(highlight_from_position, _text_editor.get_last_full_visible_line() + 1)
	_text_editor.release_focus()

	print("listening for hint key")

func on_exit() -> void:
	_destroy_jump_hints(_jump_hints)

func on_input(event: InputEvent, viewport: Viewport) -> void:
	if not (event is InputEventKey and event.is_pressed()):
		return

	viewport.set_input_as_handled()
	var input_event_key: InputEventKey = event as InputEventKey
	if input_event_key.keycode == KEY_ESCAPE:
		cancelled.emit()
		return

	var hint_letter = input_event_key.as_text_key_label().to_lower()

	var double_hints_starting_with_letter := _get_double_hints_starting_with_letter(hint_letter)
	if double_hints_starting_with_letter.size() > 0:
		var double_hint := double_hints_starting_with_letter.front() as JumpHint
		var hint_second_letter := double_hint.get_text()[1]
		print("hint_second_letter=%s" % hint_second_letter)

		var first_double_hint_position := double_hint.text_editor_position
		var last_double_hint_starting_with_letter := _get_double_hints_starting_with_letter(hint_letter).back() as JumpHint
		var last_double_hint_position := last_double_hint_starting_with_letter.text_editor_position

		_destroy_jump_hints(_jump_hints)

		_highlight_matches_async(first_double_hint_position, last_double_hint_position.line)
		return

	var jump_hint := _find_jump_hint(hint_letter)
	if jump_hint == null:
		return
	var jump_hint_position: CJTextPosition = jump_hint.text_editor_position
	jump_position_received.emit(jump_hint_position)

func _highlight_matches_async(from_position: CJTextPosition, to_line: int) -> void:
	var carets := _add_carets_at_words_start(from_position, to_line)
	var timer := _create_and_start_timer(0.3)
	await timer.timeout
	_jump_hints = _spawn_jump_hints(carets)
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

func _spawn_jump_hints(carets: Dictionary) -> Array[JumpHint]:
	var double_letter_count := carets.size() - LATIN_LETTERS_COUNT if carets.size() > LATIN_LETTERS_COUNT else 0
	var first_letter_code := 97 # ASCII code for 'a'
	var second_letter_code := 97
	var double_letter_used := double_letter_count > 0
	print("carets count = %s" % carets.size())

	var jump_hints: Array[JumpHint] = []
	for caret_index in carets:
		var caret_word_position: CJTextPosition = carets[caret_index]
		var hint_text := ""

		if double_letter_count > 0:
			hint_text = char(first_letter_code) + char(second_letter_code)
			second_letter_code += 1
			if second_letter_code > 122: # ASCII code for 'z'
				first_letter_code += 1
				second_letter_code = 97
			double_letter_count -= 1
		else:
			if double_letter_used:
				first_letter_code += 1
				double_letter_used = false
			hint_text = char(first_letter_code)
			first_letter_code += 1

		var jump_hint := _create_jump_hint(caret_word_position, hint_text)
		jump_hints.append(jump_hint)
		var caret_draw_position := _text_editor.get_caret_draw_pos(caret_index)
		_position_jump_hint(_text_editor, jump_hint.view, caret_draw_position)
		_text_editor.add_child(jump_hint.view)
		print("hint_text=%s" % hint_text)

	return jump_hints

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

func _destroy_jump_hints(hints: Array[JumpHint]) -> void:
	for hint: JumpHint in hints:
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

func _get_double_hints_starting_with_letter(letter: String) -> Array[JumpHint]:
	return _get_double_hints().filter(func(hint: JumpHint): return hint.get_text().begins_with(letter))

func _get_double_hints() -> Array[JumpHint]:
	return _jump_hints.filter(func(hint: JumpHint): return hint.get_text().length() == 2)

func _find_jump_hint(hint_text: String) -> JumpHint:
	return GD_.find(_jump_hints, func(hint: JumpHint, _index): return hint.get_text() == hint_text) as JumpHint

func get_type() -> int:
	return CJStateType.LISTEN_HINT_LETTER
