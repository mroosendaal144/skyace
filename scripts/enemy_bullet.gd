extends Area2D

var velocity := Vector2.DOWN * 350.0

func _ready() -> void:
	add_to_group("enemy_bullets")

func _process(delta: float) -> void:
	position += velocity * delta
	if position.y > get_viewport_rect().size.y + 60 or position.y < -20 or position.x < -20 or position.x > 740:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		area.take_damage(10.0)
		queue_free()
