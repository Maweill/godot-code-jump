@tool
extends EditorPlugin

const CODE_JUMP_SETTING_NAME: StringName = &"plugin/code_jump/"
const ACTIVATE_PLUGIN_SHORTCUT_SETTING_NAME: StringName = CODE_JUMP_SETTING_NAME + &"activate"

var _model: CJModel
var _current_state: CJState
var _states: Dictionary

func _enter_tree() -> void:
	_model = CJModel.new()
	init_states()

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass

func _unhandled_key_input(event: InputEvent) -> void:
	_current_state.on_input(event, get_viewport())

func init_states() -> void:
	var idle_state := CJIdleState.new()
	var listen_jump_letter_state := CJListenJumpLetterState.new()
	var listen_hint_letter_state := CJListenHintLetterState.new()
	var jump_state := CJJumpState.new()
	_states[idle_state.get_type()] = idle_state
	_states[listen_jump_letter_state.get_type()] = listen_jump_letter_state
	_states[listen_hint_letter_state.get_type()] = listen_hint_letter_state
	_states[jump_state.get_type()] = jump_state

	idle_state.plugin_activated.connect(func(): change_state(listen_jump_letter_state))
	listen_jump_letter_state.jump_letter_received.connect(
		func(letter: String):
			_model.jump_letter = letter
			change_state(listen_hint_letter_state)
	)
	listen_jump_letter_state.cancelled.connect(
		func():
			change_state(idle_state)
			_model.text_editor.grab_focus()
	)
	listen_hint_letter_state.jump_position_received.connect(
		func(position: Vector2i):
			_model.jump_position = position
			change_state(jump_state)
	)
	listen_hint_letter_state.cancelled.connect(
		func():
			change_state(idle_state)
			_model.text_editor.grab_focus()
	)
	jump_state.jumped.connect(func(): change_state(idle_state))

	change_state(idle_state)

func update_model(model: CJModel) -> void:
	var editor_settings: EditorSettings = EditorInterface.get_editor_settings()
	model.plugin_shortcut = get_or_create_activate_plugin_shortcut(editor_settings)

	var text_editor := get_current_text_editor()
	if text_editor == null:
		return
	model.text_editor = text_editor

func change_state(state: CJState) -> void:
	if _current_state:
		_current_state.on_exit()
	update_model(_model)
	_current_state = state
	_current_state.on_enter(_model)

func get_or_create_activate_plugin_shortcut(editor_settings: EditorSettings) -> Variant:
	if (!editor_settings.has_setting(ACTIVATE_PLUGIN_SHORTCUT_SETTING_NAME)):
		var shortcut: Shortcut = Shortcut.new()
		var event: InputEventKey = InputEventKey.new()
		event.device = -1
		event.alt_pressed = true
		event.keycode = KEY_J

		shortcut.events = [ event ]
		editor_settings.set_setting(ACTIVATE_PLUGIN_SHORTCUT_SETTING_NAME, shortcut)
		editor_settings.set_initial_value(ACTIVATE_PLUGIN_SHORTCUT_SETTING_NAME, shortcut, false)

	return editor_settings.get_setting(ACTIVATE_PLUGIN_SHORTCUT_SETTING_NAME)

func get_current_text_editor() -> TextEdit:
	var script_editor := EditorInterface.get_script_editor()
	var current_editor := script_editor.get_current_editor()
	if current_editor == null:
		return null
	var text_editor := current_editor.get_base_editor()
	return text_editor
