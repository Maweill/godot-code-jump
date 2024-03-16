class_name CJUtils

static func get_visible_words_starting_with_letter(text_editor: TextEdit, letter: String, from_line: int, to_line: int) -> Array[String]:
	var visible_lines_text := get_visible_lines_text(text_editor, from_line, to_line)
	return get_words_starting_with_letter(visible_lines_text, letter)

static func get_visible_lines_text(text_editor: TextEdit, from_line: int, to_line: int) -> String:
	var lines := []
	for line_index in range(from_line, to_line + 1):
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
