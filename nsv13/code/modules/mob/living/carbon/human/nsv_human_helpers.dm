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
		return "<font color='#aaa9ad'>"
	if(HAS_TRAIT(src, TRAIT_TOXINLOVER))
		return "<font color='#00ffff'>"
	if(isethereal(src))
		return "<font color='#e0d31d'>"
	if(isplasmaman(src))
		return "<font color='#800080'>"
	if(isgolem(src))
		return "<font color='#8b4513'>"
	return "<font color='#18d855'>"
