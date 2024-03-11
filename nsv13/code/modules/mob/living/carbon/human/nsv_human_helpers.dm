/**
 * # `species_examine_font()`
 *
 * This gets a humanoid's special examine font, which is used to color their species name during examine / health analyzing.
 * The first of these that applies is returned.
 * Returns:
 * * Metallic font if robotic
 * * Cyan if a toxinlover
 * * Yellow-ish if an Ethereal
 * * Purple if plasmaperson
 * * Rock / Brownish if a golem
 * * Green if none of the others apply (aka, generic organic)
*/
/mob/living/carbon/human/proc/species_examine_font()
	if((MOB_ROBOTIC in mob_biotypes))
		return "sc_robotic"
	if(HAS_TRAIT(src, TRAIT_TOXINLOVER))
		return "sc_toxlover"
	if(isethereal(src))
		return "sc_ethereal"
	if(isplasmaman(src))
		return "sc_plasmaman"
	if(isgolem(src))
		return "sc_golem"
	return "sc_normal"
