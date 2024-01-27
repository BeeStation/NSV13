/proc/human_last_name_random()
	return pick(pick(GLOB.last_names_female), pick(GLOB.last_names_male))

/proc/human_first_name_random()
	return pick(pick(GLOB.first_names_female), pick(GLOB.first_names_male))

// returns male or female name
// if gender = NEUTER returns male/female at random
// set gender to MALE or FEMALE to specify
/proc/human_full_name_random(gender = NEUTER)
	switch(gender)
		if(MALE)
			return pick(GLOB.first_names_male) + " " + pick(GLOB.last_names_male)
		if(FEMALE)
			return pick(GLOB.first_names_female) + " " + pick(GLOB.last_names_female)
		else
			return human_full_name_random(pick(MALE, FEMALE))



