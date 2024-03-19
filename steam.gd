extends Node

var is_free_weekend: bool = false
var is_owned: bool = false
var is_online: bool = false
var is_on_steam_deck: bool = false
var steam_app_id: int = 2747540
var steam_id: int = 0
var steam_username: String = ""

const achievements_dict = {7:"ACH_COMPLETE_7", 42:"ACH_COMPLETE_42", 101:"ACH_COMPLETE_101", 153:"ACH_COMPLETE_153", 216:"ACH_COMPLETE_216", 300:"ACH_COMPLETE_300", 365:"ACH_COMPLETE_365", 444:"ACH_COMPLETE_444"}


signal score_uploaded
const leaderboard_name = "Default"
var leaderboard_handle = null
var is_steam_ok = false

# Set your game's Steam app IP
func _init() -> void:
	OS.set_environment("SteamAppId", str(steam_app_id))
	OS.set_environment("SteamGameId", str(steam_app_id))


func _ready() -> void:
	# Initialize Steam
	var initialize_response: Dictionary = Steam.steamInit(false)
	print("[STEAM] Did Steam initialize?: %s" % initialize_response)
	if initialize_response['status'] != 1:
		is_steam_ok = false
		# If Steam fails to start up, shut down the app
		print("[STEAM] Failed to initialize Steam: %s" % initialize_response['verbal'])
		return
#		get_tree().quit()

	# Some example functions to run after initializing.
	# These can be deleted or commented out if not needed.
	#############################################
	#Is the user online?
	#is_online = Steam.loggedOn()

	# Get the user's Stean name and ID
	#steam_id = Steam.getSteamID()
	#steam_username = Steam.getPersonaName()

	# Is this app owned or is it a free weekend?
	#is_owned = Steam.isSubscribed()
	#is_free_weekend = Steam.isSubscribedFromFreeWeekend()

	# Is the game running on the Steam Deck
	#is_on_steam_deck = Steam.isSteamRunningOnSteamDeck()
	is_steam_ok = true
	Steam.connect("leaderboard_find_result", self, "_on_leaderboard_find_result")
	Steam.connect("leaderboard_score_uploaded", self, "_on_leaderboard_score_uploaded")
	Steam.findLeaderboard(leaderboard_name)


func _process(_delta: float) -> void:
	# Get callbacks
	Steam.run_callbacks()


func _on_leaderboard_find_result(handle: int, found: int) -> void:
	if found == 1:
		leaderboard_handle = handle
		print("Leaderboard handle set: %s" % leaderboard_handle)
	else:
		print("No handle was found")


func submit_score():
	if is_steam_ok and leaderboard_handle:
		var score = Data.get_total_score()
		Steam.uploadLeaderboardScore(score, 1, [], leaderboard_handle)


func _on_leaderboard_score_uploaded(success: int, this_handle: int, this_score: Dictionary) -> void:
	if success == 1:
		print("Successfully uploaded scores!")
		emit_signal("score_uploaded", this_score)
		# Add additional logic to use other variables passed back
	else:
		print("Failed to upload scores!")
	

func set_achievement(level_nr: int) -> void:
	if is_steam_ok and achievements_dict.has(level_nr):
		var achievement = achievements_dict.get(level_nr)
		var WAS_SET: bool = Steam.setAchievement(achievement)
		print("Steam achievement "+str(achievement)+" set: "+str(WAS_SET))
		Steam.storeStats()

###
# Due to how GDNative works, the functions must either reside here or be called with Steam.Steam. since we are calling this singleton script then the Steamworks class.
###
