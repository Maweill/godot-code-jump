# GdUnit generated TestSuite
class_name Array2dTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://core/array_2d.gd'

func test_init() -> void:
	var array_2d = Array2D.new(3, 2)
	assert_int(array_2d._width).is_equal(3)
	assert_int(array_2d._height).is_equal(2)
	assert_array(array_2d._array).has_size(6)

func test_set_get_value() -> void:
	var array_2d = Array2D.new(3, 2)
	var x = 2
	var y = 1
	var value = "test_value"
	array_2d.set_value(x, y, value)
	
	var wrong_value = array_2d.get_value(1, 1)
	assert_object(wrong_value).is_null()
	
	var right_value = array_2d.get_value(x, y)
	assert_str(right_value).is_equal(value)
