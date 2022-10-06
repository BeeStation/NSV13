/datum/mood_event/moth_drink_blood
	description = "<span class='nicegreen'>That hit the spot!</span>\n"
	mood_change = 10
	timeout = 10 MINUTES //NSV13 - Moths enjoy drinking blood on occasion

/datum/mood_event/tailpull //NSV felinid moodlets
	description = "<span class='warning'>OUCH! Stop pulling my tail! It hurts!\n"
	mood_change = -2
	timeout = 2 MINUTES

/datum/mood_event/watersprayed
	description = "<span class='warning'>I hate being sprayed with water!</span>\n"
	mood_change = -1
	timeout = 30 SECONDS

/datum/mood_event/watersplashed
	//splash gets a larger debuff
	description = "<span class='boldwarning'>I hate being splashed with water!</span>\n"
	mood_change = -2
	timeout = 30 SECONDS

/datum/mood_event/stuck_in_pool
	description = "<span class='boldwarning'>I'M STUCK IN THE POOL!</span>\n"
	mood_change = -5 //felinids really hate water

/datum/mood_event/was_stuck_in_pool
	description = "<span class='warning'>I was stuck in the pool, I never thought I'd get out.</span>\n"
	mood_change = -2 //felinids really hate water
	timeout = 4 MINUTES //End of NSV code

/datum/mood_event/hate_shower //NSV felinid moodlets
	description = "<span class='boldwarning'>I <i>HATE</i> showers!</span>\n"
	mood_change = -2
	timeout = 5 MINUTES //End of NSV code
