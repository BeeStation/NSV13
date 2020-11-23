/**
	Late game science researchable machine that allows you to project shields around the ship in exchange for a crapload of power.
	@author Kmc2000
*/

/obj/structure/overmap
{
	var/obj/machinery/shield_generator/shields
}

/obj/structure/shieldgen_frame
{
	name = "Shield Generator Frame";
	desc = "The beginnings of a shield generator. It requires 2 cooling fans, 4 flux, 1 crystal interface, and 4 modulators."
	icon = 'nsv13/icons/obj/machinery/shieldgen.dmi';
	icon_state = "shieldgen_build1";
	pixel_x = -32;
	density = TRUE;
	layer = HIGH_OBJ_LAYER;
	var/state = 1;
	var/fanCount = 0;
	var/capacitorCount = 0;
	var/modulatorCount = 0;
	var/hasInterface = FALSE;
	var/componentsDone = FALSE;
}

/datum/techweb_node/ship_shield_tech
{
	id = "ship_shield_tech";
	display_name = "Experimental Shield Technology";
	description = "Highly experimental shield technology to vastly increase survivability in ships. Although Nanotrasen researchers have had access to this technology for quite some time, the incredible amount of power required to maintain shields has proven to be the greatest challenge in implementing them.";
	prereq_ids = list("");
	design_ids = list("shield_fan", "shield_capacitor", "shield_modulator", "shield_interface", "shield_frame");
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000);
	export_price = 5000;
	hidden = TRUE
}

/datum/design/shield_fan
{
	name = "Shield cooling fan";
	desc = "A component required for producing a shield generator.";
	id = "shield_fan";
	build_type = PROTOLATHE;
	materials = list(/datum/material/iron = 4000, /datum/material/titanium = 4000, /datum/material/glass = 1000);
	build_path = /obj/item/shield_component/fan;
	category = list("Experimental Technology");
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE;
}

/datum/design/shield_capacitor
{
	name = "Flux Capacitor";
	desc = "A component required for producing a shield generator.";
	id = "shield_capacitor";
	build_type = PROTOLATHE;
	materials = list(/datum/material/iron = 10000, /datum/material/uranium = 5000, /datum/material/diamond = 5000);
	build_path = /obj/item/shield_component/capacitor;
	category = list("Experimental Technology");
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE;
}


/datum/design/shield_modulator
{
	name = "Shield Modulator";
	desc = "A component required for producing a shield generator.";
	id = "shield_modulator";
	build_type = PROTOLATHE;
	materials = list(/datum/material/iron = 10000, /datum/material/uranium = 10000, /datum/material/diamond = 10000);
	build_path = /obj/item/shield_component/modulator;
	category = list("Experimental Technology");
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE;
}

/datum/design/shield_interface
{
	name = "Bluespace Crystal Interface";
	desc = "A component required for producing a shield generator.";
	id = "shield_interface";
	build_type = PROTOLATHE;
	materials = list(/datum/material/titanium = 10000, /datum/material/bluespace = MINERAL_MATERIAL_AMOUNT, /datum/material/diamond = 10000);
	build_path = /obj/item/shield_component/interface;
	category = list("Experimental Technology");
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE;
}

/datum/design/shield_frame
{
	name = "Shield Generator Frame";
	desc = "The basic frame of a shield generator. Assembly required, parts sold separately.";
	id = "shield_frame";
	build_type = PROTOLATHE;
	materials = list(/datum/material/titanium = 20000, /datum/material/iron = 20000);
	build_path = /obj/structure/shieldgen_frame;
	category = list("Experimental Technology");
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE;
}

/obj/item/disk/design_disk/overmap_shields
	name = "SolGov Experimental Shielding Technology Disk"
	desc = "This disk is the property of SolGov, unlawful use of the data contained on this disk is prohibited."
	icon_state = "datadisk2"
	max_blueprints = 5

/obj/item/disk/design_disk/overmap_shields/Initialize()
	. = ..()
	var/datum/design/shield_fan/A = new
	var/datum/design/shield_capacitor/B = new
	var/datum/design/shield_modulator/C = new
	var/datum/design/shield_interface/D = new
	var/datum/design/shield_frame/E = new
	blueprints[1] = A
	blueprints[2] = B
	blueprints[3] = C
	blueprints[4] = D
	blueprints[5] = E

/obj/structure/shieldgen_frame/attackby(obj/item/I, mob/living/user, params)
	if(state != 11){
		return FALSE;
	}
	switch(I.type)
		if(/obj/item/shield_component/fan)
			if(fanCount >= 2){
				return FALSE;
			}
			to_chat(user, "<span class='notice'>You add [I] to [src].</span>");
			I.forceMove(src);
			fanCount ++;
		if(/obj/item/shield_component/capacitor)
			if(capacitorCount >= 4){
				return FALSE;
			}
			to_chat(user, "<span class='notice'>You add [I] to [src].</span>");
			I.forceMove(src);
			capacitorCount ++;
		if(/obj/item/shield_component/modulator)
			if(modulatorCount >= 4){
				return FALSE;
			}
			to_chat(user, "<span class='notice'>You add [I] to [src].</span>");
			I.forceMove(src);
			modulatorCount ++;
		if(/obj/item/shield_component/interface)
			if(hasInterface){
				return FALSE;
			}
			to_chat(user, "<span class='notice'>You add [I] to [src].</span>");
			I.forceMove(src);
			hasInterface = TRUE;
	componentsDone = check_finished();
	if(componentsDone){
		state = 12;
	}
	return FALSE;

/obj/structure/shieldgen_frame/proc/check_finished(){
	return (fanCount >= 2 && capacitorCount >= 4 && modulatorCount >= 4 && hasInterface);
}

/obj/structure/shieldgen_frame/proc/finish(){
	for(var/atom/movable/AM in contents){
		qdel(AM);
	}
	new /obj/machinery/shield_generator(get_turf(src));
	qdel(src);
}

/obj/structure/shieldgen_frame/wrench_act(mob/living/user, obj/item/I)
	switch(state)
		if(2)
			to_chat(user, "<span class='notice'>You start to bolt together [src].</span>");
			if(do_after(user, 5 SECONDS, target=src))
				state = 3
				update_icon()
				return FALSE
		if(4)
			to_chat(user, "<span class='notice'>You start to bolt [src]'s housings together...</span>")
			if(do_after(user, 5 SECONDS, target=src))
				state = 5
				update_icon()
				return FALSE
		if(6)
			to_chat(user, "<span class='notice'>You start to bolt [src]'s connecting struts into its frame.</span>")
			if(do_after(user, 5 SECONDS, target=src))
				state = 7
				update_icon()
				return FALSE
		if(8)
			to_chat(user, "<span class='notice'>You start to bolt [src]'s primary generator coverings...</span>")
			if(do_after(user, 5 SECONDS, target=src))
				state = 9
				update_icon()
				return FALSE
		if(10)
			to_chat(user, "<span class='notice'>You start to secure [src]'s flux generator housing...</span>")
			if(do_after(user, 5 SECONDS, target=src))
				state = 11
				update_icon()
				return FALSE
	anchored = !anchored
	I.play_tool_sound(src)
	to_chat(user, "<span class='notice'>You [anchored?"secure":"unsecure"] [src].</span>")
	return FALSE

/obj/structure/shieldgen_frame/screwdriver_act(mob/living/user, obj/item/I)
{
	. = FALSE
	switch(state)
		if(7)
			to_chat(user, "<span class='notice'>You start to screw in [src]'s primary generator coverings...</span>");
			if(do_after(user, 5 SECONDS, target=src)){
				state = 8;
				update_icon();
			}
			return FALSE;
		if(12)
			if(!anchored){
				to_chat(user, "<span class='notice'>[src] must be anchored with a wrench before you can complete it!</span>");
				return FALSE;
			}
			to_chat(user, "<span class='notice'>You start to screw in [src]'s components...</span>");
			if(do_after(user, 5 SECONDS, target=src)){
				finish();
			}
			return FALSE;
}

/obj/structure/shieldgen_frame/welder_act(mob/living/user, obj/item/I)
{
	. = FALSE
	switch(state)
		if(1)
			to_chat(user, "<span class='notice'>You start to weld the chassis together...</span>");
			if(do_after(user, 5 SECONDS, target=src)){
				state = 2;
				update_icon();
			}
		if(3)
			to_chat(user, "<span class='notice'>You start to weld [src]'s connecting struts into its frame.</span>");
			if(do_after(user, 5 SECONDS, target=src)){
				state = 4;
				update_icon();
			}
		if(5)
			to_chat(user, "<span class='notice'>You start to weld [src]'s housings to the frame.</span>");
			if(do_after(user, 5 SECONDS, target=src)){
				state = 6;
				update_icon();
			}
		if(9)
			to_chat(user, "<span class='notice'>You start to weld [src]'s primary generator coverings...</span>");
			if(do_after(user, 5 SECONDS, target=src)){
				state = 10;
				update_icon();
				return FALSE;
			}
}

/obj/structure/shieldgen_frame/update_icon(){
	icon_state = "shieldgen_build[state]"
}

/obj/machinery/shield_generator
{
	name = "Shield Generator";
	desc = "A massively powerful device which is able to project energy shields around ships. This technology is highly experimental and requires a huge amount of power.";
	icon = 'nsv13/icons/obj/machinery/shieldgen.dmi';
	icon_state = "shieldgen";
	idle_power_usage = IDLE_POWER_USE; //This will change to match the requirements for projecting a shield.
	pixel_x = -32;
	bound_height = 128;
	bound_width = 96;
	density = TRUE;
	layer = HIGH_OBJ_LAYER;
	var/flux_rate = 0; //Flux that this shield generator is producing based on power usage.
	var/power_input = 0; //Inputted power setting. Allows you to throttle the shieldgen to not eat all of your power at once.
	var/list/shield = list("integrity"=0, "max_integrity"=0);
	var/regenPriority = 50;
	var/maxHealthPriority = 50; //50/50 split
	var/max_power_input = 1.5e+7; //15 MW theoretical maximum. This much power means your shield is going to be insanely good.
	var/active = FALSE; //Are we projecting out our shields? This lets you offline the shields for a recharge period so that they become useful again.
}

/obj/machinery/shield_generator/proc/absorb_hit(damage){
	if(!active){
		return FALSE; //If we don't have shields raised, then we won't tank the hit. This allows you to micro the shields back to health.
	}
	if(shield["integrity"] >= damage){
		shield["integrity"] -= damage;
		return TRUE;
	}
	return FALSE;
}

/obj/item/shield_component
{
	name = "Shield component";
	icon = 'nsv13/icons/obj/shield_components.dmi';
}

/obj/item/shield_component/fan
{
	name = "Shield Generator Cooling Fan";
	desc = "A small fan which aids in cooling down a shield generator.";
	icon_state = "cooling_fan";
}

/obj/item/shield_component/capacitor
{
	name = "Flux Capacitor";
	desc = "A small capacitor which can generate shield flux.";
	icon_state = "capacitor";
}

/obj/item/shield_component/modulator
{
	name = "Shield Modulator";
	desc = "A control circuit for shield systems to allow them to project energy screens around the ship.";
	icon_state = "modulator";
}

/obj/item/shield_component/interface
{
	name = "Bluespace Crystal Interface";
	desc = "A housing to hold a bluespace crystal which extends the generated shield around an entire ship via subspace.";
	icon_state = "crystal_interface";
}

//Constructor of objects of class shield_generator. No params
/obj/machinery/shield_generator/Initialize()
{
	. = ..();
	var/obj/structure/overmap/ours = get_overmap();
	ours?.shields = src;
	if(!ours){
		addtimer(CALLBACK(src, .proc/try_find_overmap), 20 SECONDS);
	}
}

/obj/machinery/shield_generator/proc/try_find_overmap(){
	var/obj/structure/overmap/ours = get_overmap();
	ours?.shields = src;
	if(!ours){
		message_admins("WARNING: Shield generator in [get_area(src)] does not have a linked overmap!");
		log_game("WARNING: Shield generator in [get_area(src)] does not have a linked overmap!");
	}
}

/obj/machinery/shield_generator/proc/depower_shield(){
	shield["integrity"] = 0;
	shield["max_integrity"] = 0;
}

/obj/machinery/shield_generator/proc/try_use_power(amount) // Although the machine may physically be powered, it may not have enough power to sustain a shield.
	var/turf/T = get_turf(src)
	var/obj/structure/cable/C = T.get_cable_node()
	if(C)
		if(!C.powernet)
			return FALSE
		var/power_in_net = C.powernet.avail-C.powernet.load

		if(power_in_net && power_in_net > amount)
			C.powernet.load += amount
			return TRUE
		return FALSE
	return FALSE

//Every tick, the shield generator updates its stats based on the amount of power it's being allowed to chug.
/obj/machinery/shield_generator/process()
{
	cut_overlays();
	if(!powered() || power_input <= 0 || !try_use_power(power_input)){
		depower_shield();
		return FALSE;
	}
	var/megawatts = power_input / 1e+6; //I'm lazy.
	flux_rate = round(megawatts*2.5); //Round down them megawatts. Multiplier'd this to make shields actually useful
	add_overlay("screen_on");

	//Firstly, set the max health of the shield based off of the available input power, and the priority that the user set for generating a shield.
	var/projectRate = max(((maxHealthPriority / 100) * flux_rate), 0);
	flux_rate -= projectRate;
	shield["max_integrity"] = projectRate * 100; //1 flux/s => 100max HP for this tick.

	//Now we handle whatever's left of the power allocation for regenerating the shield

	var/regenRate = max(((regenPriority / 100) * flux_rate),0) //Times also works as of. Soo we're going, for example, 50% of flux_rate
	flux_rate -= regenRate;
	shield["integrity"] += regenRate;
	if(shield["integrity"] > shield["max_integrity"]){
		shield["integrity"] = shield["max_integrity"];
	}
}

/obj/machinery/shield_generator/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
										datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
{
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open);
	if(!ui){
		ui = new(user, src, ui_key, "ShieldGenerator", name, 600, 660, master_ui, state);
		ui.open();
	}
}

/obj/machinery/shield_generator/attack_hand(mob/user)
{
	ui_interact(user);
}

/obj/machinery/shield_generator/ui_data(mob/user)
{
	. = ..();
	var/list/data = list();
	data["maxHealthPriority"] = maxHealthPriority;
	data["regenPriority"] = regenPriority;
	data["progress"] = shield["integrity"];
	data["goal"] = shield["max_integrity"];
	data["powerAlloc"] = power_input/1e+6;
	data["maxPower"] = max_power_input/1e+6;
	data["active"] = active;
	data["available_power"] = 0;
	var/turf/T = get_turf(src)
	var/obj/structure/cable/C = T.get_cable_node()
	if(C)
		if(C.powernet)
			data["available_power"] = C.powernet.avail-C.powernet.load
	return data;
}

/obj/effect/temp_visual/overmap_shield_hit
{
	name = "Shield hit";
	icon = 'nsv13/icons/overmap/shieldhit.dmi';
	icon_state = "shieldhit";
	duration = 0.75 SECONDS;
	layer = ABOVE_MOB_LAYER+0.1;
	animate_movement = NO_STEPS; // Override the inbuilt movement engine to avoid bouncing
	appearance_flags = TILE_BOUND | PIXEL_SCALE;
}
/obj/effect/temp_visual/overmap_shield_hit/Initialize(mapload, obj/structure/overmap/OM){
	. = ..()
	alpha = 0;
	//Scale up the shield hit icon to roughly fit the overmap ship that owns us.
	var/matrix/desired = new();
	var/icon/I = icon(OM.icon);
	var/resize_x = I.Width()/96;
	var/resize_y = I.Height()/96;
	desired.Scale(resize_x,resize_y);
	desired.Turn(OM.angle);
	transform = desired;
	track(OM);
}
/obj/effect/temp_visual/overmap_shield_hit/proc/track(obj/structure/overmap/OM){
	set waitfor = FALSE;
	while(!QDELETED(src)){
		stoplag();
		forceMove(get_turf(OM));
		alpha = 255;
	}
}

/obj/machinery/shield_generator/ui_act(action, params)
{
	if(..()){
		return;
	}
	var/value = text2num(params["input"]);
	switch(action)
		if("maxHealth")
			maxHealthPriority = value;
			regenPriority = 100-maxHealthPriority;

		if("regen")
			regenPriority = value;
			maxHealthPriority = 100-regenPriority;

		if("power")
			power_input = value*1e+6;
		if("activeToggle")
			active = !active;
	return;
}
