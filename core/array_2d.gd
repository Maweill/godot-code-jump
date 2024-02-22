class_name Array2D

# Приватные переменные для хранения данных массива и его размеров
var _array := []
var _width := 0
var _height := 0

# Конструктор для инициализации двумерного массива
func _init(width: int, height: int) -> void:
	_width = width
	_height = height
	_array.resize(width * height)

# Функция для получения значения по координатам
func get_value(x: int, y: int) -> Variant:
	var index := y * _width + x
	return _array[index]

# Функция для установки значения по координатам
func set_value(x: int, y: int, value: Variant) -> void:
	var index := y * _width + x
	_array[index] = value

# Опционально: метод для вывода массива в консоль
func print_array() -> void:
	for y in range(_height):
		var row := ""
		for x in range(_width):
			row += str(get_value(x, y)) + " "
		print(row)
