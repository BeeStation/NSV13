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
var/list/ship_name_prefix = list("Trail","Tongue","Whirl","Titan","King","Lord","Prince","Dream","Hell","Heaven","Clown","Crab",
	"Lion","Hound","Devil","Demon","Dragon","Mime","Monster","Headmin","Maintainer","Man","Death","Space","Singularity",
	"Supermatter","Station","Alien","Hippie","Black","God","Dread","Robot","Xeno","Beast","Cuban","Ian","Changeling","Meme",
	"Dutch","Toolbox","Blood","Light","Rune","Lightning","War","Peace","Sanguine","Captain","Sky","Carp","Sausage","Slime",
	"Planet","Blast","Love","Dream","Pirate","War","Hellion","Spider","Goliath","Wolf","Rail","Shell","Pilot","Asteroid","Yog",
	"Bat","Weed","Princess","Widow","Monkey","Cargonia","Atmosia","Security","Storm","Honk","Honker","Science","Mystery",
	"Banana","Bee","Goon","Owl","Commie","Magic","Bluespace","Plasma","Human","Woman","Ghost","Eagle","Autist","Admin","Bwoink",
	"Mother","Snake","Hammer","Reactor","Grey","Star")
var/list/ship_name_suffix = list("slayer","blazer","bringer","slapper","twirler","nought","stomper","killer","farter","bomber",
	"destructor","stabber","holder","beater","keeper","seeker","chaser","developer","looter","slipper","loser","eater","devourer",
	"biter","maker","blaster","leader","chopper","wrecker","bender","hauler","miner","stalker","observer","arbiter","overseer",
	"watcher","indoctrinator","dominator","robustor","bane","maker","chomper","burner","hunter","puncher","raider","hoarder",
	"harmer","runner","gunner","slinger","shooter","cruiser","ship","charmer","wrangler","rider")

/proc/generate_ship_name()
	var/name = ""
	name = pick(ship_name_prefix) + pick(ship_name_suffix)
	return capitalize(name)
