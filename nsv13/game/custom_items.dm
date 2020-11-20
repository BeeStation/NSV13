/obj/item/melee/classic_baton/telescopic/stunsword
	name = "MK-1 ion current sabre"
	desc = "An exceedingly rare, nigh on priceless weapon which channels a highly unstable current of ions to produce a dazzling blade of pure energy around a durasteel blade. These weapons are highly sought after, and are only given to high ranking officers with a proven track record."
	icon = 'nsv13/icons/obj/items_and_weapons.dmi'
	icon_state = "stunsword"
	item_state = "stunsword"
	lefthand_file = 'nsv13/icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/weapons/melee_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_BULKY
	force = 10
	on_stun_sound = 'nsv13/sound/effects/saberhit.ogg'
	attack_verb = list("immolated", "slashed")
	hitsound = 'sound/weapons/rapierhit.ogg'
	var/stunforce_on = 60
	var/stunforce_off = 0
	var/stunforce = 60
	on_icon_state = "stunsword_active"
	off_icon_state = "stunsword"
	on_item_state = "stunsword_active"
	force_on = 1 //Youre still getting hit by a metal thing.
	force_off = 10
	var/serial_number = 1 //Fluff. Gives it a "rare" collector's feel
	var/max_serial_number = 20

/obj/item/melee/classic_baton/telescopic/stunsword/Initialize()
	. = ..()
	serial_number = rand(1,max_serial_number)

/obj/item/melee/classic_baton/telescopic/stunsword/examine(mob/user)
	. = ..()
	. += "<span class='notice'>This blade has a serial number: [serial_number] of [max_serial_number]</span>"

/obj/item/melee/classic_baton/telescopic/stunsword/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] raises [src] and drives it into their heart! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return BRUTELOSS

/obj/item/melee/classic_baton/telescopic/stunsword/attack_self(mob/user)
	on = !on
	SEND_SIGNAL(src, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_WEAK)
	if(on)
		flick("stunsword_ignite",src)
		visible_message("<span class='warning'>[user] swings [src] around, igniting it in the process.</span>")
		playsound(user.loc, 'nsv13/sound/effects/saberon.ogg', 100, 1)
		to_chat(user, "<span class='notice'>You ignite [src]. Your attacks with it will now stun targets nonlethally.</span>")
		icon_state = on_icon_state
		item_state = on_item_state
		force = force_on
		stunforce = stunforce_on
		attack_verb = list("sliced", "cut", "striken", "immobilized")
		hitsound = 'nsv13/sound/effects/saberhit.ogg'
		set_light(3)
	else
		flick("stunsword_extinguish",src)
		visible_message("<span class='warning'>[user] swings [src] around, extinguishing it in the process.</span>")
		playsound(user.loc, 'nsv13/sound/effects/saberoff.ogg', 100, 1)
		to_chat(user, "<span class='notice'>You extinguish [src]. It will now physically wound targets on impact.</span>")
		item_state = "stunsword_extinguish"
		icon_state = off_icon_state
		item_state = off_icon_state
		slot_flags = ITEM_SLOT_BELT
		stunforce = stunforce_off
		force = force_off
		attack_verb = list("immolated", "slashed")
		hitsound = 'sound/weapons/rapierhit.ogg'
		set_light(0)

	add_fingerprint(user)
	
/obj/item/melee/classic_baton/telescopic/stunsword/attack(mob/living/target, mob/living/user)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.adjustStaminaLoss(stunforce)
		H.apply_damage(force, BRUTE)
		user.do_attack_animation(H)
		playsound(user.loc, hitsound, 100, 1)
		target.lastattacker = user.real_name
		target.lastattackerckey = user.ckey
		target.visible_message("<span class='danger'>[user] has [pick(attack_verb)] [target] with [src]!</span>", \
								"<span class='userdanger'>[user] has [pick(attack_verb)] you with [src]!</span>")
		log_combat(user, target, "stunned")
		return

/obj/item/flashlight/atc_wavy_sticks //I dont know what theyre actually called :)
	name = "Aircraft sigalling sticks"
	desc = "A large set of fluorescent sticks used to direct aircraft around the hangar bay."
	icon = 'nsv13/icons/objects/lighting.dmi'
	icon_state = "wavystick"
	item_state = "glowstick"
	w_class = WEIGHT_CLASS_SMALL
	brightness_on = 6
	color = LIGHT_COLOR_GREEN
	color = COLOR_RED
	grind_results = list(/datum/reagent/phenol = 15, /datum/reagent/hydrogen = 10, /datum/reagent/oxygen = 5) //Meth-in-a-stick
	actions_types = list(/datum/action/item_action/pick_color, /datum/action/item_action/toggle_light)
	var/turf/start_turf
	var/turf/end_turf

/datum/action/item_action/change_color
	name = "Toggle Light"

/obj/item/flashlight/atc_wavy_sticks/ui_action_click(mob/user, var/datum/action/A)
	if(istype(A, /datum/action/item_action/pick_color))
		if(!usr.stat)
			if(light_color == LIGHT_COLOR_GREEN)
				light_color = LIGHT_COLOR_RED
				color = COLOR_RED
			else
				light_color = LIGHT_COLOR_GREEN
				color = COLOR_GREEN
	else
		. = ..()

/obj/effect/temp_visual/dir_setting/wavystick
	icon = 'icons/mob/aibots.dmi'
	icon_state = "path_indicator"
	color = "#ccffcc" //Light green
	duration = 5 SECONDS

/obj/item/flashlight/atc_wavy_sticks/afterattack(atom/target, mob/user, proximity)
	if(!start_turf)
		start_turf = get_turf(target)
		to_chat(user, "<span class='warning'>You point [src] at [target]. Point it at another turf to form a path or alt-click [src] to cancel.</span>")
		new /obj/effect/temp_visual/impact_effect/green_laser(start_turf)
		return
	if(!end_turf)
		var/testDir = get_dir(start_turf,target)
		if((testDir in GLOB.cardinals)) //Because otherwise the icon states glitch the hell out and look disgusting
			end_turf = get_turf(target)
			addtimer(VARSET_CALLBACK(src, start_turf, null), 5 SECONDS) //Clear the path after a while
			addtimer(VARSET_CALLBACK(src, end_turf, null), 5 SECONDS) //Clear the path after a while
			visible_message("<span class='warning'>[user] waves [src] around in a controlled motion.</span>")
			var/turf/last_turf = start_turf
			for(var/turf/T in getline(start_turf,end_turf))
				var/pdir = SOUTH
				if(T == start_turf)
					pdir = testDir
				else
					pdir  = get_dir(last_turf, T)
				new /obj/effect/temp_visual/dir_setting/wavystick(T, pdir)
				last_turf = T
			return
		else
			to_chat(user, "<span class='warning'>You can only indicate in straight lines, not diagonally.</span>")
			return
	. = ..()

/obj/item/flashlight/atc_wavy_sticks/AltClick(mob/user)
	. = ..()
	if(start_turf)
		start_turf = null
		to_chat(user, "<span class='warning'>Cleared target selection</span>")
		add_fingerprint(user)

/obj/item/reagent_containers/food/drinks/solgovcup //Credit to baystation for this sprite!
	name = "solgov branded drinks cup"
	desc = "A cup with solgov's logo clearly stamped on it. 'to remind them of whom they serve'"
	icon = 'nsv13/icons/obj/drinks.dmi'
	icon_state = "solgov"
	volume = 30
	spillable = TRUE
