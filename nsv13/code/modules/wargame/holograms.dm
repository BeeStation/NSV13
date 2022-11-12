/obj/structure/wargame_hologram
	name = "broken holographic wargame marker"
	desc = "You have a feeling like this is supposed to be telling you something, but the hologram must have broken."
	icon = 'nsv13/icons/obj/wargame.dmi'
	icon_state = "broke"
	anchored = TRUE
	density = FALSE
	max_integrity = 1
	obj_flags = UNIQUE_RENAME
	/// What object created this projection? Can be null as a projector isn't required for this to exist
	var/obj/item/wargame_projector/projector

/obj/structure/wargame_hologram/Initialize(mapload, source_projector)
	. = ..()
	if(source_projector)
		projector = source_projector
		LAZYADD(projector.projections, src)

/obj/structure/wargame_hologram/Destroy()
	if(projector)
		LAZYREMOVE(projector.projections, src)
		projector = null
	return ..()

/obj/structure/wargame_hologram/update_overlays()
	. = ..()
	. += mutable_appearance(icon, icon_state)

/*
Projections for 'moving vessels' in order from smallest to largest representation
*/

/obj/structure/wargame_hologram/strike_craft
	name = "strike craft marker"
	desc = "The NT wargame standard representation for a singular strike craft of some kind."
	icon_state = "strikesingle"

/obj/structure/wargame_hologram/strike_craft/wing
	name = "strike craft wing marker"
	desc = "The NT wargame standard representation for a wing of strike craft of some sort."
	icon_state = "strikewing"

/obj/structure/wargame_hologram/ship_marker
	name = "small vessel marker"
	desc = "The NT wargame standard representation of a smaller sized vessel, usually used for corvette sized ships."
	icon_state = "smallship"

/obj/structure/wargame_hologram/ship_marker/medium
	name = "medium vessel marker"
	desc = "The NT wargame standard representation of an average sized vessel, usually used for destroyer sized ships."
	icon_state = "mediumship"

/obj/structure/wargame_hologram/ship_marker/large
	name = "large vessel marker"
	desc = "The NT wargame standard representation of a larger sized vessel, usually used for cruiser sized ships."
	icon_state = "bigship"

/obj/structure/wargame_hologram/ship_marker/large/alternate
	name = "alternate large vessel marker"
	desc = "The NT wargame alternative representation of a larger sized vessel, usually used for special vessels like carriers."
	icon_state = "bigship_alternate"

/obj/structure/wargame_hologram/unidentified
	name = "unidentified contact marker"
	desc = "The NT wargame standard representation for a contact that has not yet been identified."
	icon_state = "unidentified"

/*
Projections for misc stuff, like stations, scout probes, or incoming missiles
*/

/obj/structure/wargame_hologram/missile_warning
	name = "in-flight missile marker"
	desc = "The NT wargame standard representation for a missile or torpedo that is currently en route to its target."
	icon_state = "missile"

/obj/structure/wargame_hologram/probe
	name = "probe marker"
	desc = "The NT wargame standard representation for a probe-sized vessel or structure."
	icon_state = "probe"

/obj/structure/wargame_hologram/stationary_structure
	name = "station marker"
	desc = "The NT wargame standard representation for a space stations of all sizes."
	icon_state = "station"

/obj/structure/wargame_hologram/stationary_structure/platform
	name = "platform marker"
	desc = "The NT wargame standard representation for platforms, armed or not, of all sizes."
	icon_state = "platform"

/*
Projections for space 'terrain' like asteroids and dust clouds
*/

/obj/structure/wargame_hologram/dust
	name = "dust field marker"
	desc = "The NT wargame standard representation for a large cloud of stellar dust."
	icon_state = "dustcloud"

/obj/structure/wargame_hologram/asteroid
	name = "small asteroid marker"
	desc = "The NT wargame standard representation for a small to medium sized asteroid."
	icon_state = "asteroidsmall"

/obj/structure/wargame_hologram/asteroid/large
	name = "large asteroid marker"
	desc = "The NT wargame standard representation for a medium to large sized asteroid."
	icon_state = "asteroidlarge"

/obj/structure/wargame_hologram/asteroid/cluster
	name = "asteroid cluster marker"
	desc = "The NT wargame standard representation for a cluster of smaller asteroids."
	icon_state = "asteroidcluster"

/obj/structure/wargame_hologram/planet
	name = "planetary body marker"
	desc = "The NT wargame standard representation for planetary bodies of all sizes."
	icon_state = "planet"
