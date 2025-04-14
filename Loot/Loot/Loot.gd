extends Node

class_name Loot


## Return the type of object.
func _get_type() -> String:
    return ""


## Despawn the object when picked up.
func picked_up() -> void:
    queue_free()
