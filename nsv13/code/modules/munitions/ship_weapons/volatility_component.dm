/**Volatile substances.

Add this component to an atom to mark it as volatile, if it takes fire damage, is struck by something that's ignited, or optionally, when it's destroyed, it'll explode violently.

*/

/datum/component/volatile
	var/desc = "<span class='warning'>It's highly volatile and liable to explode if subjected to heat!</span>"
	var/volatility = 1
	var/volatile_when_hit = FALSE //Does this volatile thing blow up when it's destroyed?
	var/explosion_scale = 1

/datum/component/volatile/proc/set_volatile_when_hit(flag)
	volatile_when_hit = flag

/datum/component/volatile/proc/explode()
	if(!parent)
		message_admins("Volatility component tried to explode with no attached parent. Contact a coder")
		return FALSE
	//Explosion! This can lead to a chain reaction if you're not careful... WATCH THOSE SHELLS MAA!
	log_game("Volatile substance caused an explosion at [get_area(parent)].")
	var/ExPower = volatility * explosion_scale
	explosion(parent, 0, round(ExPower * 0.75), round(ExPower * 1.5), round(ExPower * 2), TRUE, FALSE, round(ExPower * 1.5), FALSE, FALSE)
	if(!QDELETED(parent))
		qdel(parent)

/datum/component/volatile/proc/burn_act()
	SIGNAL_HANDLER

	if(prob(CLAMP(volatility * 10, 0, 100))) //How likely we are to blow up
		explode()

/datum/component/volatile/proc/damage_react(datum/source, amount)
	SIGNAL_HANDLER
	//Is this thing volatile when smacked? Harder hits mean more likely to go up in flames...
	if(volatile_when_hit && prob(CLAMP(amount/5 * volatility, 0, 100)))
		explode()

/datum/component/volatile/proc/examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(desc)
		examine_list += desc
		if(volatile_when_hit) //Don't play with the torpedo warheads
			examine_list += "<span class='warning'>It may explode if hit with enough force!</span>"

/datum/component/volatile/Initialize(volatility = 1, volatile_when_hit = FALSE, explosion_scale = 1)
	if(volatility <= 0)
		message_admins("Volatility component with volatility \"[volatility]\" added to [parent], deleting the volatility component...")
		RemoveComponent()
		return
	src.volatility = volatility
	src.volatile_when_hit = volatile_when_hit
	src.explosion_scale = explosion_scale
	RegisterSignal(parent, COMSIG_ATOM_DAMAGE_ACT, .proc/damage_react, override = TRUE)
	RegisterSignal(parent, COMSIG_ATOM_FIRE_ACT, .proc/burn_act)
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/examine)

/datum/component/volatile/Destroy(force, silent)
	UnregisterSignal(parent, COMSIG_ATOM_DAMAGE_ACT)
	UnregisterSignal(parent, COMSIG_ATOM_FIRE_ACT)
	UnregisterSignal(parent, COMSIG_PARENT_EXAMINE)
	return ..()

/datum/component/volatile/emptorp
	desc = "<span class='warning'>It's highly volatile and risks misfires if subjected to heat!</span>"

///Overrides parent proc.
/datum/component/volatile/emptorp/explode()
	if(!parent)
		message_admins("Volatility component tried to explode with no attached parent. Contact a coder")
		return FALSE
	log_game("Volatile substance caused an electromagnetic reaction at [get_area(parent)]")
	var/base_ex_power = explosion_scale * volatility
	empulse(get_turf(parent), base_ex_power, base_ex_power * 2)
	explosion(parent, 0, 1, round(base_ex_power / 2), smoke = TRUE)
	if(!QDELETED(parent))
		qdel(parent)

/datum/component/volatile/helltorp //Hoo boy
	desc = "<span class='warning'>It's extremely volatile and prone to runaway reactions if subjected to heat!</span>"

///Overrides parent proc
/datum/component/volatile/helltorp/explode()
	if(!parent)
		message_admins("Volatility component tried to explode with no attached parent. Contact a coder")
		return FALSE
	log_game("Volatile substance caused a runaway hellfire reaction at [get_area(parent)]")
	var/base_ex_power = explosion_scale * volatility
	explosion(parent, 0, 0, base_ex_power, base_ex_power * 2, base_ex_power)
	var/turf/detonation_turf = get_turf(parent)
	detonation_turf.atmos_spawn_air("o2=20;plasma=110;TEMP=700")
	if(!QDELETED(parent))
		qdel(parent)
