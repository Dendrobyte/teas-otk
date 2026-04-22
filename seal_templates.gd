class_name SealTemplates

## All of the base "learnings" for our Seals that can be drawn

static var PHOENIX_SEAL: PackedVector2Array = PackedVector2Array([
    Vector2(500, 780), Vector2(180, 100), Vector2(80, 540), Vector2(360, 980),
    Vector2(560, 960), Vector2(640, 620), Vector2(580, 440), Vector2(480, 620),
    Vector2(640, 980), Vector2(900, 960), Vector2(1120, 540), Vector2(980, 100),
    Vector2(660, 780),
])

static var PLANT_SEAL: PackedVector2Array = PackedVector2Array([
    Vector2(500, 500), Vector2(300, 440), Vector2(170, 530),
    Vector2(260, 640), Vector2(460, 620), Vector2(500, 500),
    Vector2(660, 380), Vector2(880, 370), Vector2(940, 470),
    Vector2(820, 580), Vector2(500, 500), Vector2(530, 900),
])

static var ALL_SEALS = {
    "PHOENIX": PHOENIX_SEAL,
    "PLANT": PLANT_SEAL,
}