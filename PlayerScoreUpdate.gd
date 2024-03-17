extends HBoxContainer

onready var trophy = $Trophy
onready var arrows = $Arrows
onready var label = $Score

func _ready():
	modulate.a = 0
	GSteam.connect("score_uploaded", self, "animate_score")
	

func _exit_tree():
	GSteam.disconnect("score_uploaded", self, "animate_score")


func animate_score(this_score:Dictionary) -> void:
	if this_score["score_changed"] == 1 && this_score.has("global_rank_new") && this_score.has("global_rank_prev") && this_score.has("score"):
		var new_score = this_score["score"]
		var new_rank = this_score["global_rank_new"]
		var prev_rank = this_score["global_rank_prev"]
		if new_rank && new_score && new_rank > prev_rank:
			# Initially, everything is invisible
			label.modulate.a = 0
			arrows.modulate.a = 0
			modulate.a = 1
			# Update the score text
			label.text = "#" + str(new_rank)
			
			# Determine if the trophy should be animated
			var animate_trophy = true
			arrows.visible = false
			if new_rank == 1:
				trophy.modulate = Color.gold
				trophy.end_color = Color.yellow
				trophy.start_color = Color.gold
			elif new_rank == 2:
				trophy.modulate = Color.silver
				trophy.end_color = Color.whitesmoke
				trophy.start_color = Color.silver
			elif new_rank == 3:
				trophy.modulate = Color.sienna
				trophy.end_color = Color.saddlebrown
				trophy.start_color = Color.sienna
			else:
				arrows.visible = true
				trophy.visible = false
			trophy.modulate.a = 0
				
			# Start animation sequence
			var tween = get_tree().create_tween()
			# Fade in all elements
			tween.tween_property(label, "modulate:a", 1, 1).set_trans(Tween.TRANS_SINE)
			tween.tween_property(arrows, "modulate:a", 1, 1).set_trans(Tween.TRANS_SINE).connect("finished", arrows, "start_animating")
			tween.tween_property(trophy, "modulate:a", 1, 1).set_trans(Tween.TRANS_SINE).connect("finished", trophy, "start_animating")
			tween.tween_interval(4)
			tween.tween_property(trophy, "modulate:a", 0, 1).set_trans(Tween.TRANS_SINE).connect("finished", trophy, "stop_animating")
			tween.tween_property(arrows, "modulate:a", 0, 1).set_trans(Tween.TRANS_SINE).connect("finished", arrows, "stop_animating")
			tween.tween_property(label, "modulate:a", 0, 1).set_trans(Tween.TRANS_SINE)
			tween.play()

