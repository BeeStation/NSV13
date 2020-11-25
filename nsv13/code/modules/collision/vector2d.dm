/*

Vector class written by qwertyquerty and Kmc2000

This uses operator overloading

Special thanks to qwertyquerty for explaining and dictating a lot of this! (I've mostly translated his pseudocode into readable byond code)

*/

/datum/vector2d
	var/x
	var/y

/*
Constructor for vector2d objects, taking a simple X,Y coordinate.
*/
/datum/vector2d/New(x = 0, y = 0)
	src.x = x
	src.y = y
	..()

/datum/vector2d/Destroy(force, ...)
	. = ..()
	return QDEL_HINT_QUEUE

/*
Method to set our position directly
*/
/datum/vector2d/proc/_set(x,y,sanity=FALSE)
	src.x = x
	src.y = y
	if(sanity)
		if(!isnum_safe(x) || !isnum_safe(y))
			src.x = 0
			src.y = 0
			testing("What the fuck are you doing to vectors: [x] [y] for [usr?.name]")
		src.x = isnum_safe(x) ? src.x : 0
		src.y = CLAMP(src.y, -world.maxy*32, world.maxy*32)

/*
Method to overload the + operator to add a vector to another vector
@return a new vector with the desired x,y after addition
*/
/datum/vector2d/proc/operator+(datum/vector2d/b)
	if(isnum(b))
		return new /datum/vector2d(x + b, y + b)
	else if(istype(b, /datum/vector2d))
		return new /datum/vector2d(x + b.x, y + b.y)

/*
Method to overload the += operator to add the X,Y coordinates to our own ones, without making a new vector2d
*/
/datum/vector2d/proc/operator+=(datum/vector2d/b)
	if(isnum(b))
		x += b
		y += b
	else if(istype(b, /datum/vector2d))
		x += b.x
		y += b.y

/*
Method to overload the - operator to subtract a vector from this one.
@return a new vector with the desired X,Y after operation performed
*/
/datum/vector2d/proc/operator-(datum/vector2d/b)
	if(!b)
		return new /datum/vector2d(-x, -y)
	else if(isnum(b))
		return new /datum/vector2d(x - b, y - b)
	else if(istype(b, /datum/vector2d))
		return new /datum/vector2d(x - b.x, y - b.y)

/*
Method to overload the += operator to subtract the X,Y coordinates to our own ones, without making a new vector2d
*/
/datum/vector2d/proc/operator-=(datum/vector2d/b)
	if(isnum(b))
		x -= b
		y -= b
	else if(istype(b, /datum/vector2d))
		x -= b.x
		y -= b.y

/*
Method to overload the * operator to multiply this vector by another one
@return a vector2d object with the required calculations done.
*/
/datum/vector2d/proc/operator*(datum/vector2d/b)
	if(isnum(b))
		return new /datum/vector2d(x * b, y * b)
	else if(istype(b, /datum/vector2d))
		return new /datum/vector2d(x * b.x, y * b.y)

/*
Method to overload the *= operator to multiply the X,Y coordinates to our own ones, without making a new vector2d
*/
/datum/vector2d/proc/operator*=(datum/vector2d/b)
	if(isnum(b))
		x *= b
		y *= b
	else if(istype(b, /datum/vector2d))
		x *= b.x
		y *= b.y

/*
Method to overload the / operator to divide this vector by another one
@return a vector2d object with the required calculations done.
*/
/datum/vector2d/proc/operator/(datum/vector2d/b)
	if(isnum(b))
		return new /datum/vector2d(x / b, y / b)
	else if(istype(b, /datum/vector2d))
		return new /datum/vector2d(x / b.x, y / b.y)

/*
Overrides the ~= operator to check if a vector has the same x and y values as another one (equivalency)
@return 1 if the vectors are equivalent, 0 if not
*/
/datum/vector2d/proc/operator~=(datum/vector2d/b)
	return (istype(b, /datum/vector2d) && x == b.x && y == b.y)

/*
Convert the vector to a readable format: [x, y]
@return a string representation of the vector: [x, y]
*/
/datum/vector2d/proc/to_string()
	return "\[[src.x], [src.y]\]"

/*
Calculate the dot product of two vectors
@return the dot product of the two vectors
*/
/datum/vector2d/proc/dot(var/datum/vector2d/other)
	return src.x * other.x + src.y * other.y

/*
Calculate the cross product of two vectors
@return the cross product of the two vectors
*/
/datum/vector2d/proc/cross(var/datum/vector2d/other)
	return src.x * other.y - src.y * other.x

/*
Get the magnitude of a vector squared
@return the magnitude of the vector squared (hypot)^2
*/
/datum/vector2d/proc/ln2()
	return src.dot(src)

/*
Get the magnitude of a vector
@return the magnitude of the vector (hypot)
*/
/datum/vector2d/proc/ln()
	return sqrt(src.ln2())

/*
Get the angle of a vector
@return the angle of the vector (atan) in radians
*/
/datum/vector2d/proc/angle()
	return ATAN2(src.x, src.y)

/*
Normalize the vector so it has a magnitude of 1
@return a normalized version of the vector
*/
/datum/vector2d/proc/normalize()
	RETURN_TYPE(/datum/vector2d)
	return src / src.ln()

/*
Methods for projecting a vector onto another
*/
/datum/vector2d/proc/project(var/datum/vector2d/other)
	RETURN_TYPE(/datum/vector2d)
	var/amt = src.dot(other) / other.ln2()
	src.x = amt * other.x
	src.y = amt * other.y
	return src

/datum/vector2d/proc/project_n(var/datum/vector2d/other)
	RETURN_TYPE(/datum/vector2d)
	var/amt = src.dot(other)
	src.x = amt * other.x
	src.y = amt * other.y
	return src

/*
Methods for reflecting a vector across an axis
*/
/datum/vector2d/proc/reflect(axis)
	src.project(axis)
	src *= -2

/datum/vector2d/proc/reflect_n(axis)
	src.project_n(axis)
	src *= -2

/*
Quickly rotate the vector a 4th turn
@return the rotated vector
*/
/datum/vector2d/proc/perp()
	RETURN_TYPE(/datum/vector2d)
	var/newx = src.y
	var/newy = -src.x
	src.x = newx
	src.y = newy
	return src

/*
A method to copy the values of another vector onto this one
*/
/datum/vector2d/proc/copy(var/datum/vector2d/other)
	src.x = other.x
	src.y = other.y

/*
A method to make a clone of this vector
@return a new vector2d with the same stats as this one
*/
/datum/vector2d/proc/clone()
	RETURN_TYPE(/datum/vector2d)
	return new /datum/vector2d(x,y)

/*
Method to turn this vector counter clockwise by a desired angle
@return the rotated vector
*/
/datum/vector2d/proc/rotate(angle)
	RETURN_TYPE(/datum/vector2d)
	var/s = sin(angle)
	var/c = cos(angle)
	var/newx = c*x + s*y
	var/newy = -s*x + c*y
	x = newx
	y = newy
	return src

/*
Negate both values of a vector without making a new one
@return the reversed vector
*/
/datum/vector2d/proc/reverse(angle)
	RETURN_TYPE(/datum/vector2d)
	src.x = -src.x
	src.y = -src.y
	return src
