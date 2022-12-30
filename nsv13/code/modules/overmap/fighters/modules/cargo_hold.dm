/obj/item/fighter_component/secondary/utility/hold
	name = "cargo hold"
	desc = "A cramped cargo hold for hauling light freight."
	icon_state = "hold_tier1"
	var/max_w_class = WEIGHT_CLASS_GIGANTIC
	var/max_freight = 5

/obj/item/fighter_component/secondary/utility/hold/tier2
	name = "expanded cargo hold"
	icon_state = "hold_tier2"
	tier = 2
	max_freight = 10

/obj/item/fighter_component/secondary/utility/hold/tier3
	name = "\improper S0CC3RMUM Jumbo Sized Cargo Hold"
	desc ="Now with extra space for seating unlucky friends in the boot!"
	icon_state = "hold_tier3"
	tier = 3
	max_freight = 20

/obj/item/fighter_component/secondary/utility/hold/load(obj/structure/overmap/target, atom/movable/AM)
	if(length(contents) >= max_freight || isliving(AM) || istype(AM, /obj/item/fighter_component) || istype(AM, /obj/item/card/id) || istype(AM, /obj/item/modular_computer/tablet/pda) || istype(AM, /obj/structure/overmap)) //This just causess issues, trust me on this)
		return FALSE
	if((AM.move_resist > MOVE_FORCE_DEFAULT) || !AM.doMove(src))
		return //Can't put ultra heavy stuff in
	target.visible_message("[icon2html(src)] [AM] is loaded into the cargo hold")
	playsound(target, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)
	return TRUE
