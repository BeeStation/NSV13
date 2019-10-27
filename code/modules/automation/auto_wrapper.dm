//Takes input item and attempts to wrap it in wrapping paper acquired from nowhere
/obj/machinery/automation/wrapper
	name = "wrapper"
	desc = "Wraps items in wrapping paper."

/obj/machinery/automation/wrapper/Bumped(atom/movable/input)
	if(isitem(input) || istype(input, /obj/structure/closet))
		contents += input
	..()

/obj/machinery/automation/wrapper/process()
	if(contents.len)
		var/obj/item/I = contents[1]
		if(I.can_be_package_wrapped())
			var/obj/item/smallDelivery/P = new /obj/item/smallDelivery(get_step(src, outputdir))
			var/size = round(I.w_class)
			I.forceMove(P)
			P.name = "[weightclass2text(size)] parcel"
			P.w_class = size
			size = min(size, 5)
			P.icon_state = "deliverypackage[size]"
			adjust_item_drop_location(P)
			playsound(loc, 'sound/machines/ping.ogg', 30, 1)
		else if(istype (contents[1], /obj/structure/closet))
			var/obj/structure/closet/O = contents[1]
			if(!O.opened && O.delivery_icon)
				var/obj/structure/bigDelivery/P = new /obj/structure/bigDelivery(get_step(src, outputdir))
				P.icon_state = O.delivery_icon
				O.forceMove(P)
				playsound(loc, 'sound/machines/ping.ogg', 30, 1)
		else
			contents[1].loc = get_step(src, outputdir)
	..()
