/datum/ai_laws/add_hacked_law(law) //Overridden for the sake of synthetics, as they need a ultra priority law to say that they outrank people.
	if (!(law in hacked))
		hacked += law