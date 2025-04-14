extends Sprite2D

var rotation_speed = 5


# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    var target = $"../target"
    var angle_to_player = global_position.direction_to(target.position).angle() + deg_to_rad(90)
    #rotation = lerp(rotation, angle_to_player, rotation_speed * delta)
    rotation = move_toward(rotation, angle_to_player, rotation_speed * delta)
