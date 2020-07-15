/*
Planet orbit code: a primer

Hey folks, Vsauce here, and today I'm gonna learn you a little physics.

The acceleration of an object needed to maintain a circular path around an object (where acceleration is directed towards the point of orbit)
can be given by a = v^2/r where v is the orbital velocity (linear velocity) and r is the orbit of radius.

Now, this can be expanded upon for all kinds of fancy stuff like mass, gravity, blah blah, but since the physics system implemented in NSV13 doesn't take mass in to account, it
greatly simplifies the math needed to be done here.

Because mass isn't taken into account, and because we have to make up arbitrary values for gravitational acceleration (a, since, we're not on a 1:1 scale with meters, obviously), we need
to get creative.

The solution is this: an orbital radius and centerpoint is all that really needs to be defined. The system will then define velocity and acceleration based on the desired radius. Velocity
is scaled with distance from the centerpoint, decreasing with proportion to the square of distance to adequately represent the relationship between orbital velocity and radius given a constant
acceleration.

At the datum radius (2400, given a distance of 75 tiles from the center of the map, assuming 300x300 maps), the desired angular velocity will be 1 degree/s, which represents that a planet
orbiting in the middle of the map should orbit at about 1 rotation per 6 minutes.

The desired orbital velocity will be calculated from the desired radius of the object, using a known constant acceleration.

To do this we calculate the desired linear velocity of an object orbiting at 1 deg/s, which happens to be 42 u/s at 2400u radius. Next, we calculate the grav_const (or a) to maintain consistent
velocities with respect to radius, with our above described datum orbital radius/orbital speed.

This yields a value of 0.735. The two equations we used for this are v=Wr, and a = v^2/r. This value a is then used to calculate velocity for
any number of different radii, since a will be const and velocity wont. If this doesn't make sense to you, then just accept it.

It just works.


EDIT: planet math shit part 2: ignore everything above boogaloo (kinda)

So, it appears you can actually just edit position directly. for some stupid reason I was thinking the physics engine didn't allow that, whatever.

The above math is still important though, for consistency, but this can be way simplified to a classic physics-on-rails concept where they just follow a path using trig stuff. yay


EDIT 2: planet math mk3

So, uh, after pondering this I realized that the circular motion kinematics stuff doesn't take into account diminishing gravity with distance, meaning a cant be constant with radius or further planets
will orbit faster, not slower, which is not what we want. To fix this, grav_const is changed to a value that will yield the correct value of 0.735 at 2400u when plugged into the inverse square law for
gravity, giving the following final value: 4233600

EDIT3: Well, all the above math gives us a nice baseline, but planets move a bit too fast, the resulting value for gravity below is tweaked until the desired result is achieved.
*/

GLOBAL_VAR_INIT(grav_const, 500000) //don't question this number, just accept it
GLOBAL_LIST_EMPTY(active_planets)


/obj/structure/overmap/planet
	name = "Placeholder"
	desc = "Report this to your friendly local coder."
	icon = 'nsv13/icons/overmap/stellarbodies/planets.dmi'

	bump_impulse = 0 //planets don't give a fuck about ships hitting them.
	bounce_factor = 1 //move, bitch, get out the way, get out the way bitch get out the way.

	faction = "planet"
	wrecked = TRUE

	var/orbit_center_x = 0 //These variables describe the center of the orbit of the planet.
	var/orbit_center_y = 0

	var/orbit_position = 0 //this describes the location of the planet in its orbit, in degrees
	var/orbit_speed = 0 //orbital angular velocity in deg/s
	var/orbit_radius = 0 //the radius at which the planet should orbit the centerpoint

	var/last_planet_process = 0
	no_collide = TRUE //stahp ramming planets damnit


/obj/structure/overmap/planet/Initialize(mapload, radius = 0, center_x = 4800, center_y = 4800) //orbit the center of the overmap, where a star (should) be
	. = ..()

	orbit_radius = radius
	orbit_center_x = center_x
	orbit_center_y = center_y

	GLOB.active_planets += src

	//now that the planet is instantiated, now we determine its initial position and fill in the blanks

	orbit_position = rand(0, 359)
	position.x = orbit_center_x + orbit_radius * cos(orbit_position)
	position.y = orbit_center_y + orbit_radius * sin(orbit_position)

	set_posi2real(position.x, position.y)

	var/gravitational_acceleration = GLOB.grav_const / orbit_radius ** 2
	var/linear_velocity = sqrt(gravitational_acceleration * orbit_radius)

	var/orbit_rad = linear_velocity / orbit_radius //orbit speed in radians

	orbit_speed = TODEGREES(orbit_rad)

/obj/structure/overmap/planet/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/grav_maker, 30) //planets exert gravity



/obj/structure/overmap/planet/process() //hijack the physics processing loop before it fires and just inject a specific velocity into it that moves the planet to where it should be in its orbit
	var/time = min(world.time - last_planet_process, 10)
	time /= 10 // fuck off deciseconds
	last_planet_process = world.time

	//rotate the planet icon so it faces the dark side away from the primary
	angle = -(orbit_position + 45)
	//first calculate change in orbit position

	orbit_position += orbit_speed * time
	if(orbit_position > 359) //technically this doesn't matter, but it's for the sanity of VV for planets over time
		orbit_position -= 360

	//then calculate the difference in position, and tell the physics engine to get movin'

	var/new_pos_x = orbit_center_x + orbit_radius * cos(orbit_position)
	var/new_pos_y = orbit_center_y + orbit_radius * sin(orbit_position)

	var/dx = new_pos_x - position.x
	var/dy = new_pos_y - position.y

	velocity.x = dx / 32
	velocity.y = dy / 32

	..(null, time) // run the normal movement code, using our time reference instead of the normal overmap one, which should eliminate discrepencies between the two loops and prevent stuttering


/obj/structure/overmap/planet/gas
	name = "barren planet"
	desc = "A barren planet with a very thin atmosphere."
	icon_state = "planet_gas"

/obj/structure/overmap/planet/ocean
	name = "ocean planet"
	desc = "A planet that has water. Lots of it."
	icon_state = "planet_ocean"

/obj/structure/overmap/planet/ice
	name = "exotic planet"
	desc = "Planets just want to have fun."
	icon_state = "planet_small"

/obj/structure/overmap/planet/red
	name = "arid planet"
	desc = "Bring a horse, and make sure to take it to the old town road."
	icon_state = "planet_red"

/obj/structure/overmap/planet/cloud
	name = "gas giant"
	desc = "In a universe full of playas, this planet's a pimp."
	icon_state = "planet_cloud"

/obj/structure/overmap/planet/swirly
	name = "exotic ocean planet"
	desc = "Oceans just wanna have fun."
	icon_state = "planet_swirly"

/obj/structure/overmap/planet/jungle
	name = "jungle planet"
	desc = "From orbit you swear you can see a huge temple and dudes running around in orange flight suits. Strange."
	icon_state = "planet_green"

/obj/structure/overmap/planet/rockocean
	name = "ice planet"
	desc = "Bring a coat."
	icon_state = "planet_rockocean"