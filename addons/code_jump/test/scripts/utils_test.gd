# GdUnit generated TestSuite
class_name CjUtilsTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://addons/code_jump/src/scripts/utils.gd'


func test_get_words_starting_with_letter() -> void:
	# Test case 1: Basic functionality
	var text1 = "apple banana cherry date"
	var expected1 = ["apple"]
	var result1 = CJUtils.get_words_starting_with_letter(text1, "a")
	assert_array(result1).is_equal(expected1)

	# Test case 2: Case-insensitivity м
	var text2 = "Apple Banana Cherry Date"
	var expected2 = ["Apple"]
	var result2 = CJUtils.get_words_starting_with_letter(text2, "a")
	assert_array(result2).is_equal(expected2)

	# Test case 3: Words with symbols before the letter
	var text3 = "(apple) [banana] {cherry} date"
	var expected3 = ["apple"]
	var result3 = CJUtils.get_words_starting_with_letter(text3, "a")
	assert_array(result3).is_equal(expected3)

	# Test case 4: Words with multiple symbols before the letter
	var text4 = "{[apple]} [[banana]] {{cherry}} date"
	var expected4 = ["apple"]
	var result4 = CJUtils.get_words_starting_with_letter(text4, "a")
	assert_array(result4).is_equal(expected4)

	# Test case 5: No matching words
	var text5 = "apple banana cherry date"
	var expected5 = []
	var result5 = CJUtils.get_words_starting_with_letter(text5, "x")
	assert_array(result5).is_equal(expected5)

	# Test case 6: Empty string
	var text6 = ""
	var expected6 = []
	var result6 = CJUtils.get_words_starting_with_letter(text6, "a")
	assert_array(result6).is_equal(expected6)

	# Test case 7: Special characters and numbers
	var text7 = "apple123 @banana $cherry date"
	var expected7 = ["apple123"]
	var result7 = CJUtils.get_words_starting_with_letter(text7, "a")
	assert_array(result7).is_equal(expected7)

	# Test case 8: Uppercase letter as input
	var text8 = "Apple Banana Cherry Date"
	var expected8 = ["Apple"]
	var result8 = CJUtils.get_words_starting_with_letter(text8, "A")
	assert_array(result8).is_equal(expected8)

	# Test case 9: Multiple occurrences of the same word
	var text9 = "apple banana apple cherry apple date"
	var expected9 = ["apple", "apple", "apple"]
	var result9 = CJUtils.get_words_starting_with_letter(text9, "a")
	assert_array(result9).is_equal(expected9)

	# Test case 10: Words with hyphens and underscores
	var text10 = "apple-pie banana_split cherry-date"
	var expected10 = ["apple-pie"]
	var result10 = CJUtils.get_words_starting_with_letter(text10, "a")
	assert_array(result10).is_equal(expected10)

	# Test case 11:
	var text11 = "function_name(text String)"
	var expected11 = ["text"]
	var result11 = CJUtils.get_words_starting_with_letter(text11, "t")
	assert_array(result11).is_equal(expected11)

	# Test case 12:
	var text12 = "variable_name.x"
	var expected12 = ["x"]
	var result12 = CJUtils.get_words_starting_with_letter(text12, "x")
	assert_array(result12).is_equal(expected12)

	# Test case 13:
	var text13 = "pple123 @pple $pple pple"
	var expected13 = ["pple123", "pple"]
	var result13 = CJUtils.get_words_starting_with_letter(text13, "p")
	assert_array(result13).is_equal(expected13)
