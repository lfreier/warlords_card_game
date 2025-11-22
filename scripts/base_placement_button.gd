class_name BasePlacementButton
extends Button

var base_obj: Base
var click_locked: bool
var marker: TargetMarker

func init(offset: float, base: Base) -> void:
	anchor_left = offset
	anchor_right = offset
	base_obj = base
	icon = base.base_sprite.texture
	signals.player_lock_click.connect(lock_click)
	pressed.connect(base_place_click)

func base_place_click() -> void:
	if (!click_locked):
		signals.player_lock_click.emit(true, self.get_script().get_global_name())
		if (marker == null):
			marker = globals.target_marker_scene.instantiate()
			self.add_child(marker)
			marker.scale = Vector2(0.5, 0.5)
			marker.init(CardEffect.CardTarget.LANE, self)

func lock_click(toggle: bool, source: String) -> void:
	if (source != self.get_script().get_global_name()):
		click_locked = toggle
	if (marker != null):
		marker.queue_free()
