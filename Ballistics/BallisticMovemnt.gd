# Made by Aj8841 @ xsnipinblazex@gmail.com 

#This is very basic Ballistic trajectory with a *not* working hit detection
#simulates gravity, drag, and the magnus effect
# this is all I deem necessary for a realistic trajectory for all types of projectiles. Magnus effect simulates magnus and possibly spin drift, haven't seen it yet since I'm making this on godot mobile
# about 4/5 accurate when compared to my references using the F5 Sports Pitchlogic System

#updated 7/28/2024


extends MeshInstance3D # extends any node as long as it doesn't affect the gravity and velocity

var mass = 0.0167 #mass of the object In kg

var Active = false # for future initialization

var iV = 39.294816 # 87.9 mph iV: Initial velocity in m/s
var velocity = Vector3(0, 0, 0) # this is the actual velocity during runtime
var direction = Vector3(0, -0.04, -1) # direction of travel degrees/90
var spin = Vector3(1252, 1480, -858) # spin rate in rpm (sidespin +(CW), backspin +(CCW), riflespin +(CW)) *see commit on github for more infoaa

var angDamp = 0.2 # rotational drag Coefficient 
var linDamp = 0.35 # linear drag Coefficient 
var Dia = 0.075 # diameter of object 
var area = 0.01723 # cross sectional area

var Air_density = 1.225 
const c = 1 # a constant for scaling if needed
var rps = 2 * PI / 60 # rpm to radians a second conversion
var GRAV = -9.81 # acceleration of gravity in m/s
var MoI = 0.09  # moment of inertia 
var airRes = 0.5 * Air_density * area #air resistance factor

var raycast
var lastPos = Vector3()

func _ready():
    velocity = iV * direction # fires in direction with velocoty
    # spin *= Vector3(-1, 1, -1) # makes spin relative to F5 Sports’ pitchlogic system
    Active = true

    # Get the RayCast node
    raycast = $RayCast
    raycast.enabled = true

func _physics_process(delta):
    if Active:
        lastPos = global_transform.origin
        velocity.y += GRAV * delta * c # accelerate to gravity
        var spinforce = (spin * rps) * (Dia / 2) / (mass * (velocity.length() * 2))  # Get the force of the magnus effect
        var AngDrag = -angDamp * spin * (Dia / 2) 
        var torque = -(Dia / 2) * AngDrag
        if spin.length() < 0:
            torque *= -1
        var angAccel = torque / MoI # angular drag
        spin -= angAccel
        var DF = airRes * velocity * velocity * linDamp #linear drag
        velocity -= DF * delta
        velocity += spinforce * delta

        # Update the position of the ball
        global_transform.origin += velocity * delta


        #do hit check here
