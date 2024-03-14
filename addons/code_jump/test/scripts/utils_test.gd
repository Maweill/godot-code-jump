# GdUnit generated TestSuite
class_name CjUtilsTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://addons/code_jump/src/scripts/utils.gd'

#region Tests of get_words_starting_with_letter()
func test_basic_functionality() -> void:
	var text = "apple banana cherry date"
	var expected = ["apple"]
	var result = CJUtils.get_words_starting_with_letter(text, "a")
	assert_array(result).is_equal(expected)

func test_case_insensitivity() -> void:
	var text = "Apple Banana Cherry Date"
	var expected = ["Apple"]
	var result = CJUtils.get_words_starting_with_letter(text, "a")
	assert_array(result).is_equal(expected)

func test_words_with_symbols_before_letter() -> void:
	var text = "(apple) [banana] {cherry} date"
	var expected = ["apple"]
	var result = CJUtils.get_words_starting_with_letter(text, "a")
	assert_array(result).is_equal(expected)

func test_words_with_multiple_symbols_before_letter() -> void:
	var text = "{[apple]} [[banana]] {{cherry}} date"
	var expected = ["apple"]
	var result = CJUtils.get_words_starting_with_letter(text, "a")
	assert_array(result).is_equal(expected)

func test_no_matching_words() -> void:
	var text = "apple banana cherry date"
	var expected = []
	var result = CJUtils.get_words_starting_with_letter(text, "x")
	assert_array(result).is_equal(expected)

func test_empty_string() -> void:
	var text = ""
	var expected = []
	var result = CJUtils.get_words_starting_with_letter(text, "a")
	assert_array(result).is_equal(expected)

func test_special_characters_and_numbers() -> void:
	var text = "apple123 @banana $cherry date"
	var expected = ["apple123"]
	var result = CJUtils.get_words_starting_with_letter(text, "a")
	assert_array(result).is_equal(expected)

func test_uppercase_letter_as_input() -> void:
	var text = "Apple Banana Cherry Date"
	var expected = ["Apple"]
	var result = CJUtils.get_words_starting_with_letter(text, "A")
	assert_array(result).is_equal(expected)

func test_multiple_occurrences_of_same_word() -> void:
	var text = "apple banana apple cherry apple date"
	var expected = ["apple", "apple", "apple"]
	var result = CJUtils.get_words_starting_with_letter(text, "a")
	assert_array(result).is_equal(expected)

func test_words_with_hyphens_and_underscores() -> void:
	var text = "apple-pie banana_split cherry-date"
	var expected = ["apple-pie"]
	var result = CJUtils.get_words_starting_with_letter(text, "a")
	assert_array(result).is_equal(expected)

func test_function_name_with_parameters() -> void:
	var text = "function_name(text String)"
	var expected = ["text"]
	var result = CJUtils.get_words_starting_with_letter(text, "t")
	assert_array(result).is_equal(expected)

func test_variable_name_with_dot_notation() -> void:
	var text = "variable_name.v"
	var expected = ["variable_name", "v"]
	var result = CJUtils.get_words_starting_with_letter(text, "v")
	assert_array(result).is_equal(expected)

func test_cyrillic_characters() -> void:
	var text = "pple123 тест"
	var expected = ["тест"]
	var result = CJUtils.get_words_starting_with_letter(text, "т")
	assert_array(result).is_equal(expected)
#endregion
