# Code Jump

The Code Jump addon allows for fast cursor movement without using the mouse or cursor keys.

## 📋 Requirements

This addon is only compatible with Godot 4.0 or later.

## 📦 Installation

1. [Download Latest Release](https://github.com/Maweill/godot-code-jump/releases/latest)
2. Unpack the `addons/code_jump` folder into your `/addons` folder within the Godot project
3. Enable this addon within the Godot settings: `Project > Project Settings > Plugins`

## 🔍 How it Works

1. Press the `editor_settings/plugin/code_jump/activate` command to activate Code Jump.
2. Press a key corresponding to the initial letter of the word you want to jump to.
3. Code Jump will then display hint characters for all words starting with that letter.
4. Press the key matching the hint character of the desired word, and the cursor will instantly move to that word's position.

![example gif](https://s9.gifyu.com/images/SV3pF.gif)

## 📋 Commands

- `editor_settings/plugin/code_jump/activate`: Activates Code Jump and waits for an initial letter input.

## 🎨 Customizing the Hint Appearance

You can customize the appearance of the hint characters by adjusting the following settings:

- `editor_settings/plugin/code_jump/hint_font_color`: Changes the color of the hint characters.
- `editor_settings/plugin/code_jump/hint_background_color`: Changes the background color of the hint characters.
