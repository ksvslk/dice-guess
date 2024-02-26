extends VBoxContainer

onready var title = $Title
onready var subtitle = $Subtitle
onready var loading_bar = $Title/LoadingBar

export (String) var title_text = ""
export (String) var subtitle_text = ""
export (Color) var title_color = Color.white

func _ready():
	title.text = title_text
	subtitle.text = subtitle_text
	title.modulate = title_color
	if subtitle_text == "":
		subtitle.visible = false
		

func set_title(s):
	title_text = s
	title.text = title_text


func set_subtitle(s):
	subtitle_text = s
	subtitle.text = subtitle_text


func start_loading():
	loading_bar.start_loading()

func stop_loading():
	loading_bar.end_loading()
