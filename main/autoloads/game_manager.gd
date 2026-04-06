extends Node
var session_data: Array[int] = [0, 0, 0, 0]
var total_points: int = 0

var max_session_points : int = 0
var max_session_shapes_destroyed: int = 0
var max_largest_cluster: int = 0
var max_highest_bomb_profit : int = 0

var session_number: int = 0

var detonation_idx_value: int = 0
var current_met_threshold: int = 0
var detonation_thresholds: Array[int] = [12, 80, 190]
