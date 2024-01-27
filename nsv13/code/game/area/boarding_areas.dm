/area/nsv/boarding_pod
	name = "Kapsuła Desantowa Syndykatu" //AQ EDIT
	icon_state = "syndie-ship"
	requires_power = FALSE

//Legacy areas.
/area/ruin/powered/nsv13/prisonship
	name = "Statek Więzienny Syndykatu" //AQ EDIT


/area/ruin/powered/nsv13/trooptransport
	name = "Transportowiec Syndykatu" //AQ EDIT


/area/ruin/powered/nsv13/gunship
	name = "Korweta Syndykatu" //AQ EDIT


/area/ruin/powered/nsv13/yacht
	name = "Luksusowy Yacht" //AQ EDIT

//Use this area on your boarding maps.
/area/ruin/powered/nsv13/boarding_interior
	name = "Mapa Wewnętrzna Abordażu" //AQ EDIT
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	has_gravity = STANDARD_GRAVITY
	always_unpowered = FALSE

/area/ruin/unpowered/boarding_interior
	name = "Mapa Wewnętrzna Abordażu (Wymaga Prądu)" //AQ EDIT
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	has_gravity = STANDARD_GRAVITY
