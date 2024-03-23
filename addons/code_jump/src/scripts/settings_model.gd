class_name CJSettingsModel

var plugin_activation_shortcut: Shortcut
var hint_font_color: Color
var hint_background_color: Color


func _init(
	plugin_activation_shortcut_value: Shortcut,
	hint_font_color_value: Color,
	hint_background_color_value: Color
) -> void:
	update(plugin_activation_shortcut_value, hint_font_color_value, hint_background_color_value)


func update(
	plugin_activation_shortcut_value: Shortcut,
	hint_font_color_value: Color,
	hint_background_color_value: Color
) -> void:
	plugin_activation_shortcut = plugin_activation_shortcut_value
	hint_font_color = hint_font_color_value
	hint_background_color = hint_background_color_value
