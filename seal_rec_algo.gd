class_name OneDollar

# Implemented based on
# https://depts.washington.edu/acelab/proj/dollar/dollar.js

static var INTERVAL = 20 # The paper just uses 64

# Resampling
static func normalize(stroke_points: PackedVector2Array): # See note below, but convert to Array[Vector2]
    var new_points: PackedVector2Array = [stroke_points[0]]
    # Take every n points until we have INTERVAL number of points
    var step = path_length(stroke_points) / (INTERVAL - 1) # -1 to get edges from vertices
    var d_walked = 0
    var i = 1
    while i < stroke_points.size():
        var dist = stroke_points[i-1].distance_to(stroke_points[i]) # Should just be regular distance formula
        if d_walked + dist >= step:
            var new_x = stroke_points[i-1].x + ((step - d_walked) / dist) * (stroke_points[i].x - stroke_points[i-1].x)
            var new_y = stroke_points[i-1].y + ((step - d_walked) / dist) * (stroke_points[i].y - stroke_points[i-1].y)
            var new_point = Vector2(new_x, new_y)
            stroke_points.insert(i, new_point) # NOTE: This can be slow bc packed array. Change to array if need-be then go back on return
            new_points.append(new_point)
            d_walked = 0
        else:
            d_walked += dist
        i += 1

    # If we fall short, we add the last point
    if new_points.size() == INTERVAL-1:
        new_points.append(stroke_points[-1])
    return new_points

#### Helper Functions ####
static func path_length(points):
    var d = 0.0
    for i in range(1, points.size()):
        d += points[i-1].distance_to(points[i])
    return d

func distance(p1, p2):
    var dx = p2.x - p1.x
    var dy = p2.y - p1.y
    return sqrt(dx*dx + dy*dy)