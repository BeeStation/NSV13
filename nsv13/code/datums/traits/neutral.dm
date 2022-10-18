/datum/quirk/spaceborn
	name = "Spaceborn"
	desc = "You've spent most of your life in low gravity environments and your body has adapted as such. You've learnt to go without oxygen longer than most but you don't handle higher G-forces very well."
	value = 0
	mob_trait = TRAIT_GFORCE_WEAKNESS
	human_only = TRUE
	gain_text = "<span class='notice'>Your body feels heavy.</span>"
	lose_text = "<span class='notice'>You don't feel so heavy anymore.</span>"
	medical_record_text = "The patient's body has adapted to low-G environments."
	// Extra safety checks to make sure no one cheeses the multiplication somehow. Although ideally this trait shouldn't be removed
	var/og_oxmod = 1
	var/cached_oxmod = 1

/datum/quirk/spaceborn/add()
	var/mob/living/carbon/human/H = quirk_holder
	if(!istype(H) || (TRAIT_NOBREATH in H.dna.species.inherent_traits))
		qdel(src)
		return
	og_oxmod = H.physiology.oxy_mod
	H.physiology.oxy_mod *= 0.8
	cached_oxmod = H.physiology.oxy_mod

/datum/quirk/spaceborn/remove()
	if(!quirk_holder)
		return
	var/mob/living/carbon/human/H = quirk_holder
	if(H.physiology.oxy_mod == cached_oxmod)
		H.physiology.oxy_mod = og_oxmod
	else
		H.physiology.oxy_mod = initial(H.physiology.oxy_mod)
