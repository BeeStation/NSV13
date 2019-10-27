//Labels items like a hand labeler

/obj/machinery/automation/label //Takes a recipe datum, accepts ingredients for them and makes it
	name = "auto labeler"
	desc = "Takes in items and labels them like a hand labeler. However if a crate is inserted, it will generate a manifest of all contents alongside giving a label."
	var/to_label_on = ""
	radial_categories = list(
	"Change Label Name"
	)

/obj/machinery/automation/label/Initialize()
	. = ..()
	radial_categories["Change Label Name"] = image(icon = 'icons/mob/radial.dmi', icon_state = "auto_change_label")

/obj/machinery/automation/label/examine(mob/user)
	. = ..()
	if(.)
		to_chat(user, "<span class='notice'>Current label: <span class='bold'>[to_label_on ? to_label_on : "No label currently set!!!"]</span></span>")

/obj/machinery/automation/label/MakeRadial(mob/living/user)
	var/category = show_radial_menu(user, src, radial_categories, null, require_near = TRUE)
	if(category)
		switch(category)
			if("Change Label Name")
				to_label_on = stripped_input(usr,"New label: ","Input a custom label!", "", MAX_NAME_LEN)

/obj/machinery/automation/label/process()
	if(contents.len && isitem(contents[1]))
		if(to_label_on)
			contents[1].name = "[contents[1].name] ([to_label_on])"
			playsound(loc, 'sound/machines/ping.ogg', 30, 1)
			contents[1].loc = get_step(src, outputdir)
		else
			playsound(loc, 'sound/machines/ping.ogg', 30, 1)
			contents[1].loc = get_step(src, outputdir)

	else
		if(contents.len && istype(contents[1], /obj/structure/closet/crate))
			var/obj/structure/closet/crate/acrate = contents[1]
			if(!acrate.manifest)
				var/obj/item/paper/fluff/jobs/cargo/manifest/P = new(acrate)
				P.name = "crate content manifest"
				P.info += "<h2>Crate Content List</h2><br/>"
				for(var/atom/movable/AM in acrate.contents - P)
					P.info += "<li>[AM.name]</li>"
					P.info += "<br/>"
				P.forceMove(acrate)
				acrate.manifest = P
				acrate.update_icon()
			playsound(loc, 'sound/machines/ping.ogg', 30, 1)
			acrate.loc = get_step(src, outputdir)

/obj/machinery/automation/label/Bumped(atom/input)
	if(isitem(input) || istype(input, /obj/structure/closet/crate))
		contents += input
	..()
