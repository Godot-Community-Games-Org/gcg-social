extends Control

signal username_requested(peer_id: int, username: String)

# This method is called by the client when requesting the use of a username for this session
@rpc("any_peer")
func request_username(peer_id: int, username: String) -> void:
	if !OS.has_feature("is_server"):
		return
	# Since the list of players is managed elsewhere we emit a signal to indicate that we are requesting a username
	username_requested.emit(peer_id, username)

# If the server tells this client that the username is not available, show an error message
@rpc("authority")
func username_unavailable() -> void:
	$Login/ErrorMessage.text = "That username is taken"
	$Login/ErrorMessage.show()

# If the server tells this client that the username is available, hide the login screen to show the main page
@rpc("authority")
func username_available() -> void:
	hide()

# If the username is not available, notify the client that requested the username
func _on_players_username_unavailable(peer_id: int) -> void:
	rpc_id(peer_id, "username_unavailable")

# If the username is available, notify the client that requested the username
func _on_players_username_available(peer_id: int) -> void:
	rpc_id(peer_id, "username_available")

func _on_login_btn_pressed() -> void:
	var username: String = $Login/MarginContainer/UsernameLine/UsernameInput.text
	# Validate the username
	if username.length() < 4:
		$Login/ErrorMessage.text = "Username must be at least 4 characters long."
		$Login/ErrorMessage.show()
	elif username.length() > 10:
		$Login/ErrorMessage.text = "Username cannot be longer than 10 characters"
		$Login/ErrorMessage.show()
	else:
		# The first iteration uses ephemeral usernames with no persistence
		# Here, this client requests use of the entered username on the server
		var peer_id = multiplayer.get_unique_id()
		rpc_id(0, "request_username", peer_id, username)

# When the player starts typing a new username, clear out the error message
func _on_username_input_text_changed(new_text: String) -> void:
	$Login/ErrorMessage.text = ""
	$Login/ErrorMessage.hide()
