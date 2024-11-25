extends Control

#@onready var editor_scene = preload("res://assets/scenes/editor.tscn")
@onready var tab_container = $HSplitContainer/TabContainer
@onready var FileSystem = $HSplitContainer/FileSystem

func init_settings(editor):
	#var highlighter = editor.syntax_highlighter
	var highlighter = CodeHighlighter.new()
	
	editor.syntax_highlighter = highlighter

	editor.add_theme_font_size_override("font_size", 22)
	
	# Set gutters
	editor.gutters_draw_breakpoints_gutter = true
	editor.gutters_draw_bookmarks = true
	editor.gutters_draw_executing_lines = true
	editor.gutters_draw_line_numbers = true
	editor.gutters_draw_fold_gutter = true
	
	# Small settings
	editor.code_completion_enabled = true
	editor.indent_automatic = true
	
	editor.auto_brace_completion_enabled = true
	editor.auto_brace_completion_highlight_matching = true
	editor.scroll_smooth = false
	editor.minimap_draw = true
	editor.caret_type = 0 # 0 = line 1 = block
	editor.caret_blink = true
	editor.draw_tabs = true
	
	# Highlighting
	highlighter.number_color = Color("#a1ffe0")
	highlighter.symbol_color = Color("#abc9ff")
	highlighter.function_color = Color("#57b3ff")
	highlighter.member_variable_color = Color("#bce0ff")
	
	# Add keword color. In the future, the colors will probably be variables for customization
	# Keywords
	for keyword in ["if", "else", "elif", "switch", "case", "default", "break", "continue", "return", "for", "while", "do", "foreach"]:
		highlighter.add_keyword_color(keyword, Color("#ff8ccc"))
	
	# Member keywords
	for member_keyword in ["var", "int", "bool", "float", "double", "char", "string", "True", "true", "False", "false", "function", "def", "func", "class", "private", "method", "try", "catch", "finally", "throw", "and", "or", "not", "null", "undefined", "in", "final", "static", "let", "const", "export", "import", "internal", "extends", "super", "this"]:
		highlighter.add_member_keyword_color(member_keyword, Color("#ff7885"))
	
	# Color regions
	highlighter.add_color_region('"', '"', Color("#ffeda1"))
	highlighter.add_color_region("'", "'", Color("#ffeda1"))
	highlighter.add_color_region("#", "", Color("#9c9c9c"))
	highlighter.add_color_region("<", ">", Color("#ffeda1"))
	highlighter.add_color_region("//", "", Color("#ffeda1"))
	highlighter.add_color_region("/*", "*/", Color("#ffeda1"))
	
	return editor

func add_tab(file):
	# Called when a new tab is open
	var editor = CodeEdit.new()
	
	editor.name = file
	print(editor)
	editor = init_settings(editor)
	
	print(file + " created")
	
	# Add to tab container
	tab_container.add_child(editor)
	
	# Set the current tab to the latest one. AKA the amount of children minus one
	tab_container.current_tab = tab_container.get_child_count() - 1
	
func _ready():
	initiate_files("res://")
	
func _process(delta):
	if Input.is_action_just_pressed("New Tab"):
		add_tab("New Tab")
	if Input.is_action_just_pressed("Close Tab"):
		tab_container.get_current_tab_control().queue_free() # Delete selected tab
	if Input.is_action_just_pressed("Save File"):
		$FileDialog.show()
		# Later, fix it so it doesn't still type S (issue #88768 on Godot Github)

func _on_file_dialog_file_selected(path):
	print(path)
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(tab_container.get_current_tab_control().text)
	
func _on_file_pressed(button):
	print(button.text)
	
func initiate_files(path):
	FileSystem.create_item().set_text(0, path)
	
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			else:
				print("Found file: " + file_name)
			file_name = dir.get_next()
			var item = FileSystem.create_item()
			
			item.set_text(0, file_name)
			item.set_icon_max_width(0, 30)
			item.set_icon(0, load("res://assets/icons/folder.svg"))
	
	#item.button_clicked

func open_dir():
	print("Thingy happened")

func _on_welcome_pressed():
	var dialog = FileDialog.new()
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.use_native_dialog = true
	print(dialog.current_dir)
	#dialog.dir_selected.connect(open_dir.bind(path))
	dialog.show()
