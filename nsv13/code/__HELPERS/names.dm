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

/var/list/fighter_noun = list(
	"Paw","Hand","Warmth","Eye","Wings","Palms","Pillar",
	"Dawn","Fist","Chicken","Hawk","Sparrow","Thunder","Watcher",
	"Guardian","Stalker","Heron","Swan","Swallow","The Unladen Swallow",
	"Wren","Corvid","Falcon","Eagles","Owl","Kestrel","Harrier","Vultures",
	"Osprey","Parrot","Kingfisher","Toucan","Trogon","Inflation","Union",
	"Cayenne","Mortgage","Hen","Light","Puma","Aglet","Seller","Steam",
	"Lighting","Wriggler","Carp","Ginseng","Hyena","Tenement","Jet","Cheese",
	"Asterisk")

/var/list/fighter_planet = list(
	"Mercury","Venus","Terra","Mars","Ceres",
	"Pallas","Vesta","Jupiter","Saturn","Neptune",
	"Pluto","Makemake","Haumea","Quaoar","Orcus","Eris","Gonggong","Spe",
	"Arion","Arkas","Orbitar","Taphao Thong","Taphao Kaew","Dimidium","Galileo",
	"Brahe","Lipperhey","Janssen","Harriot","AEgir","Amateru","Dagon","Tadmor",
	"Meztli","Smertrios","Hypatia","Quijote","Dulcinea","Rocinante","Sancho",
	"Thestias","Saffar","Samh","Majriti","Fortitudo","Draugr","Poltergeist",
	"Phobetor","Arber","Tassili","Madriu","Naqaya","Bocaprins","Yanyan","Sissi",
	"Ganja","Tondra","Eburonia","Drukyul","Yvaga","Naron","Guarani","Mastika",
	"Bendida","Nakanbe","Awasis","Caleuche","Wangshu","Melquiades","Pipitea",
	"Ditso","Asye","Veles","Finlay","Onasilos","Makropulos","Surt","Bionayel","Eyeke",
	"Cayahuanca","Hamarik","Abol","Hiisi","Belisama","Mintome","Neri","Toge","Iolaus",
	"Koyopa","Independance","Ixbalanque","Victoriapeak","Magor","Fold","Santamasa",
	"Noifasui","Kavian","Babylonia","Bran","Alef","Lete","Chura","Wadirum","Buru",
	"Staburags","Beirut","Umbaassa","Vytis","Peitruss","Trimobe","Baiduri","Ggantija",
	"Cuptor","Xolotl","Isli","Hairu","Bagan","Lagigurans","Nachtwacht","Kereru","Xolotlan",
	"Equiano","Albmi","Perwana","Jebus","Pollera","Tumearandu","Sumajmajta","Haik","Leklsullun",
	"Pirx","Viriato","Aumatex","Negoiu","Teberda","Dopere","Vlasina","Viculus","Iztok","Krotoa",
	"Halla","Riosar","Samagiya","Isagel","Eiger","Ugarit","Sazum","Tanzanite","Maeping","Agouto",
	"Ramajay","Khomsa","Gokturk","Tryzub","Barajeel","Cruinlagh","Mulchatna","Ibirapita",
	"Madalitso","Bambaruush")

/var/list/fighter_moon = list(
	"Luna","Phobos","Deimos","Metis","Adrastea","Amalthea","Thebe","Io","Europa",
	"Ganymede","Callisto","Themisto","Leda","Ersa","Himalia","Pandia","Lysithea","Elara",
	"Dia","Carpo","Valetudo","Euporie","Eupheme","Mneme","Harpalyke","Orthosie","Helike",
	"Praxidike","Thelxinoe","Thyone","Ananke","Iocaste","Hermippe","Philophrosyne","Pasithee",
	"Eurydome","Chaldene","Isonoe","Kallichore","Erinome","Kale","Eirene","Aitne","Eukelade",
	"Arche","Taygete","Carme","Herse","Kalyke","Hegemone","Pasiphae","Sponde","Megaclite",
	"Cyllene","Sinope","Aoede","Autonoe","Callirrhoe","Kore","Pan","Daphnis","Atlas","Prometheus",
	"Pandora","Epimetheus","Janus","Aegaeon","Mimas","Methone","Anthe","Pallene","Enceladus",
	"Tethys","Telesto","Calypso","Dione","Helene","Polydeuces","Rhea","Titan","Hyperion","Iapetus",
	"Kiviuq","Ijiraq","Phoebe","Paaliaq","Skathi","Albiorix","Bebhionn","Erriapus","Skoll","Tarqeq",
	"Siarnaq","Tarvos","Hyrrokkin","Greip","Mundilfari","Bergelmir","Narvi","Jarnsaxa","Suttungr","Hati",
	"Bestla","Farbauti","Thrymr","Aegir","Kari","Fenrir","Surtur","Loge","Ymir","Fornjot","Cordelia",
	"Ophelia","Bianca","Cressida","Desdemona","Juliet","Portia","Rosalind","Cupid","Belinda","Perdita",
	"Puck","Mab","Miranda","Ariel","Umbriel","Titania","Oberon","Francisco","Caliban","Stephano","Trinculo",
	"Sycorax","Margaret","Prospero","Setebos","Ferdinand","Naiad","Thalassa","Despina","Galatea",
	"Larissa","Hippocamp","Proteus","Triton","Nereid","Halimede","Sao","Laomedeia","Psamathe","Neso",
	"Charon","Styx","Nix","Kerberos","Hydra","MK2","Namaka","Weywot","Vanth","Dysnomia","Xiangliu")

/proc/generate_fighter_name()
	var/name = ""
	var/randomizer = rand(0,1)
	var/chooser = FALSE
	if(randomizer == 0)
		chooser = FALSE
	else
		chooser = TRUE
	name = pick(fighter_noun) + " of " + "[chooser ? pick(fighter_moon) : pick(fighter_planet)]"
	return capitalize(name)
