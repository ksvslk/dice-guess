extends ColorRect

var payment = null
var ios_payment = null

onready var all_level_packs = $VBoxContainer/AllLevelPacks
onready var level_pack_1 = $VBoxContainer/LevelPack1
onready var level_pack_2 = $VBoxContainer/LevelPack2
onready var level_pack_3 = $VBoxContainer/LevelPack3
onready var restore = $VBoxContainer/Restore
onready var store_timer = $StoreTimer
onready var bonus_levels = $"../Menu/HBoxContainer/VBoxContainer/BonusLevels"

var in_progress_purchase_id = ""

func _ready():
	if Engine.has_singleton("GodotGooglePlayBilling"):
		payment = Engine.get_singleton("GodotGooglePlayBilling")
		# No params.
		payment.connect("connected", self, "_on_connected")
		# No params.
		payment.connect("disconnected", self, "_on_disconnected")
		# Response ID (int), Debug message (string).
		payment.connect("connect_error", self, "_on_connect_error")
		# Purchases (Dictionary[]).
		payment.connect("purchases_updated", self, "_on_purchases_updated")
		# Response ID (int), Debug message (string).
		payment.connect("purchase_error", self, "_on_purchase_error")
		# SKUs (Dictionary[]).
		payment.connect("sku_details_query_completed", self, "_on_sku_details_query_completed")
		# Response ID (int), Debug message (string), Queried SKUs (string[]).
		payment.connect("sku_details_query_error", self, "_on_sku_details_query_error")
		# Purchase token (string).
		payment.connect("purchase_acknowledged", self, "_on_purchase_acknowledged")
		# Response ID (int), Debug message (string), Purchase token (string).
		payment.connect("purchase_acknowledgement_error", self, "_on_purchase_acknowledgement_error")
		# Purchase token (string).
		payment.connect("purchase_consumed", self, "_on_purchase_consumed")
		# Response ID (int), Debug message (string), Purchase token (string).
		payment.connect("purchase_consumption_error", self, "_on_purchase_consumption_error")
		# Purchases (Dictionary[])
		payment.connect("query_purchases_response", self, "_on_query_purchases_response")
		payment.startConnection()
		restore.visible = false
	elif Engine.has_singleton("InAppStore"):
		ios_payment = Engine.get_singleton("InAppStore")
		store_timer.connect("timeout", self, "handle_ios_store_events")
		store_timer.start()
		request_ios_products_info()
		restore.visible = true
	else:
		printerr("Android IAP support is not enabled. Make sure you have enabled 'Custom Build' and installed and enabled the GodotGooglePlayBilling plugin in your Android export settings! This application will not work.")

################################
#		  GOOGLE PLAY 		   #
################################

# GOOGLE PLAY
func _on_connected():
	if !GPack.is_amazon:
		payment.queryPurchases("inapp") # Use "subs" for subscriptions.
		payment.querySkuDetails(Data.skus.keys(), "inapp")

# GOOGLE PLAY
func _notification(what):
	if what == NOTIFICATION_APP_RESUMED && !GPack.is_amazon:
		payment.queryPurchases("inapp")
		
		
# GOOGLE PLAY
func _on_query_purchases_response(query_result):
	if query_result.status == OK:
		for purchase in query_result.purchases:
			_handle_purchase(purchase)
	else:
		printerr("queryPurchases failed, response code: ",
				query_result.response_code,
				" debug message: ", query_result.debug_message)
				

# GOOGLE PLAY
func _get_button_title_google_play(available_sku) -> String:
	var price = available_sku["price"]
	return available_sku["title"].get_slice("(", 0) + " - " + price


# GOOGLE PLAY
func _on_sku_details_query_completed(sku_details):
	for available_sku in sku_details:
		if available_sku["sku"] == Data.all_level_packs_id:
			all_level_packs.set_title(_get_button_title_google_play(available_sku))
		elif available_sku["sku"] == Data.level_pack_1_id:
			level_pack_1.set_title(_get_button_title_google_play(available_sku))
		elif available_sku["sku"] == Data.level_pack_2_id:
			level_pack_2.set_title(_get_button_title_google_play(available_sku))
		elif available_sku["sku"] == Data.level_pack_3_id:
			level_pack_3.set_title(_get_button_title_google_play(available_sku))
	_display_purchase_buttons_reasonably()


# GOOGLE PLAY
func _on_purchases_updated(purchases):
	#print("Purchases updated (on resume and startup): %s" % to_json(purchases))
	# See _on_connected
	for purchase in purchases:
		_handle_purchase(purchase)


# GOOGLE PLAY
func _handle_purchase(purchase):
	if purchase.purchase_state == 1:
		if !purchase.is_acknowledged:
			_give_content(purchase.sku)
			payment.acknowledgePurchase(purchase.purchase_token)
			#print("Purchase " + str(purchase.sku) + " has not been acknowledged. Acknowledging...")
		else:
			#print("Purchase " + str(purchase.sku) + " was acknowledged already. Giving content if needed.")
			_give_content(purchase.sku)


# GOOGLE PLAY
func _on_purchase_acknowledged(purchase_token):
	pass
	#print("Purchase acknowledged: %s" % purchase_token)
	
	
# GOOGLE PLAY
func _on_purchase_consumed(purchase_token):
	pass
	#print("Purchase consumed successfully: %s" % purchase_token)
	

# GOOGLE PLAY
func _on_purchase_error(code, message):
	printerr("Purchase error %d: %s" % [code, message])
	

# GOOGLE PLAY
func _on_purchase_acknowledgement_error(code, message, token):
	printerr("Purchase acknowledgement error %d: %s %s" % [code, message, token])
	
	
# GOOGLE PLAY
func _on_purchase_consumption_error(code, message, purchase_token):
	printerr("Purchase consumption error %d: %s, purchase token: %s" % [code, message, purchase_token])


# GOOGLE PLAY
func _on_sku_details_query_error(code, message, list):
	printerr("SKU details query error %d: %s %s" % [code, message, to_json(list)])
	
	
# GOOGLE PLAY
func _on_disconnected():
	#print("GodotGooglePlayBilling disconnected. Will try to reconnect in 10s...")
	yield(get_tree().create_timer(10), "timeout")
	payment.startConnection()


################################
#		   APP STORE		   #
################################

# APP STORE
func request_ios_products_info():
	ios_payment.request_product_info({ "product_ids": Data.skus.keys() })

# APP STORE
func handle_ios_store_events():
	while ios_payment.get_pending_event_count() > 0:
		var response_event = ios_payment.pop_pending_event()
		if response_event["type"] == "purchase":
			var result = response_event["result"]
			if result == "ok":
				_give_content(response_event["product_id"])
				set_active_for_bonus_menu(response_event["product_id"])
			elif result == "progress":
				set_loading_for_bonus_menu(response_event["product_id"])
			else:
				set_active_for_bonus_menu(response_event["product_id"])
		elif response_event["type"] == "product_info":
			if response_event["result"] == "ok":
				update_ios_products_buttons(response_event)
			else:
				printerr("Could not fetch products info.")
		elif response_event["type"] == "restore":
			if response_event["result"] == "ok":
				_give_content(response_event["product_id"])
			elif response_event["result"] == "error":
				printerr("Restore error.")
			elif response_event["result"] == "completed":
				printerr("Restore completed")
			else:
				printerr("No restore.")
			set_active_for_bonus_menu("restore")


# APP STORE
func _get_button_title(response_event, index) -> String:
	var title = response_event["titles"][index]
	var price = response_event["localized_prices"][index]
	return title + " - " + price


# APP STORE
func update_ios_products_buttons(response_event):
	for index in range(response_event.ids.size()):
		var product_id = response_event.ids[index]
		if product_id == Data.all_level_packs_id:
			all_level_packs.set_title(_get_button_title(response_event, index))
		elif product_id == Data.level_pack_1_id:
			level_pack_1.set_title( _get_button_title(response_event, index))
		elif product_id == Data.level_pack_2_id:
			level_pack_2.set_title(_get_button_title(response_event, index))
		elif product_id == Data.level_pack_3_id:
			level_pack_3.set_title(_get_button_title(response_event, index))

# APP STORE
func _on_Restore_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if in_progress_purchase_id == "":
				set_loading_for_bonus_menu("restore")
				ios_payment.restore_purchases()
			elif in_progress_purchase_id == "restore":
				set_active_for_bonus_menu("restore")
		
		
		
		
################################
#		  UNIVERSAL 		   #
################################

# UNIVERSAL
func _give_content(sku):
	match sku:
		Data.all_level_packs_id:
			Data.set_all_level_packs_purchased()
			_display_purchase_buttons_reasonably()
		Data.level_pack_1_id:
			Data.set_level_pack_1_purchased()
			_display_purchase_buttons_reasonably()
		Data.level_pack_2_id:
			Data.set_level_pack_2_purchased()
			_display_purchase_buttons_reasonably()
		Data.level_pack_3_id:
			Data.set_level_pack_3_purchased()
			_display_purchase_buttons_reasonably()
	if ios_payment:
		ios_payment.finish_transaction(sku)


# UNIVERSAL
func _display_purchase_buttons_reasonably():
	var count_packs_purchased = 0
	var is_all_in_purchased = false
	for sku_id in Data.skus.keys():
		if sku_id == Data.all_level_packs_id:
			is_all_in_purchased = Data.skus[sku_id]
		elif Data.skus[sku_id] == true:
			count_packs_purchased += 1
			if sku_id == Data.level_pack_1_id:
				level_pack_1.visible = false
			elif sku_id == Data.level_pack_2_id:
				level_pack_2.visible = false
			elif sku_id == Data.level_pack_3_id:
				level_pack_3.visible = false
	if is_all_in_purchased:
		all_level_packs.visible = false
		level_pack_1.visible = false
		level_pack_2.visible = false
		level_pack_3.visible = false
		visible = false
		bonus_levels.visible = false
	elif count_packs_purchased == 2:
		all_level_packs.visible = false
	elif count_packs_purchased == 3:
		all_level_packs.visible = false
		visible = false
		bonus_levels.visible = false
	elif count_packs_purchased == 1:
		visible = false
		


# UNIVERSAL
func set_loading_for_bonus_menu(product_id: String):
	in_progress_purchase_id = product_id
	if product_id == Data.all_level_packs_id:
		all_level_packs.start_loading()
	elif product_id == Data.level_pack_1_id:
		level_pack_1.start_loading()
	elif product_id == Data.level_pack_2_id:
		level_pack_2.start_loading()
	elif product_id == Data.level_pack_3_id:
		level_pack_3.start_loading()
	elif product_id == "restore":
		restore.start_loading()


# UNIVERSAL
func set_active_for_bonus_menu(product_id: String):
	in_progress_purchase_id = ""
	if product_id == Data.all_level_packs_id:
		all_level_packs.stop_loading()
	elif product_id == Data.level_pack_1_id:
		level_pack_1.stop_loading()
	elif product_id == Data.level_pack_2_id:
		level_pack_2.stop_loading()
	elif product_id == Data.level_pack_3_id:
		level_pack_3.stop_loading()
	elif product_id == "restore":
		restore.stop_loading()


# UNIVERSAL
func _purchase(sku):
	if payment:
		var response = payment.purchase(sku)
		if response.status != OK:
			printerr("Purchase error %s: %s" % [response.response_code, response.debug_message])
	elif ios_payment:
		var result = ios_payment.purchase({ "product_id": sku })
		if result == OK:
			set_loading_for_bonus_menu(sku)
		else:
			pass
			#show_error()


# UNIVERSAL
func _on_AllLevelPacks_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed() && in_progress_purchase_id == "":
			_purchase(Data.all_level_packs_id)


# UNIVERSAL
func _on_LevelPack1_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed() && in_progress_purchase_id == "":
			_purchase(Data.level_pack_1_id)


# UNIVERSAL
func _on_LevelPack2_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed() && in_progress_purchase_id == "":
			_purchase(Data.level_pack_2_id)


# UNIVERSAL
func _on_LevelPack3_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed() && in_progress_purchase_id == "":
			_purchase(Data.level_pack_3_id)
