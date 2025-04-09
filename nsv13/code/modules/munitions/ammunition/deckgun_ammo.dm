
//Artillery shells

/obj/item/ship_weapon/ammunition/naval_artillery //Huh gee this sure looks familiar don't it...
	name = "\improper FTL-13 Naval Artillery Round"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "torpedo"
	desc = "A large shell designed to deliver a high-yield warhead upon high-speed impact with solid objects. You need to arm it with a multitool before firing."
	anchored = FALSE
	w_class = WEIGHT_CLASS_GIGANTIC
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	density = TRUE
	projectile_type = /obj/item/projectile/bullet/mac_round //What bullet type we fire
	obj_integrity = 300 //Beefy, relatively hard to use as a grief tool.
	max_integrity = 300
	volatility = 3 //Majorly explosive, when armed
	var/armed = FALSE //Do it do the big boom?
	var/speed = 0.5 //Needs powder to increase speed.

/obj/item/ship_weapon/ammunition/naval_artillery/armed //This is literally just for mail.
	armed = TRUE

// Handles shell powder load damage modifiers
/obj/item/ship_weapon/ammunition/naval_artillery/proc/handle_shell_modifiers(obj/item/projectile/proj)
	return

/obj/item/ship_weapon/ammunition/naval_artillery/cannonball
	name = "cannon ball"
	desc = "The QM blew the cargo budget on corgis, the clown stole all our ammo, we've got half a tank of plasma and are halfway to Dolos. Hit it."
	icon_state = "torpedo_ball"
	projectile_type = /obj/item/projectile/bullet/mac_round/cannonshot
	obj_integrity = 100
	max_integrity = 100
	climbable = TRUE //No ballin'
	climb_time = 25
	climb_stun = 3
	volatility = 0
	explode_when_hit = FALSE //Literally just iron

/obj/item/ship_weapon/ammunition/naval_artillery/cannonball/admin
	desc = "This cannon ball seems to be so comically large it's impossible to scale!"
	anchored = TRUE
	no_trolley = TRUE //Can still be loaded into a gun if you're really dedicated.
	projectile_type = /obj/item/projectile/bullet/mac_round/cannonshot/admin
	climb_time = 600
	climb_stun = 10
	obj_integrity = 1000
	max_integrity = 1000

/obj/item/ship_weapon/ammunition/naval_artillery/ap
	name = "\improper TX-101 Armour Penetrating Naval Artillery Round"
	desc = "A massive diamond-tipped round which can slice through armour plating with ease to deliver a lethal impact. Best suited for targets with heavy armour such as destroyers and up."
	icon_state = "torpedo_ap"
	projectile_type = /obj/item/projectile/bullet/mac_round/ap


/obj/item/ship_weapon/ammunition/naval_artillery/ap/handle_shell_modifiers(obj/item/projectile/proj)
	if(speed >= NAC_NORMAL_POWDER_LOAD)
		proj.damage = proj.damage * CLAMP(log(10, speed * 5), 1, 2) // at 2 speed (or 100% powder load), damage mod is 1, logarithmically scaling up/down based on powder load
	proj.armour_penetration = proj.armour_penetration * CLAMP(sqrt(speed * 0.5), 0.5, 3)

/obj/item/ship_weapon/ammunition/naval_artillery/homing
	name = "FTL-1301 Magneton Naval Artillery Round"
	desc = "A specialist artillery shell which can home in on a target using its hull's innate magnetism, while less accurate than torpedoes, these shells are still a very viable option."
	icon_state = "torpedo_homing"
	projectile_type = /obj/item/projectile/bullet/mac_round/magneton

/obj/item/ship_weapon/ammunition/naval_artillery/multitool_act(mob/living/user, obj/item/I)
	. = ..()
	if(!do_after(user, 2 SECONDS, target = src))
		return
	playsound(src, 'sound/machines/click.ogg', 50, 1)
	armed = !armed
	var/datum/component/volatile/kaboom = GetComponent(/datum/component/volatile)
	kaboom.set_volatile_when_hit(armed) //Shells only go up when they're armed.
	icon_state = (armed) ? "[initial(icon_state)]_armed" : initial(icon_state)

/obj/item/ship_weapon/ammunition/naval_artillery/examine(mob/user)
	. = ..()
	. += "[(armed) ? "<span class='userdanger'>It is currently armed and ready to fire!</span>" : "<span class ='notice'>It must be armed before firing.</span>"]"


//Powder bags

/obj/item/powder_bag
	name = "gunpowder bag"
	desc = "A highly flammable bag of gunpowder which is used in naval artillery systems."
	icon = 'nsv13/icons/obj/munitions/deck_gun.dmi'
	icon_state = "powder"
	density = TRUE
	w_class = WEIGHT_CLASS_HUGE // Bag is big
	var/volatility = 2 //Gunpowder is volatile...
	var/power = 0.5

/obj/item/powder_bag/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands=TRUE)
	AddComponent(/datum/component/volatile, volatility, TRUE)

/obj/item/powder_bag/plasma
	name = "plasma-based projectile accelerant"
	desc = "An extremely powerful 'bomb waiting to happen' which can propel naval artillery shells to high speeds with half the amount of regular powder!"
	icon_state = "spicypowder"
	power = 1
	volatility = 4 //DANGEROUSLY VOLATILE. Can send the entire magazine up in smoke.

/obj/item/powder_bag/hungry
	name = "gunpowder bag" // full name is built in update_name()
	desc = "Cute!"
	icon_state  = "hungrypowder"
	power = 1
	volatility = 3
	var/is_evolving = FALSE // async my beloved
	var/Elevel = 1
	var/energy = 0
	var/next_evolve = 15
	var/devour_chance = 0 // chance to eat feeder, increases with each evolution level
	var/devouring = FALSE
	// enraged related variables
	var/enraged = FALSE
	var/mob/living/target
	var/satisfied_until // we don't attack anyone until we've passed this timestamp
	var/satisfaction_duration = 5 MINUTES

/obj/item/powder_bag/hungry/Initialize(mapload)
	. = ..()
	if(!mapload)
		playsound(src, 'sound/items/eatfood.ogg', 100, 1)
	update_state()

	var/datum/component/volatile/VC = GetComponent(/datum/component/volatile)
	VC.explosion_scale = 0.5

/**
 * Updates the current state of the hungry bag.
 */
/obj/item/powder_bag/hungry/proc/update_state()
	var/prefix
	switch(Elevel)
		if(0 to 3)
			prefix = "famished"
		if(4 to 6)
			prefix = "ravenous"
			icon_state = "hungrypowder_wobble"
		if(7 to 9)
			prefix = "starving"
		if(10 to 12)
			prefix = "malnourished"
			icon_state = "hungrypowder_fastwobble"
		if(13 to 15)
			prefix = "hungry"
		if(16 to 18)
			prefix = "peckish"
		if(19 to 21)
			prefix = "well-fed"
			icon_state = "hungrypowder_shake"
		if(22 to 24)
			prefix = "stuffed"
		if(25 to 27)
			prefix = "gluttonized"
		else
			prefix = "enraged"
			icon_state = "hungrypowder_shakeflash"
			SpinAnimation(20, 1, pick(0, 1))
			if(!enraged)
				enraged = TRUE
				START_PROCESSING(SSobj, src)
	name = "[prefix] [initial(name)]"

/obj/item/powder_bag/hungry/attackby(obj/item/I, mob/living/user)
	if(!istype(I, /obj/item/reagent_containers/food/snacks))
		return ..()
	if(!istype(user, /mob/living/carbon/human))
		to_chat(user, "<span class='info'>\The [src] is too lonely to eat right now.</span>")
		return
	if(!do_after(user, 7, TRUE, src))
		return
	if(is_evolving || devouring)
		to_chat(user, "<span class='info'>\The [src] can't eat right now.</span>")
		return
	var/obj/item/reagent_containers/food/snacks/F = I
	var/list/food_reagents = F.reagents.reagent_list + F.bonus_reagents
	var/datum/reagent/toxin/plasma/plasma = locate() in food_reagents
	if(plasma)
		// Too spicy for Mr Bag's taste
		playsound(loc, 'sound/items/eatfood.ogg', 100, 1)
		visible_message("<span class='danger'>\The [src] begins to expand!</span>")
		var/delay = max(50 - plasma.volume, 5)
		var/datum/component/volatile/VC = GetComponent(/datum/component/volatile)
		addtimer(CALLBACK(VC, TYPE_PROC_REF(/datum/component/volatile/, explode)), delay)
		Shake(10, 10, delay)
		return
	var/nutri = 0
	// loop instead of locate() so we can catch subtypes too
	for(var/datum/reagent/consumable/nutriment/N in food_reagents)
		nutri += N.volume
	if(!nutri)
		to_chat(user, "<span class='info'>\The [F] is not nutritious enough!</span>")
		return
	visible_message("<span class='notice'>\The [src] takes a huge bite out of [F]!</span>")
	energy += nutri * 2
	qdel(F)
	if(energy >= next_evolve)
		evolve(user)
	playsound(loc, 'sound/items/eatfood.ogg', 100, 1)

/**
 * Increases the bag's power and volatility, while also potentially causing it to become aggressive towards the feeder.
 * * Feeder: Optional Argument, the individual who fed the bag, causing it to evolve.
 */
/obj/item/powder_bag/hungry/proc/evolve(mob/living/feeder)
	set waitfor = FALSE
	is_evolving = TRUE
	while(energy >= next_evolve)
		Elevel++
		power += 2
		volatility += 2
		next_evolve = max(round(next_evolve ** 1.015, 1), next_evolve + initial(next_evolve))

		update_state() // we update state on every iteration so we can't jump over any switch ranges

		devour_chance++
		if(feeder && prob(devour_chance))
			devour_chance = max(devour_chance - 10, 1)
			playsound(feeder, 'sound/effects/tendril_destroyed.ogg', 100, 0)
			visible_message("<span class='danger'>\The [src] twitches violently as it begins to rapidly roll towards [feeder]!</span>")
			sleep(20)
			var/turf/T = get_turf(src)
			if(T != loc)
				forceMove(T)
			var/dist = rand(3, 5)
			var/turf/FT
			for(var/i in 1 to dist)
				T = get_turf(src)
				FT = get_turf(feeder)
				if(FT.z != z)
					break
				if(get_dist(T, FT) < 2)
					devour(feeder, 5, FALSE)
					feeder = null
					sleep(10)
					break
				else
					var/turf/step = get_step_towards(T, FT)
					Move(step, get_dir(T, step))
					var/static/list/messagepool = list("HELLO", "HI!!", "HENLO!", "PERSON", "YAY", "HUNGRY", "FOOD", "MMMMM", "YES", "PLAY") // (HE IS A VERY GOOD BOY)
					say(pick(messagepool))
					sleep(1)
			if(feeder) // How could be so naive? There is no escape
				say("SAD")
				playsound(feeder, 'sound/effects/tendril_destroyed.ogg', 100, 0)
				feeder = null
	// update our component
	var/datum/component/volatile/VC = GetComponent(/datum/component/volatile)
	VC.volatility = volatility

	visible_message("<span class='warning'>\The [src] gurgles happily.</span>")
	new /obj/effect/temp_visual/heart(loc) // :)
	is_evolving = FALSE

/**
 * Attempts to devour a living target.
 * * target = The target.
 * * consumeTime = The time for the bag to finish consumption.
 * * checkEvolve = Whether `evolve()` should be called on completion.
 * * growSize = Whether the bag should grow in size on completion.
 *
 * Keep in mind that this is a blocking call by default
 */
/obj/item/powder_bag/hungry/proc/devour(mob/living/target, consumeTime = 26, checkEvolve = TRUE, growSize = TRUE)
	devouring = TRUE
	forceMove(get_turf(target))
	visible_message("<span class='danger'>\The [src] wraps around and begins to devour [target]. Cute!</span>")
	target.Stun(100 + consumeTime, TRUE, TRUE)
	target.notransform = TRUE
	target.anchored = TRUE
	if(target.stat != DEAD)
		INVOKE_ASYNC(target, TYPE_PROC_REF(/mob, emote), "scream")
	SpinAnimation(20, 1, pick(0, 1), parallel = FALSE) // he does tricks!
	var/segsleep = consumeTime * 0.5
	sleep(segsleep)
	say("NOM")
	sleep(segsleep)
	energy = max((next_evolve - energy) * 2, energy)
	if(isplasmaman(target))
		visible_message("<span class='danger'>\The [src] doesn't look very well..</span>")
		var/datum/component/volatile/VC = GetComponent(/datum/component/volatile)
		addtimer(CALLBACK(VC, TYPE_PROC_REF(/datum/component/volatile/, explode)), 20)
		Shake(10, 10, 20)
	var/list/inventoryItems = target.get_equipped_items(TRUE)
	target.unequip_everything()
	target.gib(TRUE, TRUE, TRUE)
	for(var/atom/movable/AM as() in inventoryItems)
		var/throwdir = pick(GLOB.alldirs)
		AM.throw_at(get_step(src, throwdir), rand(1, 3), 2)
	if(growSize)
		transform.Scale(1.1)
	devouring = FALSE
	if(checkEvolve)
		evolve()

/obj/item/powder_bag/hungry/process(delta_time)
	if(!enraged)
		return PROCESS_KILL
	if(satisfied_until > world.time || devouring)
		return
	if(target)
		if(target.z != z || get_dist(src, target) > 8)
			target = null
	else
		var/closest_dist = 100
		for(var/mob/living/L in orange(8, src))
			var/dist = get_dist(src, L)
			if(dist < closest_dist || (target.stat == DEAD && L.stat != DEAD)) // Pick the closest ALIVE mob to us, otherwise pick the closest dead one
				target = L
				closest_dist = dist
		if(!target)
			return
	if(get_dist(src, target) <= 1)
		INVOKE_ASYNC(src, PROC_REF(devour), target)
		satisfied_until = world.time + satisfaction_duration
	else if(!throwing)
		throw_at(target, 10, 2)

/obj/item/powder_bag/hungry/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!enraged)
		return ..()
	if(target && hit_atom == target && !devouring)
		INVOKE_ASYNC(src, PROC_REF(devour), target)
		satisfied_until = world.time + satisfaction_duration
		return
	return ..()

/obj/item/powder_bag/hungry/examine(mob/user)
	. = ..()
	if(enraged)
		. += "<span class='notice'>It appears to be <font color=red><i><b>very</b></i></font> agitated.</span>"
