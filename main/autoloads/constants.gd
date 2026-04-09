extends Node
const BOMB_SCENE_PATH: String = "res://bomb/bomb.tscn"
const SHAPE_SCENE_PATH: String = "res://shapes/shape.tscn"
const SHAPE_RESOURCE_PATH_START: String = "res://shapes/shape_resources/"
const SHAPE_RESOURCE_PATH_END: String = "_shape.tres"
const FLOATING_TEXT_PATH: String = "res://ui/floating_text.tscn"
const TILE_SIZE: int = 3
const VIEWPORT_WIDTH: int = 640
const VIEWPORT_HEIGHT: int = 360

const CAMERA_SHAKE_INTENSITY_CAP: float = 8.0
const UI_SHAKE_INTENSITY_CAP: float = 4.0
const MIN_SHAPE_SPEED: int = 62
const MAX_SHAPE_SPEED: int = 70
const BASE_BOMB_RADIUS: int = 77
const BASE_BOUNCY_BALL_SIZE: int = 62
const SPRITE_SCALE: float = 0.5

const DRAG_HAND_CURSOR_ICON: Texture2D = preload("res://ui/assets/cursors/grab_cursor_64.svg")
const POINTER_HAND_CURSOR_ICON: Texture2D = preload("res://ui/assets/cursors/point_hand_cursor.svg")
const OPEN_HAND_CURSOR_ICON: Texture2D = preload("res://ui/assets/cursors/open_hand_cursor_64.svg")
const NORMAL_CURSOR_ICON: Texture2D = preload("res://ui/assets/cursors/cursor_64.svg")

const BUTTON_CLICK_SOUND = preload("res://ui/assets/audio/click-3.wav")
const BUTTON_HOVER_SOUND: AudioStream = preload("res://ui/assets/audio/hover-3.wav")
const ENTER_BUTTON_VOLUME: float = -22.0
const ENTER_PITCH_RANGE: Vector2 = Vector2(0.9, 1.1)
const BUTTON_CLICK_VOLUME: float = -15.0
const BUTTON_CLICK_PITCH: float = 0.47


const GAME_MUSIC = preload("uid://blfyrn5f36j0a")
const GAME_MUSIC_2 = preload("uid://fbfnmarp7o2h")

var POINTS_SAVE_KEY: String = "points"
var MAX_SESSION_POINTS_SAVE_KEY: String = "max_session_points"
var MAX_HIGHEST_BOMB_PROFIT_SAVE_KEY: String = "max_highest_bomb_profit"
var MAX_SESSION_SHAPES_DESTROYED_SAVE_KEY: String = "max_session_shapes_destroyed"
var MAX_LARGEST_CLUSTER_SAVE_KEY: String = "max_largest_cluster"
var MIN_BUTTON_BOUNCE: Vector2 = Vector2(0.95, 0.95)
var MAX_BUTTON_BOUNCE: Vector2 = Vector2(1.15, 1.15)
