//Legacy areas.
/area/ruin/powered/nsv13/prisonship
	name = "Syndicate prison ship"


/area/ruin/powered/nsv13/trooptransport
	name = "Syndicate troop transport"


/area/ruin/powered/nsv13/gunship
	name = "Syndicate corvette"


/area/ruin/powered/nsv13/yacht
	name = "Luxury yacht"

//Use this area on your boarding maps.
/area/ruin/powered/nsv13/boarding_interior
	name = "Boarding Interior Map"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	has_gravity = STANDARD_GRAVITY
	always_unpowered = FALSE
	valid_territory = FALSE
	unique = FALSE //Instance those areas!

/area/ruin/unpowered/boarding_interior
	name = "Boarding Interior Map (Requires Power)"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	has_gravity = STANDARD_GRAVITY
	valid_territory = FALSE
	unique = FALSE //Instance those areas!
