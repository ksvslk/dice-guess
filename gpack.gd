extends Node

var ios_plugin = null
var game_center = null
var icloud = null

var android_plugin = null
var plugin = null

var current_ad = ""
var haptic_enabled = true

const is_amazon = false


func _ready():
	if Engine.has_singleton("GPack"):
		android_plugin = Engine.get_singleton("GPack")
	if Engine.has_singleton("IPack"):
		ios_plugin = Engine.get_singleton("IPack")
	if Engine.has_singleton("GameCenter"):
		game_center = Engine.get_singleton("GameCenter")
		game_center.authenticate()
	if Engine.has_singleton("ICloud"):
		icloud = Engine.get_singleton("ICloud")
	else:
		print("iOS Game Center plugin is not available on this platform.")


func is_signed_in() -> bool:
	if android_plugin && !is_amazon:
		return android_plugin.isSignedIn()
	elif game_center:
		return game_center.is_authenticated()
	return false
	
func ask_for_review():
	if GPack.android_plugin && !is_amazon:
		android_plugin.askForReview()
	elif Engine.has_singleton("InAppStore"):
		var ias = Engine.get_singleton("InAppStore")
		ias.ask_for_review()
	

################
# ACHIEVEMENTS #
################

func unlock_achievement(id: String) -> void:
	if android_plugin && !is_amazon:
		android_plugin.unlockAchievement(id)
	elif game_center:
		game_center.award_achievement({ 
				"name":id,
				"progress":100.0,
				"show_completion_banner":true
		})


func show_achievements() -> void:
	if android_plugin && !is_amazon:
		android_plugin.showAchievements()
	elif game_center:
		game_center.show_game_center({ "view":"achievements" })


################
# LEADERBOARD  #
################


func submit_score() -> void:
	var score = Data.get_total_score()
	if android_plugin && !is_amazon:
		android_plugin.submitScore(score, C.leaderboard_id)
	elif game_center:
		game_center.post_score({ "score": score, "category": C.leaderboard_id, })
	

func show_leaderboard() -> void:
	if android_plugin && !is_amazon:
		android_plugin.showLeaderboard(C.leaderboard_id)
	elif game_center:
		game_center.show_game_center({ "view":"leaderboards" })

################
#   FIREBASE   #
################

func log_event(event_name: String, dictionary: Dictionary) -> void:
	if android_plugin && !is_amazon:
		android_plugin.logEvent(event_name, dictionary)


################
#    ADMOB     #
################

func load_rewarded_ad() -> void:
	if android_plugin && !is_amazon:
		android_plugin.loadRewardedAd()


func is_rewarded_ad_loaded() -> bool:
	if android_plugin && !is_amazon:
		return android_plugin.isRewardedAdLoaded()
	return false


func show_rewarded_ad(ad_category: String) -> void:
	if android_plugin && !is_amazon:
		current_ad = ad_category
		android_plugin.showRewardedAd()


################
#  SAVE GAME   #
################

func save_game(data: Dictionary, progress: int) -> void:
	if android_plugin && !is_amazon:
		android_plugin.saveGame(data, progress)
	elif icloud:
		data["progress"] = progress
		var _result = icloud.set_key_values(data)


func load_game() -> void:
	if android_plugin && !is_amazon:
		android_plugin.loadGame()
	elif icloud:
		var game_data = icloud.get_all_key_values()
		if not game_data.empty():
			Data.load_game(game_data)


func perform_haptic_feedback(constant:int) -> void:
	if android_plugin and haptic_enabled:
		android_plugin.performHapticFeedback(constant)
	elif ios_plugin and haptic_enabled:
		if constant == C.tap_vibration:
			ios_plugin.impact_occurred_custom(0.4)
		elif constant == C.soft_vibration:
			ios_plugin.impact_occurred_custom(0.2)
		elif constant == C.fail_vibration:
			ios_plugin.notification_occurred_custom(2)
		elif constant == C.success_vibration:
			ios_plugin.notification_occurred_custom(0)


# Signals you can connect to in the Android plugin.
# Prefixed by "s" so they would be recognized more easily from various scripts.
const s_rewarded_ad_loaded = "rewarded_ad_loaded"
const s_rewarded_ad_failed_to_load = "rewarded_ad_failed_to_load"
const s_reward_earned = "reward_earned"
const s_rewarded_ad_was_not_ready_to_show = "rewarded_ad_was_not_ready_to_show"
const s_on_rewarded_ad_showed = "on_rewarded_ad_showed"
const s_on_rewarded_ad_failed_to_show = "on_rewarded_ad_failed_to_show"
const s_on_rewarded_ad_dismissed = "on_rewarded_ad_dismissed"

const s_on_start_loading_saved_game = "on_start_loading_saved_game"
const s_on_loading_saved_game_complete = "on_loading_saved_game_complete"
const s_on_start_saving_game = "on_start_saving_game"
const s_on_saving_game_complete = "on_saving_game_complete"

const s_on_signed_in_status_changed = "on_signed_in_status_changed"

const s_on_start_showing_review = "on_start_showing_review"
const s_on_ending_review = "on_ending_review"

const s_on_loading_player_scores = "on_loading_player_scores"
const s_on_player_scores_loaded = "on_player_scores_loaded"

#50 - 100, 0.99$
#101 - 150, 0.99$
#151 - 200, 0.99$
# All levels - 1.99$
