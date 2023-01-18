/obj/item/wallframe/shuttlecraft_chair
	name = "packaged shuttlecraft chair"
	desc = "A box with all the parts you need to make a wall-mounted shuttlecraft chair."
	icon = 'nsv13/icons/obj/structures/shuttlecraft_seat.dmi'
	icon_state = "install_package"
	materials = list(/datum/material/iron = 10000)
	w_class = WEIGHT_CLASS_BULKY
	result_path = /obj/structure/chair/shuttlecraft_chair
	pixel_shift = -10

/obj/structure/chair/shuttlecraft_chair
	name = "Shuttle Seat"
	desc = "A wall-mounted seat often found on shuttles and dropships."
	icon = 'nsv13/icons/obj/structures/shuttlecraft_seat.dmi'
	icon_state = "shuttle_seat"
	anchored = TRUE
	can_buckle = 1
	buckle_lying = 0
	resistance_flags = NONE
	max_integrity = 250
	integrity_failure = 25
	var/opened = FALSE
	var/mutable_appearance/armrest
	buildstackamount = 5
	item_chair = null
	layer = OBJ_LAYER

/obj/structure/chair/shuttlecraft_chair/Initialize(mapload, ndir, building)
	. = ..()
	if(building)
		setDir(ndir)
	armrest = GetArmrest()
	armrest.layer = ABOVE_MOB_LAYER

/obj/structure/chair/shuttlecraft_chair/proc/GetArmrest()
	return mutable_appearance('nsv13/icons/obj/structures/shuttlecraft_seat.dmi', "belt")

/obj/structure/chair/shuttlecraft_chair/Destroy()
	QDEL_NULL(armrest)
	return ..()

/obj/structure/chair/shuttlecraft_chair/post_buckle_mob(mob/living/M)
	. = ..()
	update_armrest()

/obj/structure/chair/shuttlecraft_chair/proc/update_armrest()
	if(has_buckled_mobs())
		add_overlay(armrest)
	else
		cut_overlay(armrest)

/obj/structure/chair/shuttlecraft_chair/post_unbuckle_mob()
	. = ..()
	update_armrest()

/obj/structure/chair/shuttlecraft_chair/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Alt-click to fold the chair up or down.</span>"

/obj/structure/chair/shuttlecraft_chair/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/chair/shuttlecraft_chair/AltClick(mob/living/user)
    if(!istype(user) || !user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
        return
    if(broken)
        to_chat(user, "<span class='warning'>[src] is broken [opened?"open":"closed"].</span>")
        return
    if(has_buckled_mobs())
        to_chat(user, "<span class='warning'>You can't [opened?"open":"close"] [src] while someone is sitting in it!</span>")
        return
    else
        playsound(loc, 'sound/machines/click.ogg', 15, 1, -3)
        opened = !opened
        can_buckle = !can_buckle
        update_icon()

/obj/structure/chair/shuttlecraft_chair/update_icon()
	if(!opened)
		icon_state = "shuttle_seat"
	else
		icon_state = "seat_up"

/obj/structure/chair/shuttlecraft_chair/Initialize(mapload)
    . = ..()
    var/datum/component/riding/D = LoadComponent(/datum/component/riding)
    D.set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, -10), TEXT_SOUTH = list(0, 10), TEXT_EAST = list(-10, 0), TEXT_WEST = list(10, 0)))
    D.set_vehicle_dir_offsets(NORTH, 0, -10)
    D.set_vehicle_dir_offsets(SOUTH, 0, 10)
    D.set_vehicle_dir_offsets(EAST, -10, 0)
    D.set_vehicle_dir_offsets(WEST, 10, 0)
