@tool
extends EditorPlugin

const CODE_JUMP_SETTING_NAME: StringName = &"plugin/code_jump/"
const ACTIVATE_PLUGIN_SHORTCUT_SETTING_NAME: StringName = CODE_JUMP_SETTING_NAME + &"activate"

#region Editor settings
var activate_plugin_shortcut: Shortcut
#endregion

func _enter_tree() -> void:
	var editor_settings: EditorSettings = get_editor_settings()
	activate_plugin_shortcut = get_or_create_activate_plugin_shortcut(editor_settings)

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass

func _unhandled_key_input(event: InputEvent) -> void:
	if !(event is InputEventKey):
		return

	if (activate_plugin_shortcut.matches_event(event)):
		var editor = EditorInterface.get_script_editor()
		var text_editor = editor.get_current_editor().get_base_editor()
		var first_visible_line_index = text_editor.get_first_visible_line()
		var last_visible_line_index = text_editor.get_last_full_visible_line()
		var visible_lines_text = ""
		# спавним по курсору на каждое слово
		# меняем первую букву на "a", "b", "c"...
		# ждем ввода пользователя
		# перемещаем курсор к выбранному слову
		# возвращаем первые буквы в исходное
		for line_index in range(first_visible_line_index, last_visible_line_index + 1):
			visible_lines_text += text_editor.get_line(line_index)
		var whole_words = get_words_starting_with_letter(visible_lines_text, "g")
		print("whole_words=%s" % whole_words.is_empty())
		var search_result = text_editor.search(whole_words[0], 2, first_visible_line_index, 0)
		print("search_result=%s" % search_result)
		text_editor.set_caret_line(search_result.y, false)
		text_editor.set_caret_column(search_result.x, false)

func get_words_starting_with_letter(text: String, letter: String) -> Array[String]:
	# Regular expression to split the text by non-word characters
	var regex = RegEx.new()
	regex.compile("\\w+")

	# Split the string into words using the regex
	var words := regex.search_all(text)

	# Filter words that start with 'm'
	var filtered_words: Array[String] = []
	for word in words:
		var word_string = word.get_string()
		print("WORD_STRING=%s" % word_string)
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
	return get_editor_interface().get_editor_settings()
