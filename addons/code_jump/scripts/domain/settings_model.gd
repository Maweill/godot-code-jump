class_name CJSettingsModel

var letter_plugin_activation_shortcut: Shortcut
var words_plugin_activation_shortcut: Shortcut
var hint_font_color: Color
var hint_background_color: Color


func _init(
	letter_plugin_activation_shortcut_value: Shortcut,
	words_plugin_activation_shortcut_value: Shortcut,
	hint_font_color_value: Color,
	hint_background_color_value: Color
) -> void:
	update(letter_plugin_activation_shortcut_value, words_plugin_activation_shortcut_value, hint_font_color_value, hint_background_color_value)


func update(
	letter_plugin_activation_shortcut_value: Shortcut,
	words_plugin_activation_shortcut_value: Shortcut,
	hint_font_color_value: Color,
	hint_background_color_value: Color
) -> void:
	letter_plugin_activation_shortcut = letter_plugin_activation_shortcut_value
	words_plugin_activation_shortcut = words_plugin_activation_shortcut_value
	hint_font_color = hint_font_color_value
	hint_background_color = hint_background_color_value
