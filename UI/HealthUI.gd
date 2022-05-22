extends Control


var hearts = 3 setget set_hearts
var max_hearts = 3 setget set_max_hearts

const heart_width = 15

onready var heartUIFull = $HeartUIFull
onready var heartUIEmpty = $HeartUIEmpty


func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	heartUIFull.rect_size.x = hearts * heart_width


func set_max_hearts(value):
	max_hearts = max(value, 1)
	self.hearts = min(hearts, max_hearts)
	heartUIEmpty.rect_size.x = max_hearts * heart_width


func _ready():
	self.max_hearts = PlayerStats.max_health
	self.hearts = PlayerStats.health
	PlayerStats.connect("health_changed", self, "set_hearts")  # warning-ignore:return_value_discarded
	PlayerStats.connect("max_health_changed", self, "set_max_hearts")  # warning-ignore:return_value_discarded
