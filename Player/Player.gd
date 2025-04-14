extends CharacterBody2D

class_name Player

const MAX_AMMO: int = 1
const MAX_ARMOUR: int = 2

var combat_lib = preload("res://Combat.gd").new()

var player_types: Dictionary = {
    "Rock": {"strong_to": "Scissors", "weak_to": "Paper"},
    "Paper": {"strong_to": "Rock", "weak_to": "Scissors"},
    "Scissors": {"strong_to": "Paper", "weak_to": "Rock"},
}
var actions: Array = ["Spawning", "Searching", "Moving", "InCombat"]
var priorities: Array = ["Ring", "Player", "Loot", "Avoidance"]
#var current_action: String = actions[0]
var current_action: String = actions[1]

var player_name: String
var type: String
var strong_to: String
var weak_to: String
var aggressiveness: float
var passiveness: float
var greed: float
var spacial_perception_modifier: float
var terrain_modifier: float
var has_armour: bool
var armour_modifier: int
var has_weapon: bool
var weapon_ammo: int
var weapon_modifier: int
var health: int
var alive: bool
var score: int
var objects_detected: Array
var distance: Vector2

@export var movement_speed: float
@export var rotation_speed: float

signal loot_picked_up
signal player_died


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
    randomize()

    type = player_types.keys()[randi_range(0, 2)]
    strong_to = player_types[type]["strong_to"]
    weak_to = player_types[type]["weak_to"]
    priorities.shuffle()
    aggressiveness = snappedf(randf(), 0.1)
    passiveness = snappedf(randf(), 0.1)
    greed = snappedf(randf(), 0.1)
    spacial_perception_modifier = snappedf(randf(), 0.1)
    terrain_modifier = 0
    has_armour = false
    armour_modifier = 0
    has_weapon = false
    weapon_ammo = 0
    weapon_modifier = 0
    health = 1
    alive = true
    rotation_speed = 3
    movement_speed = 80

    print($RingDamageTimer.get_parent())


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
    determine_action(delta)


func _physics_process(delta) -> void:
    perform_action(delta)


## Determine if the player is strong to the opponent.
func is_strong_to(given_type: String) -> bool:
    if given_type == strong_to:
        return true
    else:
        return false


## Determine if the player is weak to the opponent.
func is_weak_to(given_type: String) -> bool:
    if given_type == weak_to:
        return true
    else:
        return false


## Check the player health to see if the player is still alive.
func check_health() -> void:
    if health <= 0:
        die()


## Determine the action to take.
func determine_action(delta) -> void:
    if current_action == "Searching" and objects_detected.size() == 0:
        rotation -= rotation_speed * delta

    elif current_action == "Searching":
        current_action = "Moving"


## Perform the determined action.
func perform_action(delta) -> void:
    if current_action == "Moving":
        var collision = move(delta)
        if not collision:
            return

        var collider = collision.get_collider()
        print_debug("Collided with {collider}".format({"collider": collider}))

        if collider._get_type() in ["Armour", "Weapon"]:
            pick_up_loot(collider)
            current_action = "Searching"

        elif collider._get_type() == "Player":
            current_action = "InCombat"
            collider.current_action = "InCombat"
            var result: Array = combat_lib.do_combat(self, collider)
            var winner: Player = result[0]
            winner.current_action = "Searching"


## Calculate damage done by a weapon provided the player has one and ammo for it.
func calculate_weapon_damage() -> int:
    var result: int = 0
    result += weapon_modifier
    if weapon_ammo > 0:
        weapon_ammo -= 1

    check_ammo()
    return result


## Check if the weapon has ammo and adjust the weapon modifier accordingly.
func check_ammo() -> void:
    if has_weapon and weapon_ammo == 0:
        weapon_modifier = 0


## Check the amount of armour the player has and adjust the armour accordingly.
func check_armour() -> void:
    if armour_modifier == 0:
        has_armour = false


## Handle picking up loot.
func pick_up_loot(item: Loot) -> void:
    print_debug("Picking up {item}".format({"item": item}))
    var item_type = item._get_type()
    if item_type == "Armour":
        if not has_armour or armour_modifier < MAX_ARMOUR:
            item.picked_up()
            emit_signal("loot_picked_up", item)
            equip_armour()
            return

    if item_type == "Weapon":
        if not has_weapon or weapon_ammo < MAX_AMMO:
            item.picked_up()
            emit_signal("loot_picked_up", item)
            equip_weapon()


## Equip picked up armour.
func equip_armour() -> void:
    has_armour = true
    armour_modifier += 1


## Equip picked up weapon.
func equip_weapon() -> void:
    has_weapon = true
    weapon_modifier += 1


## Modify ammo count when picking up a weapon when the player already has one.
func equip_ammo() -> void:
    weapon_ammo += 1
    if weapon_ammo > MAX_AMMO:
        weapon_ammo = MAX_AMMO


## Calculate the damage dealt to another player.
## Only the attacker should perform this calculation.
func calculate_damage_dealt(opponent: Player) -> int:
    var result: int = 1
    if is_strong_to(opponent.type):
        result += 1

    result += calculate_weapon_damage()
    result -= opponent.armour_modifier

    if result < 0:
        result = 0

    return result


## Calculate damage taken from another player.
## Only the attacker should perform this calculation.
func calculate_damage_taken(opponent: Player) -> int:
    var result: int = opponent.calculate_damage_dealt(self)
    result -= armour_modifier
    if armour_modifier > 0:
        armour_modifier -= 1

    if result < 0:
        result = 0

    return result


## Take damage based on the amount of damage the opponent calculated it would do
## and the armour this player has.
func take_damage(damage: int) -> void:
    var remainder: int = damage - armour_modifier
    armour_modifier -= damage
    if armour_modifier <= 0:
        armour_modifier = 0

    health -= remainder
    check_health()
    check_armour()


## Perform player death actions.
func die() -> void:
    alive = false
    emit_signal("player_died", self)
    $RingDamageTimer.stop()
    queue_free()


## Handle when the cone of sight collides with an object.
func _on_cone_of_sight_body_entered(body) -> void:
    if body == self:
        return

    $ConeOfSight/ConeOfSightSprite.modulate = Color(255, 255, 255)
    if objects_detected.size() == 0:
        objects_detected.append(body)
        return

    # TODO: Figure out priority reorginization.
    objects_detected.append(body)


## Handle when an object leaves the cone of vision.
func _on_cone_of_sight_body_exited(_body) -> void:
    $ConeOfSight/ConeOfSightSprite.modulate = Color(1.0, 1.0, 1.0)


## Return the type of object.
func _get_type() -> String:
    return "Player"


## Move to the determined target.
func move(delta) -> Object:
    if objects_detected.size() == 0:
        current_action = "Searching"
        return

    var target = objects_detected[0]
    if is_instance_valid(target):
        var angle_to_object = global_position.direction_to(
            target.position
        ).angle() + deg_to_rad(90)
        rotation = move_toward(rotation, angle_to_object, rotation_speed * delta)

        var destination = objects_detected[0].position
        distance = Vector2(destination - position)
        velocity = distance.normalized() * movement_speed
        var collision = move_and_collide(velocity * delta)
        return collision

    current_action = "Searching"
    return


## Target the next object detected if there is one.
func target_next_object() -> void:
    if objects_detected.size() == 0:
        current_action = "Searching"

    else:
        current_action = "Moving"


func _on_entered_ring() -> void:
    $RingDamageTimer.stop()


func _on_exited_ring() -> void:
    if alive and $RingDamageTimer.is_stopped():
        $RingDamageTimer.start()


func _on_ring_damage_timer_timeout():
    take_damage(1)
