extends Node

var ring: Ring
var spawner: Spawner

var Players: Array = []
var player_count: int = 100
var armour_count: int = 5
var weapon_count: int = 5


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
    randomize()

    create_ring()
    create_spawner()

    for p in range(player_count):
        var player: Player = load("res://Player/Player.tscn").instantiate()
        player.player_name = "Player{num}".format({"num": p})
        $PlayersLayer.add_child(player)
        Players.append(player)
        player.position = Vector2(
            randi_range(0, ProjectSettings.get("display/window/size/viewport_width")),
            randi_range(0, ProjectSettings.get("display/window/size/viewport_height"))
        )
        player.look_at(ring.position)
        player.connect("loot_picked_up", Callable(self, "_on_item_picked_up"))
        player.connect("player_died", Callable(self, "_on_player_died"))

    for a in range(armour_count):
        var armour: Armour = load("res://Loot/Armour/Armour.tscn").instantiate()
        armour.armour_name = "Armour{num}".format({"num": a})
        $LootLayer.add_child(armour)
        armour.position = Vector2(
            randi_range(0, ProjectSettings.get("display/window/size/viewport_width")),
            randi_range(0, ProjectSettings.get("display/window/size/viewport_height"))
        )

    for w in range(weapon_count):
        var weapon: Weapon = load("res://Loot/Weapon/Weapon.tscn").instantiate()
        weapon.weapon_name = "Weapon{num}".format({"num": w})
        $LootLayer.add_child(weapon)
        weapon.position = Vector2(
            randi_range(0, ProjectSettings.get("display/window/size/viewport_width")),
            randi_range(0, ProjectSettings.get("display/window/size/viewport_height"))
        )


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
    pass


## Called every frame to perform physics calculations.
func _physics_process(_delta) -> void:
    pass


func create_ring() -> void:
    ring = load("res://Ring/Ring.tscn").instantiate()
    $RingLayer.add_child(ring)
    ring.create_ring()
    ring.connect("object_entered_ring", Callable(self, "_on_body_entered_ring"))
    ring.connect("object_exited_ring", Callable(self, "_on_body_exited_ring"))


func create_spawner() -> void:
    spawner = load("res://Spawner/Spawner.tscn").instantiate()
    $SpawnerLayer.add_child(spawner)
    spawner.connect("spawner_entered", Callable(self, "_on_spawner_entered"))
    spawner.connect("spawner_exited", Callable(self, "_on_spawner_exited"))
    $SpawnerLayer/SpawnerRangeL/SpawnerRangeSamplerL.progress_ratio = randi()
    spawner.position = $SpawnerLayer/SpawnerRangeL/SpawnerRangeSamplerL.position
    $SpawnerLayer/SpawnerRangeR/SpawnerRangeSamplerR.progress_ratio = randi()
    spawner.target = $SpawnerLayer/SpawnerRangeR/SpawnerRangeSamplerR.position
    spawner.look_at(spawner.target)
    spawner.rotation_degrees += 90


## Handle an item is picked up.
func _on_item_picked_up(item: Loot) -> void:
    for player in Players:
        if item in player.objects_detected:
            player.objects_detected.erase(item)
            player.target_next_object()


## Handle when a player dies.
func _on_player_died(dead_player: Player) -> void:
    # Removing an item from an array being iterated through
    # might be a bad idea.
    Players.erase(dead_player)

    for player in Players:
        if dead_player in player.objects_detected:
            player.objects_detected.erase(dead_player)
            player.target_next_object()


func _on_body_entered_ring(body) -> void:
    if body._get_type() == "Player":
        #body._on_entered_ring()
        body.get_node("RingDamageTimer").stop()


func _on_body_exited_ring(body) -> void:
    if body._get_type() == "Player":
        #body._on_exited_ring()
        if body.get_node("RingDamageTimer").is_stopped() and body.alive:
            body.get_node("RingDamageTimer").start()


func _on_ring_damage_timeout(body) -> void:
    body.take_damage(1)


func _on_spawner_entered() -> void:
    pass


func _on_spawner_exited() -> void:
    pass
