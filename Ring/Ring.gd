extends Area2D

class_name Ring

var center: Vector2
var ring_scale_threshold: float = 0.01
#var ring_scale_factor: float = 0.001
var ring_scale_factor: float = 0.1

signal object_entered_ring
signal object_exited_ring
signal ring_damage


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass


func create_ring() -> void:
    center = Vector2(
        randi_range(0, ProjectSettings.get("display/window/size/viewport_width")),
        randi_range(0, ProjectSettings.get("display/window/size/viewport_height")),
    )
    transform.origin = Vector2(center)


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
    if global_scale.x > ring_scale_threshold:
        global_scale -= Vector2(ring_scale_factor * delta, ring_scale_factor * delta)


func _on_body_entered(body):
    emit_signal("object_entered_ring", body)


func _on_body_exited(body) -> void:
    emit_signal("object_exited_ring", body)
