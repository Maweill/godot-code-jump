class_name CJUtils

static func get_visible_words_starting_with_letter(text_editor: TextEdit, letter: String) -> Array[String]:
	var visible_lines_text := get_visible_lines_text(text_editor)
	return get_words_starting_with_letter(visible_lines_text, letter)

static func get_visible_lines_text(text_editor: TextEdit) -> String:
	var first_visible_line_index := text_editor.get_first_visible_line()
	var last_visible_line_index := text_editor.get_last_full_visible_line()
	var lines := []
	for line_index in range(first_visible_line_index, last_visible_line_index + 1):
		lines.append(text_editor.get_line(line_index))
	return "\n".join(lines)

static func get_words_starting_with_letter(text: String, letter: String) -> Array[String]:
	var regex := RegEx.new()
	regex.compile("[\\p{L}\\d_]+-?[\\p{L}\\d_]*")
	var words := regex.search_all(text)
	var filtered_words: Array[String] = []
	for word in words:
		var word_string = word.get_string()
		var word_string_lower := word_string.to_lower()
		var letter_lower = letter.to_lower()
		if word_string_lower.begins_with(letter_lower):
			filtered_words.append(word_string)
		elif word_string.begins_with("_") \
		and word_string.length() > 1 \
		and word_string_lower[1] == letter_lower:
			filtered_words.append(word_string)
	return filtered_words
