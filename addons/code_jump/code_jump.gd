@tool
extends EditorPlugin

class JumpHint:
	var text_editor_position: Vector2i
	var view: Label

	func set_position(position: Vector2):
		view.set_global_position(position)

	func hide():
		view.hide()

const CODE_JUMP_SETTING_NAME: StringName = &"plugin/code_jump/"
const ACTIVATE_PLUGIN_SHORTCUT_SETTING_NAME: StringName = CODE_JUMP_SETTING_NAME + &"activate"

#region Editor settings
var activate_plugin_shortcut: Shortcut
#endregion

var jump_hint_scene: PackedScene = preload("jump_hint.tscn")
var text_editor: TextEdit

#TODO Локальные переменные с нижнего подчеркивания
var listening_for_jump_letter: bool
var listening_for_navigation_letter: bool
var jump_letter: String
var jump_hints: Dictionary = {}

var _model: CJModel
var current_state: CJState
var states: Dictionary

func _enter_tree() -> void:
	_model = CJModel.new()
	init_states()

	var editor_settings: EditorSettings = get_editor_settings()
	activate_plugin_shortcut = get_or_create_activate_plugin_shortcut(editor_settings)

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass

func _unhandled_key_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.is_pressed()):
		return

	var script_editor := EditorInterface.get_script_editor()
	text_editor = script_editor.get_current_editor().get_base_editor()

	# 3
	if listening_for_navigation_letter:
		get_viewport().set_input_as_handled()
		text_editor.grab_focus()
		listening_for_navigation_letter = false

		var navigation_letter = (event as InputEventKey).as_text_key_label().to_lower()
		print("navigation_letter=%s" % navigation_letter)

		hide_jump_hints(jump_hints)
		var jump_hint_position: Vector2i = (jump_hints.get(navigation_letter) as JumpHint).text_editor_position
		text_editor.set_caret_line(jump_hint_position.y, false)
		text_editor.set_caret_column(jump_hint_position.x, false)
		return

	# 2
	if listening_for_jump_letter:
		get_viewport().set_input_as_handled()
		listening_for_jump_letter = false
		listening_for_navigation_letter = true

		jump_letter = (event as InputEventKey).as_text_key_label()
		print("jump_letter=%s" % jump_letter)
		text_editor.grab_focus()
		await highlight_matches_async()
		text_editor.release_focus()
		return

	# 1
	if activate_plugin_shortcut.matches_event(event):
		get_viewport().set_input_as_handled()
		listening_for_jump_letter = true
		listening_for_navigation_letter = false
		text_editor.release_focus()
		print("listening for jump key")
		return

func init_states() -> void:
	var idle_state := CJIdleState.new()
	var listen_jump_letter_state := CJListenJumpLetterState.new()
	var listen_hint_letter_state := CJListenHintLetterState.new()
	pass

func change_state(state: CJState) -> void:
	if current_state:
		current_state.on_exit()
	current_state = state
	current_state.on_enter(_model)

func highlight_matches_async() -> void:
	var visible_lines_text := get_visible_lines_text(text_editor)
	var whole_words := get_words_starting_with_letter(visible_lines_text, jump_letter)

	var search_start := Vector2i(0, text_editor.get_first_visible_line())
	var hint_letter_code := 97 # ASCII code for 'a'
	for word in whole_words:
		var word_position := text_editor.search(word, 2, search_start.y, search_start.x)
		var hint_letter = char(hint_letter_code)
		await create_and_display_jump_hint(word, word_position, hint_letter)

		print("word=%s, word_position=%s" % [word, word_position])
		print("hint_letter=%s" % hint_letter)

		search_start = Vector2i(word_position.x + 1, word_position.y)
		hint_letter_code += 1

func get_visible_lines_text(text_editor: TextEdit) -> String:
	var first_visible_line_index := text_editor.get_first_visible_line()
	var last_visible_line_index := text_editor.get_last_full_visible_line()
	var lines := []
	for line_index in range(first_visible_line_index, last_visible_line_index + 1):
		lines.append(text_editor.get_line(line_index))
	return "\n".join(lines)

func create_and_display_jump_hint(word: String, search_result: Vector2i, hint_letter: String) -> void:
	var caret_index := text_editor.add_caret(search_result.y, search_result.x)
	await get_tree().create_timer(0.13).timeout

	var jump_hint = create_jump_hint(search_result, hint_letter)
	jump_hints[hint_letter] = jump_hint

	position_jump_hint(text_editor, jump_hint.view, caret_index)
	text_editor.add_child(jump_hint.view)

	text_editor.remove_caret(caret_index)

func create_jump_hint(text_editor_position: Vector2i, hint_letter: String) -> JumpHint:
	var jump_hint := JumpHint.new()
	jump_hint.view = create_jump_hint_view(hint_letter)
	jump_hint.text_editor_position = text_editor_position
	return jump_hint

func create_jump_hint_view(hint_letter: String) -> Label:
	var jump_hint_view = jump_hint_scene.instantiate()
	jump_hint_view.text = hint_letter

	var font_size = get_editor_settings().get_setting("interface/editor/code_font_size")
	jump_hint_view.set("theme_override_font_sizes/font_size", font_size)

	jump_hint_view.scale *= EditorInterface.get_editor_scale()
	return jump_hint_view

func position_jump_hint(text_editor: TextEdit, jump_hint_view: Label, caret_index: int) -> void:
	var caret_position := text_editor.get_caret_draw_pos(caret_index)
	caret_position.y -= text_editor.get_line_height()
	caret_position.x -= jump_hint_view.size.x / 2
	jump_hint_view.set_position(caret_position)

func hide_jump_hints(hints: Dictionary) -> void:
	for hint: JumpHint in hints.values():
		hint.hide()

func get_words_starting_with_letter(text: String, letter: String) -> Array[String]:
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

func get_or_create_activate_plugin_shortcut(editor_settings: EditorSettings) -> Variant:
	if (!editor_settings.has_setting(ACTIVATE_PLUGIN_SHORTCUT_SETTING_NAME)):
		var shortcut: Shortcut = Shortcut.new()
		var event: InputEventKey = InputEventKey.new()
		event.device = -1
		event.alt_pressed = true
		event.keycode = KEY_J

		shortcut.events = [ event ]
		editor_settings.set_setting(ACTIVATE_PLUGIN_SHORTCUT_SETTING_NAME, shortcut)
		editor_settings.set_initial_value(ACTIVATE_PLUGIN_SHORTCUT_SETTING_NAME, shortcut, false)

	return editor_settings.get_setting(ACTIVATE_PLUGIN_SHORTCUT_SETTING_NAME)

func get_editor_settings() -> EditorSettings:
	return EditorInterface.get_editor_settings()
