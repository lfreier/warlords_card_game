class_name BasePlacementButton
extends Button

var base_obj: Base
var click_locked: bool
var marker: TargetMarker
var target_lane: Lane

@export var confirm: bool

func init(offset: float, base: Base, lane: Lane) -> void:
	anchor_left = offset
	anchor_right = offset
	base_obj = base
	icon = base.base_sprite.texture
	target_lane = lane
	
	var desc: Label = Label.new()
	self.add_child(desc)
	desc.text = base.description
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.set_anchors_preset(Control.PRESET_CENTER_BOTTOM, false)
	desc.size.x = 150
	desc.set_anchor_and_offset(SIDE_LEFT, 0.5, -100, true)
	desc.set_anchor_and_offset(SIDE_RIGHT, 0.5, 100, true)
	desc.set_anchor_and_offset(SIDE_TOP, 1, 0, true)
	desc.set_anchor_and_offset(SIDE_BOTTOM, 1, 75, true)
	signals.player_lock_click.connect(lock_click)
	if (confirm):
		pressed.connect(base_place_click_confirm)
	else:
		pressed.connect(base_place_click)
		signals.player_lock_click.emit(true, self.get_script().get_global_name())

func base_place_click() -> void:
	if (!click_locked):
		signals.place_base.emit(base_obj, target_lane, true)
		signals.player_lock_click.emit(false, "")
		
func base_place_click_confirm() -> void:
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
