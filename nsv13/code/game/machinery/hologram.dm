/obj/machinery/holopad/proc/create_admin_hologram(client/C)
	set waitfor = FALSE
	RETURN_TYPE(/mob/living/simple_animal/admin_holopad)
	var/icon/final = icon()
	var/mob/living/carbon/human/dummy/D = new(locate(1,1,1)) //spawn on 1,1,1 so we don't have runtimes when items are deleted
	var/new_name = null //Name for the hologram. Can be defaulted to your char name otherwise.
	if(alert("Do you want to use your character slot ([C.prefs.active_character.real_name]) or choose a new name and have a random appearance?",src,"Yes","No") == "Yes")
		C.prefs.active_character.copy_to(D)
		new_name = C.prefs.active_character.real_name
	else
		randomize_human(D)
		new_name = input(C, "Select a name for your communications hologram (leave blank to just be called hologram)", "Robust hologram creator") as text
	C.cmd_admin_dress(D)
	for(var/dir in list(2, 1, 4, 8)) //A little bit hacky, but does the trick. BYOND's icon format starts with a south facing dir, while cardinals starts with NORTH.
		CHECK_TICK
		D.setDir(dir) //Set the dir of the mannequin to face the next direction
		COMPILE_OVERLAYS(D) //Prepare it for an image capture
		var/icon/I = icon(getFlatIcon(D), frame = 1) //And finally clone the appearance of our new dummy character.
		final.Insert(I, "hologram", frame=1, dir=dir) //Then, we add this new icon_state and direction to the icon we're generating. This is then cleanly applied to the dummy mob to give it its appearance.
	qdel(D)
	say("Incoming priority one transmission from Central Command.")
	playsound(src, 'nsv13/sound/effects/computer/admin_holopad_activate.ogg', 100, FALSE)
	var/mob/Hologram = new /mob/living/simple_animal/admin_holopad(get_turf(src))
	. = Hologram // Our calling proc won't wait for us when we sleep so we set the return value now
	Hologram.alpha = 0
	Hologram.name = (new_name) ? new_name : Hologram.name
	Hologram.icon = final
	Hologram.grant_all_languages(grant_omnitongue=TRUE) //This is an admin thing, so this makes sense to me.
	Hologram.mouse_opacity = MOUSE_OPACITY_TRANSPARENT//So you can't click on it.
	Hologram.layer = FLY_LAYER//Above all the other objects/mobs. Or the vast majority of them.
	sleep(3.6 SECONDS) // Also returns hologram to calling proc
	//codersprite some holo effects here
	animate(Hologram, alpha = 100,time = 20)
	Hologram.add_atom_colour("#77abff", FIXED_COLOUR_PRIORITY)
	Hologram.ckey = C.ckey

/mob/living/simple_animal/admin_holopad
	name = "Hologram"
	desc = "A wacky little character!"
	icon_state = "hologram"
	incorporeal_move = TRUE
	status_flags = GODMODE
	var/datum/beam/current_beam = null
	var/obj/machinery/holopad/source = null

/mob/living/simple_animal/admin_holopad/Initialize(mapload)
	. = ..()
	source = locate(/obj/machinery/holopad) in get_turf(src)
	current_beam = new(src,source,time=INFINITY,maxdistance=INFINITY, beam_icon_state="hologram",btype=/obj/effect/ebeam)
	INVOKE_ASYNC(current_beam, /datum/beam.proc/Start)
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, .proc/check_distance)

/mob/living/simple_animal/admin_holopad/proc/check_distance()
	var/dist = get_dist(src, source)
	if(dist > (source.holo_range)/2)
		to_chat(src, "<span class='warning'>You're moving too far from [source] ([dist] / [source.holo_range] m)</span>")
	if(dist > source.holo_range)
		to_chat(src, "<span class='warning'>Range exceeded. Transmission terminated.</span>")
		qdel(src)

/mob/living/simple_animal/admin_holopad/ClickOn(target)
	. = ..()
	if(alert("End communications?",src,"Yes","No") == "Yes")
		qdel(src)

/mob/living/simple_animal/admin_holopad/Destroy()
	qdel(current_beam)
	UnregisterSignal(src, COMSIG_MOVABLE_MOVED)
	playsound(src, 'nsv13/sound/effects/computer/hum.ogg', 100, FALSE)
	return ..()

/obj/machinery/holopad/attack_ghost(mob/user)
	if(!check_rights_for(user.client, R_ADMIN))
		return
	if(alert("Appear as a hologram?",src,"Yes","No") == "No")
		return
	create_admin_hologram(user.client)
