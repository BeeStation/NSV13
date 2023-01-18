/*Vectors but they're actually matrices
	operator overload-less edition

	Every matrix can be imagined to represent a multiplication with the vector (1 1)
		For example: Matrix A * (1 1) = (-1 2) if Matrix A is the below:
		-1 0 0
		 0 2 0
		 0 0 1
		This is done to allow vector-like operator interactions without overloading, as vectors are essentially column matrices
		You just have to keep in mind x and y are actually the variables a and e

	Most of the procs here are just lazily edited versions from vector2d.dm to work with a matrix, so credit goes to qwertyquerty and Kmc2000 for that implementation.

Written by Bokkiewokkie
*/


/matrix/vector/New(x=0,y=0,b=0,c=0,d=0,f=0)
	return ..(x,b,c,d,y,f)

//Set the X and Y positions
/matrix/vector/proc/_set(x,y,sanity=FALSE)
	a = x
	e = y
	if(sanity) //fall back to 0 if the inputs are invalid.
		if(!isnum_safe(x))
			a = 0
		if(!isnum_safe(y))
			e = 0

/matrix/vector/Destroy(force, ...)
	. = ..()
	return QDEL_HINT_QUEUE

/matrix/vector/proc/to_string()
	return "\[[a], [e]\]"

/matrix/vector/proc/dot(var/matrix/vector/V)
	return a * V.a + e * V.e

/matrix/vector/proc/cross(var/matrix/vector/V)
	return a * V.e - e * V.a

/matrix/vector/proc/ln2()
	return dot(src)

/matrix/vector/proc/ln()
	return sqrt(dot(src))

/matrix/vector/proc/angle()
	return ATAN2(a, e)

/matrix/vector/proc/normalize()
	return src / src.ln()


/matrix/vector/proc/project(var/matrix/vector/V)
	var/amt = src.dot(V) / V.ln2()
	a = amt * V.a
	e = amt * V.e
	return src

/matrix/vector/proc/project_n(var/matrix/vector/V)
	var/amt = src.dot(V)
	a = amt * V.a
	e = amt * V.e
	return src

/matrix/vector/proc/reflect(axis)
	project(axis)
	src *= -2

/matrix/vector/proc/reflect_n(axis)
	project_n(axis)
	src *= -2

/matrix/vector/proc/perp()
	RETURN_TYPE(/matrix/vector)
	return Turn(90)

/matrix/vector/proc/copy(var/matrix/vector/V)
	a = V.a
	e = V.e
	return src

/matrix/vector/proc/clone()
	return new /matrix/vector(a, e)

/matrix/vector/proc/rotate(angle)
	return Turn(angle)

/matrix/vector/proc/reverse()
	return Multiply(-1)

