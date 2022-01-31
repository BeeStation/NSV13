/obj/machinery/atmospherics/components/unary/tank/nucleium
	name = "pressure tank (Nucleium)"
	icon_state = "red"

/obj/machinery/atmospherics/components/unary/tank/nucleium/New()
	..()
	var/datum/gas_mixture/air_contents = airs[1]
	air_contents.set_moles(GAS_NUCLEIUM, AIR_CONTENTS)
