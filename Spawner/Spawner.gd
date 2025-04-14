extends Sprite2D

class_name Spawner

var target: Vector2
var spawner_flight_time: float = 15

signal spawner_entered
signal spawner_exited


# Called when the node enters the scene tree for the first time.
func _ready():
    pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
    if not target:
        return

    var tween = get_tree().create_tween()
    tween.tween_property(self, "position", target, spawner_flight_time)
    tween.set_ease(Tween.EASE_IN_OUT)
    tween.tween_callback(queue_free)


func _on_spawner_visible_on_screen_notifier_screen_entered():
    emit_signal("spawner_entered")


func _on_spawner_visible_on_screen_notifier_screen_exited():
    emit_signal("spawner_exited")
    queue_free()


func _get_type() -> String:
    return "Spawner"
