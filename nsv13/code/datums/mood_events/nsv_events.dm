/datum/mood_event/moth_drink_blood
	description = "<span class='nicegreen'>That hit the spot!</span>\n"
	mood_change = 3
	timeout = 7 MINUTES

/datum/mood_event/tailpull
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
	timeout = 4 MINUTES

/datum/mood_event/hate_shower
	description = "<span class='boldwarning'>I <i>HATE</i> showers!</span>\n"
	mood_change = -2
	timeout = 5 MINUTES

/datum/mood_event/torphug
	description = "<span class='nicegreen'>I really needed that..</span>\n"
	mood_change = 1
	timeout = 2 MINUTES

/datum/mood_event/drink_navy_coffee
	description = "<span class='nicegreen'><b>THAT SHIT TASTED FUCKING DELICIOUS LET'S GO FUCK SOME SYNDICATE SHIPS UP, NAVY FOR LIFE WOOOOOO!!</b></span>\n"
	mood_change = 3
	timeout = 7 MINUTES

/datum/mood_event/drink_navy_coffee/add_effects(list/faction)
	if(FACTION_SYNDICATE in faction)
		description = "<span class='nicegreen'><b>THAT SHIT TASTED FUCKING DELICIOUS LET'S GO FUCK SOME NANOTRASEN SHIPS UP, NAVY FOR LIFE WOOOOOO!!</b></span>\n"


/datum/mood_event/cheers
	description = "<span class='nicegreen'>Cheers! ¡Salud! Kanpai! Prost! Skål! Santé! Sláinte! Saúde!</span>\n"
	mood_change = 3
	timeout = 30 SECONDS

/datum/mood_event/lizard_shivers
	description = "<span class='warning'>I'm shivering.. I need to find a spot where I can bask in the sun!</span>\n" //Evolved mental response, even if not entirely true here.
	mood_change = -2

/datum/mood_event/comfy_lizard_temperature
	description = "<span class='nicegreen'>I'm nice and warm! I missed this feeling..</span>\n" //These ships run at 20°C by default, which is.. not very nice for something coldblooded.
	mood_change = 2 //This is really hard to hit and maintain so I felt like at least a +2 would be appropriate.
