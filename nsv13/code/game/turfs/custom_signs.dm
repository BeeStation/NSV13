/obj/structure/sign/solgov_seal //Credit to baystation for these sprites!
	name = "Seal of the solarian government"
	desc = "A seal emblazened with a gold trim depicting the star, sol."
	icon = 'nsv13/icons/obj/solgov_logos.dmi'
	icon_state = "solgovseal"
	pixel_y = 27

/obj/structure/sign/solgov_flag
	name = "solgov banner"
	desc = "A large flag displaying the logo of solgov, the local government of the sol system."
	icon = 'nsv13/icons/obj/solgov_logos.dmi'
	icon_state = "solgovflag-left"
	pixel_y = 26

/obj/structure/sign/solgov_flag/right
	icon_state = "solgovflag-right"


//3/4 signs stolen from bay
/obj/structure/sign/ship
	icon = 'nsv13/icons/obj/decals.dmi'

/obj/structure/sign/ship/space
	name = "WARNING: HARD VACUUM AHEAD"
	icon_state = "space"

/obj/structure/sign/ship/fire
	name = "Fire hazard"
	icon_state = "fire"

/obj/structure/sign/ship/nosmoking
	name = "No smoking"
	icon_state = "nosmoking"

/obj/structure/sign/ship/smoking
	name = "Smoking area"
	icon_state = "smoking"

/obj/structure/sign/ship/securearea
	name = "CAUTION: SECURE AREA"
	icon_state = "securearea"

/obj/structure/sign/ship/securearea/alt
	name = "CAUTION: SECURE AREA"
	icon_state = "securearea2"

/obj/structure/sign/ship/armoury
	name = "Weapons locker"
	icon_state = "armory"

/obj/structure/sign/ship/server
	name = "Server room"
	icon_state = "server"

/obj/structure/sign/ship/shock
	name = "CAUTION: HIGH VOLTAGE"
	icon_state = "shock"

/obj/structure/sign/ship/hikpa
	name = "CAUTION: HIGH PRESSURE"
	icon_state = "hikpa"

/obj/structure/sign/ship/mail
	name = "Mail"
	icon_state = "mail"

/obj/structure/sign/ship/radiation
	name = "CAUTION: RADIATION"
	icon_state = "radiation"

/obj/structure/sign/ship/examroom
	name = "Examination room"
	icon_state = "examroom"

/obj/structure/sign/ship/science
	name = "Research and development"
	icon_state = "science"

/obj/structure/sign/ship/chemistry
	name = "Chemistry"
	icon_state = "chemistry"

/obj/structure/sign/ship/medical
	name = "Medbay"
	icon_state = "bluecross2"

/obj/structure/sign/ship/plaque
	name = "Dedication plaque"
	desc = "A plaque with several things written on it."
	icon_state = "lightplaque"

/obj/structure/sign/ship/plaque/dark
	icon_state = "darkplaque"

/obj/structure/sign/ship/plaque/light
	icon_state = "lightplaquealt"

/obj/structure/sign/ship/plaque/examine(mob/user)
	. = ..()
	var/obj/structure/overmap/scream = get_overmap()
	to_chat(user, "<span class='notice'>This plaque records those who attended the launching ceremony of the ship you're on. <br> This plaque names the ship as: <b>[scream?.name]</b> </span>")

/obj/structure/sign/ship/pods
	name = "Escape pods"
	icon_state = "podsnorth"

/obj/structure/sign/ship/pods/north
	icon_state = "podssouth"

/obj/structure/sign/ship/pods/east
	icon_state = "podseast"

/obj/structure/sign/ship/pods/west
	icon_state = "podswest"

/obj/structure/sign/ship/deck
	name = "Deck 1"
	icon_state = "deck-1"

/obj/structure/sign/ship/deck/two
	name = "Deck 2"
	icon_state = "deck-2"

/obj/structure/sign/ship/deck/three
	name = "Deck 3"
	icon_state = "deck-3"

/obj/structure/sign/ship/deck/four
	name = "Deck 4"
	icon_state = "deck-4"

/obj/structure/sign/ship/deck/five
	name = "Deck 5"
	icon_state = "deck-5"
