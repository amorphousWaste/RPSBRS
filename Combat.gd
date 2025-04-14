extends Node

class_name Combat


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
    pass


## Determine the order combat will occur.
func determine_order(player_1: Player, player_2: Player) -> Array:
    var players: Array = [player_1, player_2]
    var first: Player = null
    var second: Player = null

    print_debug(
        "{player_name} is {type}".format(
            {"player_name": player_1.player_name, "type": player_1.type}
        )
    )
    print_debug(
        "{player_name} is {type}".format(
            {"player_name": player_2.player_name, "type": player_2.type}
        )
    )
    if player_1.is_strong_to(player_2.type):
        first = player_1

    elif player_2.is_strong_to(player_1.type):
        first = player_2

    elif player_1.is_weak_to(player_2.type):
        first = player_2

    elif player_2.is_weak_to(player_1.type):
        first = player_1

    # Coin flip.
    else:
        first = [player_1, player_2][randi_range(0, 1)]

    players.erase(first)
    second = players[0]
    print_debug(
        "First {first}, Second {second}".format(
            {"first": first.player_name, "second": second.player_name}
        )
    )
    return [first, second]


## Perform combat between two players.
func do_combat(player_1: Player, player_2: Player) -> Array:
    var order: Array = determine_order(player_1, player_2)
    var first: Player = order[0]
    var second: Player = order[1]
    var winner: Player
    var loser: Player
    var damage_dealt: int
    var damage_taken: int

    while first.alive and second.alive:
        damage_dealt = first.calculate_damage_dealt(second)
        print_debug(
            "{player_name} deals: {damage_dealt}".format(
                {"player_name": first.player_name, "damage_dealt": damage_dealt}
            )
        )
        second.take_damage(damage_dealt)
        second.check_health()
        print_debug(
            "{player_name} health: {health}".format(
                {"player_name": second.player_name, "health": second.health}
            )
        )
        if second.alive:
            damage_taken = first.calculate_damage_taken(second)
            print_debug(
                "{player_name} takes: {damage_taken}".format(
                    {"player_name": first.player_name, "damage_taken": damage_taken}
                )
            )
            first.take_damage(damage_taken)
            first.check_health()
            print_debug(
                "{player_name} health: {health}".format(
                    {"player_name": first.player_name, "health": first.health}
                )
            )

    if player_1.alive:
        winner = player_1
    else:
        winner = player_2

    order.erase(winner)
    loser = order[0]

    return [winner, loser]
