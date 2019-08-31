/// This component drops gas on when a specific thing happens. Currently only on rinsing and qdeleting
/datum/component/gas_dropper
	var/datum/gas/gas
	var/gas_amount

// droptext is an arglist for visible_message
// dropsound is a list of potential sounds that gets picked from
/datum/component/gas_dropper/Initialize(var/gas_type, var/gas_amount, var/release_on_qdel, var/release_on_rinse)
	if(!ismovableatom(parent))
		return COMPONENT_INCOMPATIBLE
	if(release_on_rinse)
		RegisterSignal(parent, COMSIG_COMPONENT_RINSE_ACT, .proc/rinse_react)
	if(release_on_qdel)
		RegisterSignal(parent, COMSIG_PARENT_QDELETING, .proc/release_gas)

	gas = gas_type
	src.gas_amount = gas_amount

/datum/component/gas_dropper/proc/rinse_react()
	var/atom/A = parent
	A.visible_message("<span class='notice'>[parent] evaporates.</span>")
	release_gas()
	qdel(parent)

/datum/component/gas_dropper/proc/release_gas()
	var/atom/A = parent

	var/turf/open/T = get_turf(A)

	if(!istype(T))
		return

	T.atmos_spawn_air("plasma=[gas_amount]")