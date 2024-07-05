extends TextureRect
class_name ItemContainer

var upgrade: String = ""

func _ready() -> void:
	if upgrade != "":
		$ItemTexture.texture = load(UpgradeDB.UPGRADES[upgrade]["icon"])
