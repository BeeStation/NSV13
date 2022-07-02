/proc/new_station_name()
	var/name = ""
	var/new_station_name = ""
	if(!name)
		name = pick(GLOB.station_names)
	new_station_name = "NSV [name]"

	return new_station_name

/proc/new_prebuilt_fighter_name()
	var/numbers = rand(1,2)
	var/name = ""
	var/new_prebuilt_fighter_name = ""
	if(!name)
		name = pick(GLOB.station_names) //pulling from this list for now
		switch(numbers)
			if(1)
				new_prebuilt_fighter_name = "[name] [rand(1,99)]"
			if(2)
				new_prebuilt_fighter_name = "[name] \Roman[rand(1,99)]"

	return new_prebuilt_fighter_name

// FTL13-style ship name generation - Credit to Monster
var/list/ship_name_prefix = list(
	"Devil","Plasma","Grey","Black","Star","Trail","Tongue","Titan","King","Lord","Prince","Dream","Hell",
	"Heaven","Crab","Lion","Hound","Demon","Dragon","Monster","Man","Death","Space",
	"Whirl","God","Dread","Robot","Beast","Blood","Light","Rune","Lightning","War","Peace","Sky","Sausage","Slime",
	"Planet","Blast","Love","Dream","Pirate","War","Hellion","Spider","Goliath","Wolf","Rail",
	"Bat","Widow","Storm","Science","Mystery","Owl","Ghost","Eagle","Snake","Hammer")
var/list/ship_name_suffix = list("slayer","blazer","bringer","slapper","twirler","nought","stomper","killer","bomber",
	"destructor","stabber","holder","beater","keeper","seeker","chaser","eater","devourer",
	"biter","maker","blaster","leader","chopper","wrecker","bender","hauler","miner","stalker","overseer",
	"watcher","indoctrinator","dominator","bane","maker","chomper","burner","hunter","puncher","raider",
	"runner","gunner","slinger","shooter","cruiser","ship","wrangler","rider")

/proc/generate_ship_name()
	var/name = ""
	name = pick(ship_name_prefix) + pick(ship_name_suffix)
	return capitalize(name)

/proc/generate_fighter_name()
	var/name = ""
	name = pick(GLOB.fighter_noun) + " of " + "[pick(0,1) ? pick(GLOB.fighter_moon) : pick(GLOB.fighter_planet)]"
	return name
 
