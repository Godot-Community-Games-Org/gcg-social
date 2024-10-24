extends Node
class_name Players

const player_factory = preload("res://scenes/characters/player.tscn")

func add_player_to_scene(peer_id: int) -> void:
	if !OS.has_feature("is_server"):
		return
	var player: Player = player_factory.instantiate()
	player.set_name(str(peer_id))
	add_child(player)

func remove_player_from_scene(peer_id: int) -> void:
	var player = get_node(str(peer_id))
	remove_child(player)
	player.queue_free()

func _on_multiplayer_connection_client_connected(peer_id: int) -> void:
	add_player_to_scene(peer_id)

func _on_multiplayer_connection_client_disconnected(peer_id: int) -> void:
	remove_player_from_scene(peer_id)
