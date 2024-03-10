class_name CJListenHintLetterState
extends CJState

class JumpHint:
	var text_editor_position: Vector2i
	var view: Label

	func set_position(position: Vector2):
		view.set_global_position(position)

	func destroy():
		view.queue_free()

signal jump_position_received(position: Vector2i)

var _jump_hint_scene: PackedScene = preload("res://addons/code_jump/jump_hint.tscn")
var _text_editor: TextEdit
var _jump_letter: String
var _jump_hints: Dictionary = {}

func on_enter(model: CJModel) -> void:
	_text_editor = model.text_editor
	_jump_letter = model.jump_letter

	_text_editor.grab_focus()
	await _highlight_matches_async()
	_text_editor.release_focus()

func on_exit() -> void:
	_destroy_jump_hints(_jump_hints)

func on_input(event: InputEvent, viewport: Viewport) -> void:
	if not (event is InputEventKey and event.is_pressed()):
		return

	viewport.set_input_as_handled()
	var hint_letter = (event as InputEventKey).as_text_key_label().to_lower()
	if hint_letter not in _jump_hints:
		return
	var jump_hint := _jump_hints.get(hint_letter) as JumpHint
	var jump_hint_position: Vector2i = jump_hint.text_editor_position
	jump_position_received.emit(jump_hint_position)

func _highlight_matches_async() -> void:
	var carets := _add_carets_at_words_start()
	await _create_and_start_timer(0.15).timeout
	_jump_hints = _spawn_jump_hints(carets)
	_text_editor.remove_secondary_carets()

func _add_carets_at_words_start() -> Dictionary:
	var carets: Dictionary = {} # caret_index (int): word_position (Vector2i)
	var visible_lines_text := _get_visible_lines_text(_text_editor)
	var whole_words := _get_words_starting_with_letter(visible_lines_text, _jump_letter)
	var search_start := Vector2i(0, _text_editor.get_first_visible_line())
	var main_caret_position := _text_editor.get_line_column_at_pos(_text_editor.get_caret_draw_pos())
	for word in whole_words:
		var word_position := _text_editor.search(word, 2, search_start.y, search_start.x)
		var caret_index := _text_editor.add_caret(word_position.y, word_position.x) if main_caret_position != word_position else 0
		carets[caret_index] = word_position
		print("word=%s, word_position=%s" % [word, word_position])
		search_start = Vector2i(word_position.x + 1, word_position.y)
	return carets

func _spawn_jump_hints(carets: Dictionary) -> Dictionary:
	var jump_hints: Dictionary = {} # hint_letter (string): jump_hint (JumpHint)
	var hint_letter_code := 97 # ASCII code for 'a'
	for caret_index in carets:
		var caret_word_position: Vector2i = carets[caret_index]
		var hint_letter := char(hint_letter_code)
		var jump_hint := _create_jump_hint(caret_word_position, hint_letter)
		jump_hints[hint_letter] = jump_hint
		var caret_draw_position := _text_editor.get_caret_draw_pos(caret_index)
		_position_jump_hint(_text_editor, jump_hint.view, caret_draw_position)
		_text_editor.add_child(jump_hint.view)

		print("hint_letter=%s" % hint_letter)
		hint_letter_code += 1
	return jump_hints

func _create_jump_hint(text_editor_position: Vector2i, hint_letter: String) -> JumpHint:
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

func _position_jump_hint(text_editor: TextEdit, jump_hint_view: Label, caret_position: Vector2i) -> void:
	caret_position.y -= text_editor.get_line_height()
	caret_position.x -= jump_hint_view.size.x / 2
	jump_hint_view.set_position(caret_position)

func _get_visible_lines_text(text_editor: TextEdit) -> String:
	var first_visible_line_index := text_editor.get_first_visible_line()
	var last_visible_line_index := text_editor.get_last_full_visible_line()
	var lines := []
	for line_index in range(first_visible_line_index, last_visible_line_index + 1):
		lines.append(text_editor.get_line(line_index))
	return "\n".join(lines)

func _get_words_starting_with_letter(text: String, letter: String) -> Array[String]:
	# Regular expression to split the text by non-word characters
	var regex := RegEx.new()
	regex.compile("\\w+")

	# Split the string into words using the regex
	var words := regex.search_all(text)

	# Filter words that start with 'm'
	var filtered_words: Array[String] = []
	for word in words:
		var word_string := word.get_string()
		if word_string.begins_with(letter.to_lower()) or word_string.begins_with(letter.capitalize()): # Case-insensitive check
			filtered_words.append(word_string)

	return filtered_words

func _get_editor_settings() -> EditorSettings:
	return EditorInterface.get_editor_settings()

func get_type() -> int:
	return CJStateType.LISTEN_HINT_LETTER
