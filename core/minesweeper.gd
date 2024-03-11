class_name Minesweeper

var _board: Array2D

func create(width: int, height: int, mines_count: int) -> void:
	_board = Array2D.new(3, 2)
	for column_index in range(width):
		for row_index in range(height):
			var cell := Cell.new()
			cell.is_mine = true
			_board.set_value(column_index, row_index, cell)
