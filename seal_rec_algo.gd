class_name OneDollar

# Implemented based on
# https://depts.washington.edu/acelab/proj/dollar/dollar.js

const INTERVAL = 20 # The paper just uses 64
const SQUARE_SIZE: float = 600.0
const DIAGONAL = sqrt(SQUARE_SIZE*SQUARE_SIZE + SQUARE_SIZE*SQUARE_SIZE)

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
	
	# Apply other transforms
	# Skipping rotation since that's relevant to seals
	new_points = scale_to(new_points)
	new_points = translate_to_origin(new_points)

	return new_points

# Recognition
static func recognize(stroke_points):
	var min_dist = INF
	var matched_seal = null
	for seal in SealTemplates.ALL_SEALS:
		var seal_points = SealTemplates.ALL_SEALS[seal]	
		var dist = _compare_seal(stroke_points, seal_points)
		if dist < min_dist:
			min_dist = dist
			matched_seal = seal

	var max_dist = 0.5 * DIAGONAL
	var confidence = 1.0 - min_dist / max_dist
	
	return {
		"name": matched_seal,
		"confidence": confidence,
	}

# For every seal, compare and take the smallest
static func _compare_seal(drawn_points, seal_points):
	var sum_dist = 0.0
	var num_points = drawn_points.size()
	# TODO: Eventually, we'll programmatically generate ideal seals and use 64
	seal_points = normalize(seal_points)
	for i in range(num_points):
		sum_dist += drawn_points[i].distance_to(seal_points[i])
	return sum_dist / num_points

#### Helper Functions ####
# Compute the full length of a path of points for edge distance
static func path_length(points):
	var d = 0.0
	for i in range(1, points.size()):
		d += points[i-1].distance_to(points[i])
	return d

# In order to uniformly compare points, we will match scale
static func scale_to(points):
	var bounds = bounding_box(points)
	var scaled_points: PackedVector2Array = []
	for point in points:
		var scaled_x = point.x * (SQUARE_SIZE / bounds.w)
		var scaled_y = point.y * (SQUARE_SIZE / bounds.h)
		scaled_points.append(Vector2(scaled_x, scaled_y))
	print("Scaled: ", scaled_points)
	return scaled_points

# Takes the points and returns bounding box. x,y are min_x,min_y of points
static func bounding_box(points):
	var min_x = INF
	var min_y = INF
	var max_x = -INF
	var max_y = -INF
	for point in points:
		min_x = min(min_x, point.x)
		min_y = min(min_y, point.y)
		max_x = max(max_x, point.x)
		max_y = max(max_y, point.y)

	return {
		"x": min_x,
		"y": min_y,
		"w": max_x - min_x,
		"h": max_y - min_y,
	}

# Move the drawn image to some central origin, though technically doesn't affect recognition in some sense
static func translate_to_origin(points):
	# Technically we use 0,0 for origin apparently
	var sum = Vector2.ZERO
	for point in points:
		sum += point
	var centroid = (sum / points.size())
	var translated_points: PackedVector2Array = []
	for point in points:
		translated_points.append(point - centroid)
	return translated_points
