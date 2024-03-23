@tool
extends EditorPlugin

const CODE_JUMP_SETTING_NAME: StringName = &"plugin/code_jump/"
const ACTIVATE_PLUGIN_SHORTCUT_SETTING_NAME: StringName = CODE_JUMP_SETTING_NAME + &"activate"
const HINT_FONT_COLOR_SETTING_NAME: StringName = CODE_JUMP_SETTING_NAME + &"hint_font_color"
const HINT_BACKGROUND_COLOR_SETTING_NAME: StringName = CODE_JUMP_SETTING_NAME + &"hint_background_color"

var _model: CJModel
var _current_state: CJState
var _states: Dictionary

func _enter_tree() -> void:
	_model = CJModel.new()
	_model.settings = _get_plugin_settings()
	_init_states()
	_get_editor_settings().settings_changed.connect(_sync_settings)

func _exit_tree() -> void:
	_get_editor_settings().settings_changed.disconnect(_sync_settings)

func _unhandled_key_input(event: InputEvent) -> void:
	_current_state.on_input(event, get_viewport())

func _init_states() -> void:
	var idle_state := CJIdleState.new()
	var listen_jump_letter_state := CJListenJumpLetterState.new()
	var listen_hint_letter_state := CJListenHintLetterState.new()
	var jump_state := CJJumpState.new()
	_states[idle_state.get_type()] = idle_state
	_states[listen_jump_letter_state.get_type()] = listen_jump_letter_state
	_states[listen_hint_letter_state.get_type()] = listen_hint_letter_state
	_states[jump_state.get_type()] = jump_state

	idle_state.plugin_activated.connect(func(): _change_state(listen_jump_letter_state))
	listen_jump_letter_state.jump_letter_received.connect(
		func(letter: String):
			_model.jump_letter = letter
			_change_state(listen_hint_letter_state)
	)
	listen_jump_letter_state.cancelled.connect(
		func():
			_change_state(idle_state)
			_model.text_editor.grab_focus()
	)
	listen_hint_letter_state.jump_position_received.connect(
		func(position: CJTextPosition):
			_model.jump_position = position
			_change_state(jump_state)
	)
	listen_hint_letter_state.cancelled.connect(
		func():
			_change_state(idle_state)
			_model.text_editor.grab_focus()
	)
	jump_state.jumped.connect(func(): _change_state(idle_state))

	_change_state(idle_state)


func _change_state(state: CJState) -> void:
	if _current_state:
		_current_state.on_exit()
	_update_model(_model)
	_current_state = state
	_current_state.on_enter(_model)


func _update_model(model: CJModel) -> void:
	var text_editor := _get_current_text_editor()
	if text_editor == null:
		return
	model.text_editor = text_editor


func _get_plugin_settings() -> CJSettingsModel:
	var shortcut: Shortcut = Shortcut.new()
	var event: InputEventKey = InputEventKey.new()
	event.device = -1
	event.alt_pressed = true
	event.keycode = KEY_J
	shortcut.events = [ event ]
	var plugin_activation_shortcut: Shortcut = _get_setting(ACTIVATE_PLUGIN_SHORTCUT_SETTING_NAME, shortcut)
	var hint_font_color: Color = _get_setting(HINT_FONT_COLOR_SETTING_NAME, Color.BLACK)
	var hint_background_color: Color = _get_setting(HINT_BACKGROUND_COLOR_SETTING_NAME, Color.RED)
	return CJSettingsModel.new(plugin_activation_shortcut, hint_font_color, hint_background_color)


func _get_setting(property: StringName, alt: Variant) -> Variant:
	var editor_settings := _get_editor_settings()
	if (editor_settings.has_setting(property)):
		return editor_settings.get_setting(property)
	else:
		editor_settings.set_setting(property, alt)
		editor_settings.set_initial_value(property, alt, false)
		return alt


func _sync_settings() -> void:
	var plugin_activation_shortcut: Shortcut = _get_editor_settings().get_setting(ACTIVATE_PLUGIN_SHORTCUT_SETTING_NAME)
	var hint_font_color: Color = _get_editor_settings().get_setting(HINT_FONT_COLOR_SETTING_NAME)
	var hint_background_color: Color = _get_editor_settings().get_setting(HINT_BACKGROUND_COLOR_SETTING_NAME)
	_model.settings.update(plugin_activation_shortcut, hint_font_color, hint_background_color)


func _get_current_text_editor() -> TextEdit:
	var script_editor := EditorInterface.get_script_editor()
	var current_editor := script_editor.get_current_editor()
	if current_editor == null:
		return null
	var text_editor := current_editor.get_base_editor()
	return text_editor


func _get_editor_settings() -> EditorSettings:
	return EditorInterface.get_editor_settings()
