/**
	Late game science researchable machine that allows you to project shields around the ship in exchange for a crapload of power.
	@author Kmc2000
*/

/obj/structure/overmap
{
	var/obj/machinery/shield_generator/shields
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

//Constructor of objects of class shield_generator. No params
/obj/machinery/shield_generator/Initialize()
{
	. = ..();
	var/obj/structure/overmap/ours = get_overmap();
	ours?.shields = src;
}

/obj/machinery/shield_generator/proc/depower_shield(){
	shield["integrity"] = 0;
	shield["max_integrity"] = 0;
}

//Every tick, the shield generator updates its stats based on the amount of power it's being allowed to chug.
/obj/machinery/shield_generator/process()
{
	idle_power_usage = power_input;
	cut_overlays();
	if(!powered() || idle_power_usage <= 0){
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
	return data;
}

/obj/effect/temp_visual/overmap_shield_hit
{
	name = "Shield hit";
	icon = 'nsv13/icons/overmap/shieldhit.dmi';
	icon_state = "shieldhit";
	duration = 0.75 SECONDS;
}
/obj/effect/temp_visual/overmap_shield_hit/Initialize(mapload, obj/structure/overmap/OM){
	. = ..()
	alpha = 0;
	//Scale up the shield hit icon to roughly fit the overmap ship that owns us.
	var/matrix/desired = new();
	desired.Turn(OM.angle);
	var/icon/I = icon(OM.icon);
	var/resize_x = I.Width()/96;
	var/resize_y = I.Height()/96;
	desired.Scale(resize_x,resize_y);
	transform = desired;
	alpha = 255;
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
