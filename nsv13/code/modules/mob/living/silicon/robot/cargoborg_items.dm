/// CARGO BORGS ///
#define CYBORG_FONT "Consolas"
#define MAX_PAPER_INTEGRATED_CLIPBOARD 10

/obj/item/pen/cyborg
	name = "integrated pen"
	font = CYBORG_FONT
	desc = "You can almost hear the sound of gears grinding against one another as you write with this pen. Almost."

/obj/item/clipboard/cyborg
	name = "\improper integrated clipboard"
	desc = "A clipboard which seems to come adapted with a paper synthetizer, carefully hidden in its paper clip."
	integrated_pen = TRUE
	/// When was the last time the printer was used?
	COOLDOWN_DECLARE(printer_cooldown)
	/// How long is the integrated printer's cooldown?
	var/printer_cooldown_time = 10 SECONDS
	/// How much charge is required to print a piece of paper?
	var/paper_charge_cost = 50

/obj/item/clipboard/cyborg/Initialize(mapload)
	. = ..()
	pen = new /obj/item/pen/cyborg

/obj/item/clipboard/cyborg/examine()
	. = ..()
	. += "Alt-click to synthetize a piece of paper."
	if(!COOLDOWN_FINISHED(src, printer_cooldown))
		. += "Its integrated paper synthetizer seems to still be on cooldown."

/obj/item/clipboard/cyborg/AltClick(mob/user)
	if(!iscyborg(user))
		to_chat(user, "<span class='warning'>You do not seem to understand how to use [src].</span>")
		return
	var/mob/living/silicon/robot/cyborg_user = user
	// Not enough charge? Tough luck.
	if(cyborg_user?.cell.charge < paper_charge_cost)
		to_chat(user, "<span class='warning'>Your internal cell doesn't have enough charge left to use [src]'s integrated printer.</span>")
		return
	// Check for cooldown to avoid paper spamming
	if(COOLDOWN_FINISHED(src, printer_cooldown))
		// If there's not too much paper already, let's go
		if(!toppaper_ref || length(contents) < MAX_PAPER_INTEGRATED_CLIPBOARD)
			cyborg_user.cell.use(paper_charge_cost)
			COOLDOWN_START(src, printer_cooldown, printer_cooldown_time)
			var/obj/item/paper/new_paper = new /obj/item/paper
			new_paper.forceMove(src)
			if(toppaper_ref)
				var/obj/item/paper/toppaper = toppaper_ref?.resolve()
				UnregisterSignal(toppaper, COMSIG_ATOM_UPDATED_ICON)
			RegisterSignal(new_paper, COMSIG_ATOM_UPDATED_ICON, PROC_REF(on_top_paper_change))
			toppaper_ref = WEAKREF(new_paper)
			update_appearance()
			to_chat(user, "<span class='notice'>[src]'s integrated printer whirs to life, spitting out a fresh piece of paper and clipping it into place.</span>")
		else
			to_chat(user, "<span class='warning'>[src]'s integrated printer refuses to print more paper, as [src] already contains enough paper.</span>")
	else
		to_chat(user, "<span class='warning'>[src]'s integrated printer refuses to print more paper, its bluespace paper synthetizer not having finished recovering from its last synthesis.</span>")

/obj/item/hand_labeler/cyborg
	name = "integrated hand labeler"
	labels_left = 9000 // I don't want to bother forcing them to recharge, honestly, that's a lot of code for a very niche functionality

// The clamps
/obj/item/borg/hydraulic_clamp
	name = "integrated hydraulic clamp"
	desc = "A neat way to lift and move around few small packages for quick and painless deliveries!"
	icon = 'icons/mecha/mecha_equipment.dmi' // Just some temporary sprites because I don't have any unique one yet
	icon_state = "mecha_clamp"
	/// How much power does it draw per operation?
	var/charge_cost = 20
	/// How many items can it hold at once in its internal storage?
	var/storage_capacity = 5
	/// Does it require the items it takes in to be wrapped in paper wrap? Can have unforeseen consequences, change to FALSE at your own risks.
	var/whitelisted_contents = TRUE
	/// What kind of wrapped item can it hold, if `whitelisted_contents` is set to true?
	var/list/whitelisted_item_types = list(/obj/item/small_delivery)
	/// A short description used when the check to pick up something has failed.
	var/whitelisted_item_description = "small wrapped packages"
	/// Weight limit on the items it can hold. Leave as NONE if there isn't.
	var/item_weight_limit = WEIGHT_CLASS_NORMAL
	/// Can it hold mobs? (Dangerous, it is recommended to leave this to FALSE)
	var/can_hold_mobs = FALSE
	/// Audio for using the hydraulic clamp.
	var/clamp_sound = 'sound/mecha/hydraulic.ogg'
	/// Volume of the clamp's loading and unloading noise.
	var/clamp_sound_volume = 25
	/// Cooldown for the clamp.
	COOLDOWN_DECLARE(clamp_cooldown)
	/// How long is the clamp on cooldown for after every usage?
	var/cooldown_duration = 0.5 SECONDS
	/// How long does it take to load in an item?
	var/loading_time = 2 SECONDS
	/// How long does it take to unload an item?
	var/unloading_time = 1 SECONDS
	/// Is it currently in use?
	var/in_use = FALSE
	/// Index of the item we want to take out of the clamp, 0 if nothing selected.
	var/selected_item_index = 0
	/// Weakref to the cyborg we're currently connected to.
	var/datum/weakref/cyborg_holding_me

/obj/item/borg/hydraulic_clamp/Initialize(mapload)
	. = ..()
	if(!istype(loc, /obj/item/robot_module))
		return

	var/obj/item/robot_module/holder_module = loc
	cyborg_holding_me = WEAKREF(holder_module.robot)

	RegisterSignal(holder_module.robot, COMSIG_MOB_DEATH, PROC_REF(empty_contents))

/obj/item/borg/hydraulic_clamp/Destroy()
	var/mob/living/silicon/robot/robot_holder = cyborg_holding_me?.resolve()
	if(robot_holder)
		UnregisterSignal(robot_holder, COMSIG_MOB_DEATH)
	return ..()

/obj/item/borg/hydraulic_clamp/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It's cargo hold has a capacity of [storage_capacity] and is currently holding <b>[contents.len ? contents.len : 0]</b> items in it!</span>"
	if(storage_capacity > 1)
		. += "<span class='notice'>Use in hand to select an item you want to prioritize taking out of the storage.</span>"

/// A simple proc to empty the contents of the hydraulic clamp, forcing them on the turf it's on. Also forces `selected_item_index` to 0, to avoid any possible issues resulting from it.
/obj/item/borg/hydraulic_clamp/proc/empty_contents()
	SIGNAL_HANDLER

	selected_item_index = 0
	var/spilled_amount = 0
	var/turf/turf_of_clamp = get_turf(src)
	for(var/atom/movable/item in contents)
		item.forceMove(turf_of_clamp)
		spilled_amount++

	if(spilled_amount)
		var/holder = cyborg_holding_me?.resolve()
		if(holder)
			visible_message("<span class='warning'>[cyborg_holding_me?.resolve()] spills the content of [src]'s cargo hold all over the floor!</span>")

/obj/item/borg/hydraulic_clamp/attack_self(mob/user)
	if(storage_capacity <= 1) // No need for selection if there's one or less item at maximum in the clamp.
		return

	selected_item_index = 0

	if(contents.len <= 1)
		to_chat(user, "<span class='warning'>There's currently [contents.len ? "only one item" : "nothing"] to take out of [src]'s cargo hold, no need to pick!</span>")
		return

	. = ..()

	var/list/choices = list()
	var/index = 1
	for(var/item in contents)
		choices[item] = index
		index++

	var/selection = tgui_input_list(user, "Which item would you like to prioritize?", "Choose an item to prioritize", choices)
	if(!selection)
		return

	var/new_index = choices[selection]
	if(!new_index)
		return

	selected_item_index = new_index
	to_chat(user, "<span class='notice'>[src] will now prioritize unloading [selection].</span>")

/obj/item/borg/hydraulic_clamp/emp_act(severity)
	. = ..()
	empty_contents()

/obj/item/borg/hydraulic_clamp/pre_attack(atom/attacked_atom, mob/living/user, params)
	if(!user.Adjacent(attacked_atom) || !COOLDOWN_FINISHED(src, clamp_cooldown) || in_use)
		return

	in_use = TRUE
	COOLDOWN_START(src, clamp_cooldown, cooldown_duration)

	// We're trying to unload something from the clamp, only possible on the floor, tables and conveyors.
	if(isturf(attacked_atom) || istype(attacked_atom, /obj/structure/table) || istype(attacked_atom, /obj/machinery/conveyor))
		if(!contents.len)
			in_use = FALSE
			return

		var/extraction_index = selected_item_index ? selected_item_index : contents.len
		var/atom/movable/extracted_item = contents[extraction_index]
		selected_item_index = 0

		if(unloading_time > 0.5 SECONDS) // We don't want too much chat spam if the clamp works fast.
			to_chat(user, "<span class='notice'>You start unloading something from [src]...</span>")
		playsound(src, clamp_sound, clamp_sound_volume, FALSE, -5)
		COOLDOWN_START(src, clamp_cooldown, cooldown_duration)

		if(!do_after(user, unloading_time, target = attacked_atom))
			in_use = FALSE
			return

		var/turf/extraction_turf = get_turf(attacked_atom)
		extracted_item.forceMove(extraction_turf)
		visible_message("<span class='notice'>[src.loc] unloads [extracted_item] from [src].</span>")
		in_use = FALSE
		return

	// We're trying to load something in the clamp
	else
		if(whitelisted_contents && !is_type_in_list(attacked_atom, whitelisted_item_types))
			to_chat(user, "<span class='warning'>[src] can only pick up [whitelisted_item_description]!</span>")
			in_use = FALSE
			return

		if(contents.len >= storage_capacity)
			to_chat(user, "<span class='warning'>[src] is already at full capacity!</span>")
			in_use = FALSE
			return

		if(item_weight_limit)
			var/obj/item/to_lift = attacked_atom
			if(!to_lift || to_lift.w_class > item_weight_limit)
				to_chat(user, "<span class='warning'>[to_lift] is too big for [src]!</span>")
				in_use = FALSE
				return

		var/atom/movable/lifting_up = attacked_atom

		if(lifting_up.anchored)
			to_chat(user, "<span class='warning'>[lifting_up] is firmly secured, it's not currently possible to move it into [src]!</span>")
			in_use = FALSE
			return

		if(istype(lifting_up, /obj/structure/big_delivery))
			var/obj/structure/big_delivery/parcel = lifting_up
			parcel.setAnchored(TRUE)

		lifting_up.add_fingerprint(user)

		if(loading_time > 0.5 SECONDS) // We don't want too much chat spam if the clamp works fast.
			to_chat(user, "<span class='notice'>You start loading [lifting_up] into [src]'s cargo hold...</span>")
		playsound(src, clamp_sound, clamp_sound_volume, FALSE, -5)

		if(!do_after(user, loading_time, target = lifting_up)) // It takes two seconds to put stuff into the clamp's cargo hold
			lifting_up.anchored = FALSE
			in_use = FALSE
			return

		lifting_up.anchored = FALSE
		lifting_up.forceMove(src)
		visible_message("<span class='notice'>[src.loc] loads [lifting_up] into [src]'s cargo hold.</span>")
		in_use = FALSE

/obj/item/borg/hydraulic_clamp/better
	name = "improved integrated hydraulic clamp"
	desc = "A neat way to lift and move around wrapped crates for quick and painless deliveries!"
	storage_capacity = 2
	whitelisted_item_types = list(/obj/item/small_delivery, /obj/structure/big_delivery) // If they want to carry a small package instead, so be it, honestly.
	whitelisted_item_description = "wrapped packages"
	item_weight_limit = NONE
	clamp_sound_volume = 50

/obj/item/borg/hydraulic_clamp/better/examine(mob/user)
	. = ..()
	var/crate_count = contents.len
	. += "There is currently <b>[crate_count > 0 ? crate_count : "no"]</b> crate[crate_count > 1 ? "s" : ""] stored in the clamp's internal storage."

/obj/item/borg/hydraulic_clamp/mail
	name = "integrated rapid mail delivery device"
	desc = "Allows you to carry around a lot of mail, to distribute it around the ship like the good little mailbot you are!"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "mailbag"
	storage_capacity = 100
	loading_time = 0.25 SECONDS
	unloading_time = 0.25 SECONDS
	cooldown_duration = 0.25 SECONDS
	whitelisted_item_types = list(/obj/item/mail)
	whitelisted_item_description = "enveloppes"
	item_weight_limit = WEIGHT_CLASS_NORMAL
	clamp_sound_volume = 25
	clamp_sound = 'sound/items/pshoom.ogg'

/datum/design/borg_upgrade_clamp
	name = "Cyborg Upgrade (Improved Integrated Hydraulic Clamp)"
	id = "borg_upgrade_clamp"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/better_clamp
	materials = list(/datum/material/titanium = 4000, /datum/material/gold = 500, /datum/material/bluespace = 50)
	construction_time = 12 SECONDS
	category = list("Cyborg Upgrade Modules")

/obj/item/borg/upgrade/better_clamp
	name = "improved integrated hydraulic clamp"
	desc = "An improved hydraulic clamp that trades its storage quantity to allow for bigger packages to be picked up instead!"
	icon_state = "cyborg_upgrade3"
	require_module = TRUE
	module_type = list(/obj/item/robot_module/cargo)
	module_flags = BORG_MODULE_CARGO

/obj/item/borg/upgrade/better_clamp/action(mob/living/silicon/robot/cyborg, user = usr)
	. = ..()
	if(!.)
		return
	var/obj/item/borg/hydraulic_clamp/better/big_clamp = locate() in cyborg.module.modules
	if(big_clamp)
		to_chat(user, "<span class='warning'>This cyborg is already equipped with an improved integrated hydraulic clamp!</span>")
		return FALSE

	big_clamp = new(cyborg.module)
	cyborg.module.basic_modules += big_clamp
	cyborg.module.add_module(big_clamp, FALSE, TRUE)

/obj/item/borg/upgrade/better_clamp/deactivate(mob/living/silicon/robot/cyborg, user = usr)
	. = ..()
	if(!.)
		return
	var/obj/item/borg/hydraulic_clamp/better/big_clamp = locate() in cyborg.module.modules
	if(big_clamp)
		cyborg.module.remove_module(big_clamp, TRUE)

/// Holders for the package wrap and the wrapping paper synthesizers.

/datum/robot_energy_storage/package_wrap
	name ="Package wrapper synthetizer"
	max_energy = 25
	recharge_rate = 2


/datum/robot_energy_storage/wrapping_paper
	name ="Wrapping paper synthetizer"
	max_energy = 25
	recharge_rate = 2

/obj/item/stack/package_wrap/cyborg
	name = "integrated package wrapper"
	is_cyborg = TRUE

/obj/item/stack/wrapping_paper/cyborg
	name = "integrated wrapping paper"
	is_cyborg = TRUE

/obj/item/stack/wrapping_paper/cyborg/use(used, transfer, check = FALSE) // Check is set to FALSE here, so the stack istn't deleted.
	. = ..()
