/**Volatile substances.

Add this component to an atom to mark it as volatile, if it takes fire damage, is struck by something that's ignited, or optionally, when it's destroyed, it'll explode violently.

*/

/datum/component/volatile
	var/desc = "<span class='warning'>It's highly volatile and liable to explode if subjected to heat!</span>"
	var/volatility = 1
	var/volatile_when_hit = FALSE //Does this volatile thing blow up when it's destroyed?

/datum/component/volatile/proc/set_volatile_when_hit(flag)
	volatile_when_hit = flag

/datum/component/volatile/proc/explode()
	if(!parent)
		message_admins("Volatility component tried to explode with no attached parent. Contact a coder")
		return FALSE
	//Explosion! This can lead to a chain reaction if you're not careful... WATCH THOSE SHELLS MAA!
	log_game("Volatile substance caused an explosion at [get_area(parent)].")
	//explosion(parent, round(volatility), round(volatility * 2), round(volatility * 2.5), round(volatility * 3), TRUE, FALSE, round(volatility), FALSE, FALSE)
	explosion(parent, 0, round(volatility * 0.75), round(volatility * 1.5), round(volatility * 2), TRUE, FALSE, round(volatility * 1.5), FALSE, FALSE)

/datum/component/volatile/proc/burn_act()
	if(prob(CLAMP(volatility * 10, 0, 100))) //How likely we are to blow up
		explode()

/datum/component/volatile/proc/damage_react(datum/source, amount)
	//Is this thing volatile when smacked? Harder hits mean more likely to go up in flames...
	if(volatile_when_hit && prob(CLAMP(amount/5 * volatility, 0, 100)))
		explode()

/datum/component/volatile/proc/examine(datum/source, mob/user, list/examine_list)
	if(desc)
		examine_list += desc
		if(volatile_when_hit) //Don't play with the torpedo warheads
			examine_list += "<span class='warning'>It may explode if hit with enough force!</span>"

/datum/component/volatile/New(datum/P, volatility=1, volatile_when_hit=FALSE)
	. = ..()
	if(volatility <= 0)
		message_admins("Volatility component with volatility \"0\" added to [parent], deleting the volatility component...")
		RemoveComponent()
		return
	src.volatility = volatility
	src.volatile_when_hit = volatile_when_hit
	RegisterSignal(parent, COMSIG_ATOM_DAMAGE_ACT, .proc/damage_react)
	RegisterSignal(parent, COMSIG_ATOM_FIRE_ACT, .proc/burn_act)
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/examine)

/datum/component/volatile/Destroy(force, silent)
	UnregisterSignal(parent, COMSIG_ATOM_DAMAGE_ACT)
	UnregisterSignal(parent, COMSIG_ATOM_FIRE_ACT)
	UnregisterSignal(parent, COMSIG_PARENT_EXAMINE)
	. = ..()
