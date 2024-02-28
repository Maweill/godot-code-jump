@tool
extends EditorPlugin

const CODE_JUMP_SETTING_NAME: StringName = &"plugin/code_jump/"
const ACTIVATE_PLUGIN_SHORTCUT_SETTING_NAME: StringName = CODE_JUMP_SETTING_NAME + &"activate"

#region Editor settings
var activate_plugin_shortcut: Shortcut
#endregion

var jump_hint_scene: PackedScene = preload("res://addons/code_jump/jump_hint.tscn")
var text_editor: TextEdit

var listening_for_jump_letter: bool
var listeting_for_navigation_letter: bool
var jump_letter: String

func _enter_tree() -> void:
	var editor_settings: EditorSettings = get_editor_settings()
	activate_plugin_shortcut = get_or_create_activate_plugin_shortcut(editor_settings)

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass

func _unhandled_key_input(event: InputEvent) -> void:
	if !(event is InputEventKey):
		return

	if listeting_for_navigation_letter and event.is_released():
		listeting_for_navigation_letter = false
		text_editor.grab_focus()
		return

	if !event.is_pressed():
		return

	var editor := EditorInterface.get_script_editor()
	text_editor = editor.get_current_editor().get_base_editor()

	if listening_for_jump_letter:
		listening_for_jump_letter = false
		listeting_for_navigation_letter = true

		jump_letter = (event as InputEventKey).as_text_key_label()
		print("jump_letter=%s" % jump_letter)
		highlight_matches()
		return

	if activate_plugin_shortcut.matches_event(event):
		listening_for_jump_letter = true
		listeting_for_navigation_letter = false
		print("listening for jump key")
		text_editor.release_focus()
		return

func highlight_matches() -> void:
	var first_visible_line_index := text_editor.get_first_visible_line()
	var last_visible_line_index := text_editor.get_last_full_visible_line()
	var visible_lines_text := ""

	for line_index in range(first_visible_line_index, last_visible_line_index + 1):
		visible_lines_text += text_editor.get_line(line_index)
	var whole_words: Array[String] = get_words_starting_with_letter(visible_lines_text, jump_letter)
	print("are words empty=%s" % whole_words.is_empty())

	# двигать каретку и линию после каждого нахождения и начинать поиск c нового места
	var line_search_start_index: int = first_visible_line_index
	var column_search_start_index: int = 0
	var search_result: Vector2i
	for word in whole_words:
		search_result = text_editor.search(word, 2, line_search_start_index, column_search_start_index)
		print("word=%s, search_result=%s" % [word, search_result])
		line_search_start_index = search_result.y
		column_search_start_index = search_result.x + 1

	var caret_index := text_editor.add_caret(search_result.y, search_result.x)
	await get_tree().create_timer(0.13).timeout
	var caret_position: Vector2 = text_editor.get_caret_draw_pos(caret_index)
	var jump_hint: Label = jump_hint_scene.instantiate()
	jump_hint.set_position(caret_position)
	text_editor.add_child(jump_hint)
	text_editor.remove_caret(caret_index)

	#text_editor.set_caret_line(search_result.y, false)
	#text_editor.set_caret_column(search_result.x, false)

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
