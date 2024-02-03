/*

### This file contains a list of all the areas in your station. Format is as follows:

/area/CATEGORY/OR/DESCRIPTOR/NAME 	(you can make as many subdivisions as you want)
	name = "NICE NAME" 				(not required but makes things really nice)
	icon = 'ICON FILENAME' 			(defaults to 'icons/turf/areas.dmi')
	icon_state = "NAME OF ICON" 	(defaults to "unknown" (blank))
	requires_power = FALSE 				(defaults to true)
	ambience_index = AMBIENCE_GENERIC   (picks the ambience from an assoc list in ambience.dm)
	ambientsounds = list()				(defaults to ambience_index's assoc on Initialize(). override it as "ambientsounds = list('sound/ambience/signal.ogg')" or by changing ambience_index)

NOTE: there are two lists of areas in the end of this file: centcom and station itself. Please maintain these lists valid. --rastaf0

*/


/*-----------------------------------------------------------------------------*/
//AQUILA EDIT entire names and mood messages translated into polish
/area/ai_monitored	//stub defined ai_monitored.dm

/area/ai_monitored/turret_protected

/area/space
	icon_state = "space"
	requires_power = TRUE
	always_unpowered = TRUE
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	power_light = FALSE
	power_equip = FALSE
	power_environ = FALSE
	area_flags = UNIQUE_AREA
	outdoors = TRUE
	ambience_index = null
	ambient_music_index = AMBIENCE_SPACE
	ambient_buzz = null
	sound_environment = SOUND_AREA_SPACE

/area/space/nearstation
	icon_state = "space_near"
	dynamic_lighting = DYNAMIC_LIGHTING_IFSTARLIGHT

/area/start
	name = "start area"
	icon_state = "start"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	has_gravity = STANDARD_GRAVITY
	ambience_index = null
	ambient_buzz = null

/area/testroom
	requires_power = FALSE
	name = "Test Room"
	icon_state = "storage"

//EXTRA

/area/asteroid
	name = "Asteroida"
	icon_state = "asteroid"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	ambience_index = AMBIENCE_MINING
	sound_environment = SOUND_AREA_ASTEROID
	area_flags = UNIQUE_AREA

/area/asteroid/nearstation
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	ambience_index = AMBIENCE_RUINS
	always_unpowered = FALSE
	requires_power = TRUE
	area_flags = UNIQUE_AREA | BLOBS_ALLOWED

/area/asteroid/nearstation/bomb_site
	name = "Asteroida do testowania bomb"

//STATION13

//Docking Areas

/area/docking
	ambience_index = AMBIENCE_MAINT
	mood_bonus = -1
	mood_message = "<span class='warning'>Czujesz że nie powinieneś tutaj przebywać przy takim ruchu wahadłowców...\n</span>"
	lighting_colour_tube = "#1c748a"
	lighting_colour_bulb = "#1c748a"

/area/docking/arrival
	name = "Dok Przylotów"
	icon_state = "arrivaldockarea"

/area/docking/arrivalaux
	name = "Pomocniczy Dok Przylotów"
	icon_state = "arrivalauxdockarea"

/area/docking/bridge
	name = "Obszar Dokowania Mostku"
	icon_state = "bridgedockarea"

//Maintenance

/area/maintenance
	ambience_index = AMBIENCE_MAINT
	sound_environment = SOUND_AREA_TUNNEL_ENCLOSED
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA
	mood_bonus = -1
	mood_message = "<span class='warning'>Jest tutaj za ciasno!\n</span>"
	// assistants are associated with maints, jani closet is in maints, engis have to go into maints often
	mood_job_allowed = list(JOB_NAME_ASSISTANT, JOB_NAME_JANITOR, JOB_NAME_STATIONENGINEER, JOB_NAME_CHIEFENGINEER, JOB_NAME_ATMOSPHERICTECHNICIAN)
	mood_job_reverse = TRUE
	lighting_colour_tube = "#ffe5cb"
	lighting_colour_bulb = "#ffdbb4"

//Maintenance - Departmental

/area/maintenance/department/chapel
	name = "Tunel Konserwacyjny Kaplicy"
	icon_state = "maint_chapel"

/area/maintenance/department/chapel/monastery
	name = "Tunel Konserwacyjny Klasztoru"
	icon_state = "maint_monastery"

/area/maintenance/department/crew_quarters/bar
	name = "Tunel Konserwacyjny Baru"
	icon_state = "maint_bar"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/maintenance/department/crew_quarters/dorms
	name = "Tunel Konserwacyjny Kwatery Załogi"
	icon_state = "maint_dorms"

/area/maintenance/department/eva
	name = "Tunel Konserwacyjny EVA"
	icon_state = "maint_eva"

/area/maintenance/department/electrical
	name = "Tunel Konserwacyjny Rozdzielni"
	icon_state = "maint_electrical"

/area/maintenance/department/engine/atmos
	name = "Tunel Konserwacyjny Atmosferycznego"
	icon_state = "maint_atmos"

/area/maintenance/department/security
	name = "Tunel Konserwacyjny Ochrony"
	icon_state = "maint_sec"

/area/maintenance/department/security/brig
	name = "Tunel Konserwacyjny Brygu"
	icon_state = "maint_brig"

/area/maintenance/department/medical
	name = "Tunel Konserwacyjny Placówki Medycznej"
	icon_state = "medbay_maint"

/area/maintenance/department/medical/central
	name = "Centralny Tunel Konserwacyjny Placówki Medycznej"
	icon_state = "medbay_maint_central"

/area/maintenance/department/medical/morgue
	name = "Tunel Konserwacyjny Kostnicy"
	icon_state = "morgue_maint"

/area/maintenance/department/science
	name = "Tunel Konserwacyjny Wydziału Badawczego"
	icon_state = "maint_sci"

/area/maintenance/department/science/central
	name = "Centralny Tunel Konserwacyjny Wydziału Badawczego"
	icon_state = "maint_sci_central"

/area/maintenance/department/cargo
	name = "Tunel Konserwacyjny Zapoatrzeń"
	icon_state = "maint_cargo"

/area/maintenance/department/bridge
	name = "Tunel Konserwacyjny Mostku"
	icon_state = "maint_bridge"

/area/maintenance/department/engine
	name = "Tunel Konserwacyjny Wydziału Inżynieryjnego"
	icon_state = "maint_engi"

/area/maintenance/department/science/xenobiology
	name = "Tunel Konserwacyjny Ksenobiologii"
	icon_state = "xenomaint"
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA | XENOBIOLOGY_COMPATIBLE


//Maintenance - Generic

/area/maintenance/aft
	name = "Tunel Konserwacyjny Rufy"
	icon_state = "aftmaint"

/area/maintenance/aft/secondary
	name = "Drugorzędny Tunel Konserwacyjny Rufy"
	icon_state = "aftmaint"

/area/maintenance/central
	name = "Centralny Tunel Konserwacyjny"
	icon_state = "centralmaint"

/area/maintenance/central/secondary
	name = "Drugorzędny Centralny Tunel Konserwacyjny"
	icon_state = "centralmaint"

/area/maintenance/fore
	name = "Tunel Konserwacyjny Dzioba"
	icon_state = "foremaint"

/area/maintenance/fore/secondary
	name = "Drugorzędny Tunel Konserwacyjny Dzioba"
	icon_state = "foremaint"

/area/maintenance/starboard
	name = "Tunel Konserwacyjny Sterburty"
	icon_state = "starboardmaint"

/area/maintenance/starboard/central
	name = "Centralny Tunel Konserwacyjny Sterburty"
	icon_state = "starboardmaint"

/area/maintenance/starboard/secondary
	name = "Drugorzędny Tunel Konserwacyjny Sterburty"
	icon_state = "starboardmaint"

/area/maintenance/starboard/aft
	name = "Tunel Konserwacyjny Bakburty Sterburty"
	icon_state = "asmaint"

/area/maintenance/starboard/aft/secondary
	name = "Drugorzędny Tunel Konserwacyjny Bakburty Sterburty"
	icon_state = "asmaint"

/area/maintenance/starboard/fore
	name = "Tunel Konserwacyjny Sterburty Dzioba"
	icon_state = "fsmaint"

/area/maintenance/port
	name = "Tunel Konserwacyjny Burty"
	icon_state = "portmaint"

/area/maintenance/port/central
	name = "Centralny Tunel Konserwacyjny Burty"
	icon_state = "centralmaint"

/area/maintenance/port/aft
	name = "Tunel Konserwacyjny Burty Bakburty"
	icon_state = "apmaint"

/area/maintenance/port/fore
	name = "Tunel Konserwacyjny Burty Dzioba"
	icon_state = "fpmaint"

/area/maintenance/disposal
	name = "Utylizacja Odpadów"
	icon_state = "disposal"

/area/maintenance/disposal/incinerator
	name = "Spalarnia"
	icon_state = "incinerator"

//Maintenance - Upper

/area/maintenance/upper/aft
	name = "Tunel Konserwacyjny Górnej Rufy" // no co, to nie ja nazwałem tego upper aft
	icon_state = "aftmaint"

/area/maintenance/upper/aft/secondary
	name = "Drugorzędny Tunel Konserwacyjny Górnej Rufy"
	icon_state = "aftmaint"

/area/maintenance/upper/central
	name = "Centralny Górny Tunel Konserwacyjny"
	icon_state = "centralmaint"

/area/maintenance/upper/central/secondary
	name = "Drugorzędny Górny Centralny Tunel Konserwacyjny"
	icon_state = "centralmaint"

/area/maintenance/upper/fore
	name = "Tunel Konserwacyjny Górnego Dzioba"
	icon_state = "foremaint"

/area/maintenance/upper/fore/secondary
	name = "Drugorzędny Tunel Konserwacyjny Dzioba"
	icon_state = "foremaint"

/area/maintenance/upper/starboard
	name = "Tunel Konserwacyjny Górnej Sterburty"
	icon_state = "starboardmaint"

/area/maintenance/upper/starboard/central
	name = "Centralny Tunel Konserwacyjny Górnej Sterburty"
	icon_state = "starboardmaint"

/area/maintenance/upper/starboard/secondary
	name = "Drugorzędny Centralny Tunel Konserwacyjny Górnej Sterburty"
	icon_state = "starboardmaint"

/area/maintenance/upper/starboard/aft
	name = "Tunel Konserwacyjny Górnej Bakburty Sterburty"
	icon_state = "asmaint"

/area/maintenance/upper/starboard/aft/secondary
	name = "Drugorzędny Tunel Konserwacyjny Górnej Bakburty Sterburty"
	icon_state = "asmaint"

/area/maintenance/upper/starboard/fore
	name = "Tunel Konserwacyjny Górnej Sterburty Dzioba"
	icon_state = "fsmaint"

/area/maintenance/upper/port
	name = "Tunel Konserwacyjny Górnej Burty"
	icon_state = "pmaint"

/area/maintenance/upper/port/central
	name = "Centralny Tunel Konserwacyjny Górnej Burty"
	icon_state = "centralmaint"

/area/maintenance/upper/port/aft
	name = "Tunel Konserwacyjny Górnej Burty Bakburty"
	icon_state = "apmaint"

/area/maintenance/upper/port/fore
	name = "Tunel Konserwacyjny Górnej Burty Dzioba"
	icon_state = "fpmaint"


//Hallway
/area/hallway
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/hallway
	lighting_colour_tube = "#ffce99"
	lighting_colour_bulb = "#ffdbb4"
	lighting_brightness_tube = 8

/area/hallway/primary
	name = "Główny Korytarz"

/area/hallway/primary/aft
	name = "Główny Korytarz Rufy"
	icon_state = "hallA"

/area/hallway/primary/fore
	name = "Główny Korytarz Dzioba"
	icon_state = "hallF"

/area/hallway/primary/starboard
	name = "Główny Korytarz Sterburty"
	icon_state = "hallS"

/area/hallway/primary/port
	name = "Główny Korytarz Burty"
	icon_state = "hallP"

/area/hallway/primary/central
	name = "Centralny Główny Korytarz"
	icon_state = "hallC"

/area/hallway/secondary/command
	name = "Korytarz Dowództwa"
	icon_state = "bridge_hallway"

/area/hallway/secondary/construction
	name = "Teren Budowy"
	icon_state = "construction"

/area/hallway/secondary/exit
	name = "Korytarz Promu Ratunkowego"
	icon_state = "escape"

/area/hallway/secondary/exit/departure_lounge
	name = "Hala Odlotów"
	icon_state = "escape_lounge"

/area/hallway/secondary/entry
	name = "Korytarz Przylotów"
	icon_state = "entry"

/area/hallway/secondary/service
	name = "Korytarz Usług"
	icon_state = "hall_service"

/area/hallway/secondary/law
	name = "Korytarz Prawny"
	icon_state = "security"

/area/hallway/secondary/asteroid
	name = "Korytarz Asteroidy"
	icon_state = "construction"

/area/hallway/upper/primary/aft
	name = "Główny Korytarz Górnej Rufy"
	icon_state = "hallA"

/area/hallway/upper/primary/fore
	name = "Główny Korytarz Górnego Dzioba"
	icon_state = "hallF"

/area/hallway/upper/primary/starboard
	name = "Główny Korytarz Górnej Sterburty"
	icon_state = "hallS"

/area/hallway/upper/primary/port
	name = "Główny Korytarz Górnej Burty"
	icon_state = "hallP"

/area/hallway/upper/primary/central
	name = "Centralny Główny Korytarz Górnej Burty"
	icon_state = "hallC"

/area/hallway/upper/secondary/command
	name = "Górny Korytarz Dowództwa"
	icon_state = "bridge_hallway"

/area/hallway/upper/secondary/construction
	name = "Górny Plac Budowy"
	icon_state = "construction"

/area/hallway/upper/secondary/exit
	name = "Drugorzędny Górny Korytarz Promu Ratunkowego"
	icon_state = "escape"

/area/hallway/upper/secondary/exit/departure_lounge
	name = "Górna Hala Odlotów"
	icon_state = "escape_lounge"

/area/hallway/upper/secondary/entry
	name = "Górny korytarz Hali Przylotów"
	icon_state = "entry"

/area/hallway/upper/secondary/service
	name = "Górny Korytarz Usłóg"
	icon_state = "hall_service"

//Command

/area/bridge
	name = "Mostek"
	icon_state = "bridge"
	ambientsounds = list('sound/ambience/signal.ogg')

	lighting_colour_tube = "#ffce99"
	lighting_colour_bulb = "#ffdbb4"
	lighting_brightness_tube = 8
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/bridge/meeting_room
	name = "Sala konferencyjna szefów personelu"
	icon_state = "meeting"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/bridge/meeting_room/council
	name = "Izba Rady"
	icon_state = "meeting"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/bridge/showroom/corporate
	name = "Salon firmowy"
	icon_state = "showroom"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/crew_quarters/heads/captain
	name = "Biuro Kapitana"
	icon_state = "captain"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/crew_quarters/heads/captain/private
	name = "Kwatera Kapitana"
	icon_state = "captain_private"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/crew_quarters/heads/chief
	name = "Biuro Starszego Inżyniera"
	icon_state = "ce_office"

/area/crew_quarters/heads/cmo
	name = "Biuro Ordynatora"
	icon_state = "cmo_office"

/area/crew_quarters/heads/hop
	name = "Biuro Szefa Personelu"
	icon_state = "hop_office"

/area/crew_quarters/heads/hos
	name = "Biuro Szefa Ochrony"
	icon_state = "hos_office"

/area/crew_quarters/heads/hor
	name = "Biuro Dyrektora Badań"
	icon_state = "rd_office"

/area/comms
	name = "Przekaźnik Womunikacyjny"
	icon_state = "tcom_sat_cham"
	lighting_colour_tube = "#e2feff"
	lighting_colour_bulb = "#d5fcff"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/server
	name = "Serwerownia Wiadomości"
	icon_state = "server"
	sound_environment = SOUND_AREA_STANDARD_STATION

//Crew

/area/crew_quarters
	lighting_colour_tube = "#ffce99"
	lighting_colour_bulb = "#ffdbb4"
	lighting_brightness_tube = 8
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/crew_quarters/dorms
	name = "Kwatery Załogi"
	icon_state = "dorms"
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED | UNIQUE_AREA
	mood_bonus = 3
	mood_message = "<span class='nicegreen'>Nie ma to jak we kwaterach!\n</span>"

/area/commons/dorms/barracks
	name = "Kwatery Odpoczynkowe"

/area/commons/dorms/barracks/male
	name = "Męskie Kwatery Odpoczynkowe"
	icon_state = "dorms_male"

/area/commons/dorms/barracks/female
	name = "Źeńskie Kwatery Odpoczynkowe"
	icon_state = "dorms_female"

/area/commons/dorms/laundry
	name = "Pralnia"
	icon_state = "laundry_room"

/area/crew_quarters/dorms/upper
	name = "Górne Kwatery Odpoczynkowe"

/area/crew_quarters/cryopods
	name = "Pokój Kriokapsuł"
	icon_state = "cryopod"
	lighting_colour_tube = "#e3ffff"
	lighting_colour_bulb = "#d5ffff"

/area/crew_quarters/toilet
	name = "Toalety Kwater Załogi"
	icon_state = "toilet"
	lighting_colour_tube = "#e3ffff"
	lighting_colour_bulb = "#d5ffff"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/crew_quarters/toilet/auxiliary
	name = "Toalety Pomocnicze"
	icon_state = "toilet"

/area/crew_quarters/toilet/locker
	name = "Toalety Szatni"
	icon_state = "toilet"

/area/crew_quarters/toilet/restrooms
	name = "Toalety"
	icon_state = "toilet"

/area/crew_quarters/locker
	name = "Szatnia"
	icon_state = "locker"

/area/crew_quarters/lounge
	name = "Hala Odpoczynkowa"
	icon_state = "yellow"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/crew_quarters/fitness
	name = "Pokój Fitnesu"
	icon_state = "fitness"

/area/crew_quarters/fitness/locker_room
	name = "Szatnia Uniseks"
	icon_state = "fitness"

/area/crew_quarters/fitness/recreation
	name = "Obszar Rekreacyjny"
	icon_state = "fitness"

/area/crew_quarters/fitness/recreation/upper
	name = "Górny Obszar Rekreacyjny"
	icon_state = "fitness"

/area/crew_quarters/park
	name = "Rekreacyjnyn Park"
	icon_state = "fitness"
	lighting_colour_bulb = "#80aae9"
	lighting_colour_tube = "#80aae9"
	lighting_brightness_bulb = 9

/area/crew_quarters/cafeteria
	name = "Kafeteria"
	icon_state = "cafeteria"

/area/crew_quarters/kitchen
	name = "Kuchnia"
	icon_state = "kitchen"
	lighting_colour_tube = "#e3ffff"
	lighting_colour_bulb = "#d5ffff"

/area/crew_quarters/kitchen/coldroom
	name = "Chłodnia"
	icon_state = "kitchen_cold"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/crew_quarters/bar
	name = "Bar"
	icon_state = "bar"
	mood_bonus = 5
	mood_message = "<span class='nicegreen'>Uwielbiam przebywać w tym barze!\n</span>"
	lighting_colour_tube = "#fff4d6"
	lighting_colour_bulb = "#ffebc1"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/crew_quarters/bar/mood_check(mob/living/carbon/subject)
	if(istype(subject) && HAS_TRAIT(subject, TRAIT_LIGHT_DRINKER))
		return FALSE
	return ..()

/area/crew_quarters/bar/lounge
	name = "Bar i Salon"
	icon_state = "lounge"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/crew_quarters/bar/Initialize(mapload)
	. = ..()
	GLOB.bar_areas += src

/area/service/bar/Initialize(mapload)
	. = ..()
	GLOB.bar_areas += src

/area/crew_quarters/bar/atrium
	name = "Atrium"
	icon_state = "bar"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/crew_quarters/electronic_marketing_den
	name = "Nora Marketingu Elektronicznego"
	icon_state = "bar"

/area/crew_quarters/abandoned_gambling_den
	name = "Opuszczona Nora Hazardu"
	icon_state = "abandoned_g_den"

/area/crew_quarters/abandoned_gambling_den/secondary
	icon_state = "abandoned_g_den_2"

/area/crew_quarters/theatre
	name = "Teatr"
	icon_state = "theatre"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/crew_quarters/theatre/backstage
	name = "Kulisy"
	icon_state = "theatre_back"
	sound_environment = SOUND_AREA_WOODFLOOR

/area/crew_quarters/theatre/abandoned
	name = "Opuszczony Teatr"
	icon_state = "theatre"

/area/library
	name = "Biblioteka"
	icon_state = "library"
	flags_1 = NONE

	lighting_colour_tube = "#ffce99"
	lighting_colour_bulb = "#ffdbb4"
	lighting_brightness_tube = 8

/area/library/lounge
	name = "Salon biblioteczny"
	sound_environment = SOUND_AREA_LARGE_SOFTFLOOR
	icon_state = "library"

/area/library/abandoned
	name = "Opuszczona Biblioteka"
	icon_state = "library"
	flags_1 = NONE

/area/chapel
	icon_state = "Kaplica"
	ambience_index = AMBIENCE_HOLY
	flags_1 = NONE
	clockwork_warp_allowed = FALSE
	clockwork_warp_fail = "The consecration here prevents you from warping in."
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/chapel/main
	name = "Kaplica"

/area/chapel/main/monastery
	name = "Klasztor"

/area/chapel/office
	name = "Biuro Kaplicy"
	icon_state = "chapeloffice"

/area/chapel/asteroid
	name = "Kaplica Asteroidy"
	icon_state = "explored"
	sound_environment = SOUND_AREA_ASTEROID

/area/chapel/asteroid/monastery
	name = "Klasztor Asteroidy"

/area/chapel/dock
	name = "Dok Kaplicy"
	icon_state = "construction"

/area/lawoffice
	name = "Biuro Prawne"
	icon_state = "law"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR


//Engineering

/area/engine
	ambience_index = AMBIENCE_ENGI
	sound_environment = SOUND_AREA_LARGE_ENCLOSED
	lighting_colour_tube = "#ffce93"
	lighting_colour_bulb = "#ffbc6f"

/area/engine/engine_smes
	name = "Główna Rozdzielnia"
	icon_state = "engine_smes"

/area/engine/engineering
	name = "Inżynieria"
	icon_state = "engine"

/area/engineering/hallway
	name = "Korytarz Inżynieryjny"
	icon_state = "engine_hallway"

/area/engine/atmos
	name = "Atmosferyka"
	icon_state = "atmos"
	flags_1 = NONE

/area/engine/atmospherics_engine
	name = "Silnik Atmosferyczny"
	icon_state = "atmos_engine"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/engine/engine_room //donut station specific
	name = "Maszynownia"
	icon_state = "engine_sm"

/area/engine/engine_room/external
	name = "Dostęp Zewnętrzny Supermaterii"
	icon_state = "engine_foyer"

/area/engine/supermatter
	name = "Maszynownia Supermaterii"
	icon_state = "engine_sm_room"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/engine/break_room
	name = "Hol Inżynieryjny"
	icon_state = "engine_foyer"
	mood_bonus = 2
	mood_message = "<span class='nicegreen'>Ahhh, pora na odpoczynek.\n</span>"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/engine/gravity_generator
	name = "Pomieszczenie Generatora Grawitacyjnego"
	icon_state = "grav_gen"
	clockwork_warp_allowed = FALSE
	clockwork_warp_fail = "The gravitons generated here could throw off your warp's destination and possibly throw you into deep space."

/area/engine/storage
	name = "Magazyn Inżynieryjny"
	icon_state = "engine_storage"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/engine/storage_shared
	name = "Współdzielony Magazyn Inżynieryjny"
	icon_state = "engine_storage_shared"

/area/engine/transit_tube
	name = "Tuba Tranzytowa"
	icon_state = "transit_tube"


//Solars

/area/solar
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_IFSTARLIGHT
	area_flags = UNIQUE_AREA
	flags_1 = NONE
	ambience_index = AMBIENCE_ENGI
	sound_environment = SOUND_AREA_SPACE

/area/solar/fore
	name = "Panele Słoneczne Dzioba"
	icon_state = "yellow"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/solar/aft
	name = "Panele Słoneczne Rufy"
	icon_state = "yellow"

/area/solar/aux/port
	name = "Pomocnicze Panele Słoneczne Burty Dzioba"
	icon_state = "panelsA"

/area/solar/aux/starboard
	name = "Pomocnicze Panele Słoneczne Sterburty"
	icon_state = "panelsA"

/area/solar/starboard
	name = "Panele Słoneczne Sterburty"
	icon_state = "panelsS"

/area/solar/starboard/aft
	name = "Panele Słoneczne Bakburty Sterburty"
	icon_state = "panelsAS"

/area/solar/starboard/fore
	name = "Panele Słoneczne Sterburty Dzioba"
	icon_state = "panelsFS"

/area/solar/port
	name = "Panele Słoneczne Burty"
	icon_state = "panelsP"

/area/solar/port/aft
	name = "Panele Słoneczne Burty Bakburty"
	icon_state = "panelsAP"

/area/solar/port/fore
	name = "Panele Słoneczne Burty Dzioba"
	icon_state = "panelsFP"



//Solar Maint

/area/maintenance/solars
	name = "Tunel Konserwacyjny Paneli Słonecznych"
	icon_state = "yellow"

/area/maintenance/solars/port
	name = "Tunel Konserwacyjny Paneli Słonecznych Burty"
	icon_state = "SolarcontrolP"

/area/maintenance/solars/port/aft
	name = "Tunel Konserwacyjny Paneli Słonecznych Bakburty Burty"
	icon_state = "SolarcontrolAP"

/area/maintenance/solars/port/fore
	name = "Tunel Konserwacyjny Paneli Słonecznych Burty Dzioba"
	icon_state = "SolarcontrolFP"

/area/maintenance/solars/starboard
	name = "Tunel Konserwacyjny Paneli Słonecznych Sterburty"
	icon_state = "SolarcontrolS"

/area/maintenance/solars/starboard/aft
	name = "Tunel Konserwacyjny Paneli Słonecznych Bakburty Sterburty"
	icon_state = "SolarcontrolAS"

/area/maintenance/solars/starboard/fore
	name = "Tunel Konserwacyjny Paneli Słonecznych Sterburty Dzioba"
	icon_state = "SolarcontrolFS"

//Teleporter

/area/teleporter
	name = "Pomieszczenie z Teleportacją"
	icon_state = "teleporter"
	ambience_index = AMBIENCE_ENGI

/area/gateway
	name = "Brama"
	icon_state = "gateway"
	ambience_index = AMBIENCE_ENGI
	sound_environment = SOUND_AREA_STANDARD_STATION

//MedBay

/area/medical
	name = "Placówka Medyczna"
	icon_state = "medbay"
	ambience_index = AMBIENCE_MEDICAL
	sound_environment = SOUND_AREA_STANDARD_STATION
	mood_bonus = 2
	mood_message = "<span class='nicegreen'>Czuję się tutaj bezpieczny!\n</span>"
	lighting_colour_tube = "#e7f8ff"
	lighting_colour_bulb = "#d5f2ff"

/area/medical/medbay/zone2
	name = "Placówka Medyczna"
	icon_state = "medbay2"

/area/medical/abandoned
	name = "Opuszczona Placówka Medyczna"
	icon_state = "abandoned_medbay"
	ambientsounds = list('sound/ambience/signal.ogg')
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/medical/medbay/balcony
	name = "Balkon Placówki Medycznej"
	icon_state = "medbay"

/area/medical/medbay/central
	name = "Centrum Placówki Medycznej"
	icon_state = "med_central"

/area/medical/medbay/lobby
	name = "Izba Przujęć Placówki Medycznej"
	icon_state = "med_lobby"

	//Medbay is a large area, these additional areas help level out APC load.

/area/medical/medbay/aft
	name = "Rufa Placówki Medycznej"
	icon_state = "med_aft"

/area/medical/storage
	name = "Składownia Placówki Medycznej"
	icon_state = "med_storage"

/area/medical/office
	name = "Biuro Medyczne"
	icon_state = "med_office"

/area/medical/break_room
	name = "Pokój Wypoczynkowy Placówki Medycznej"
	icon_state = "med_break"

/area/medical/patients_rooms
	name = "Pokój Pacjentów"
	icon_state = "patients"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/medical/patients_rooms/room_a
	name = "Pokój Pacjenta A"
	icon_state = "patients"

/area/medical/patients_rooms/room_b
	name = "Pokój Pacjenta B"
	icon_state = "patients"

/area/medical/patients_rooms/room_c
	name = "Pokój Pacjenta C"
	icon_state = "patients"

/area/medical/virology
	name = "Wirusologia"
	icon_state = "virology"
	flags_1 = NONE

/area/medical/morgue
	name = "Kostnica"
	icon_state = "morgue"
	ambience_index = AMBIENCE_SPOOKY
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	mood_bonus = -2
	mood_message = "<span class='warning'>Cuchnie tu śmiercią!\n</span>"

/area/medical/chemistry
	name = "Pracownia Chemiczna"
	icon_state = "chem"

/area/medical/chemistry/upper
	name = "Górna Pracownia Chemiczna"
	icon_state = "chem"

/area/medical/apothecary
	name = "Apteka"
	icon_state = "apothecary"

/area/medical/surgery
	name = "Chirurgia"
	icon_state = "surgery"

/area/medical/surgery/aux
	name = "Poczekalnia Chirurgi"
	icon_state = "surgery"

/area/medical/cryo
	name = "Kriogenika"
	icon_state = "cryo"

/area/medical/exam_room
	name = "Gabinet Badawczy"
	icon_state = "exam_room"

/area/medical/genetics
	name = "Laboratorium Genetyczne"
	icon_state = "genetics"

/area/medical/genetics/cloning
	name = "Laboratorium Klonowania"
	icon_state = "cloning"

/area/medical/sleeper
	name = "Centrum Leczenia Szpitalnego"
	icon_state = "exam_room"


//Security

/area/security
	name = "Ochrona"
	icon_state = "security"
	ambience_index = AMBIENCE_DANGER
	sound_environment = SOUND_AREA_STANDARD_STATION
	lighting_colour_tube = "#ffeee2"
	lighting_colour_bulb = "#ffdfca"

/area/security/main
	name = "Biuro Ochrony"
	icon_state = "security"

/area/security/brig
	name = "Bryg"
	icon_state = "brig"
	mood_bonus = -3
	mood_job_allowed = list(JOB_NAME_HEADOFSECURITY,JOB_NAME_WARDEN,JOB_NAME_SECURITYOFFICER,JOB_NAME_BRIGPHYSICIAN,JOB_NAME_DETECTIVE)
	mood_job_reverse = TRUE

	mood_message = "<span class='warning'>Nienawidze ciasnych cel.\n</span>"

/area/security/courtroom
	name = "Sala Sądowa"
	icon_state = "courtroom"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/security/prison
	name = "Skrzydło Więzienne"
	icon_state = "sec_prison"
	mood_bonus = -4
	mood_job_allowed = list(JOB_NAME_HEADOFSECURITY,JOB_NAME_WARDEN, JOB_NAME_SECURITYOFFICER)  // JUSTICE!
	mood_job_reverse = TRUE
	mood_message = "<span class='warning'>Jestem tutaj uwięziony z nikłymi szansami na ucieczke!\n</span>"

/area/security/processing
	name = "Dok Wahadłowca Pracy"
	icon_state = "sec_prison"

/area/security/processing/cremation
	name = "Krematorium Ochrony"
	icon_state = "sec_prison"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/security/warden
	name = "Kontrola Brygu"
	icon_state = "Warden"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/security/detectives_office
	name = "Biuro Detektywa"
	icon_state = "detective"
	ambientsounds = list('sound/ambience/ambidet1.ogg','sound/ambience/ambidet2.ogg','sound/ambience/ambidet3.ogg','sound/ambience/ambidet4.ogg')

/area/security/detectives_office/private_investigators_office
	name = "Biuro Prywatnego Detektywa"
	icon_state = "detective"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/security/range
	name = "Strzelnica"
	icon_state = "firingrange"

/area/security/execution
	icon_state = "execution_room"
	mood_bonus = -5
	mood_message = "<span class='warning'>Czuję nadciągającą zagłade.\n</span>"

/area/security/execution/transfer
	name = "Centrum Transferowe"

/area/security/execution/education
	name = "Izba Edukacji Więźniów"

/area/security/nuke_storage
	name = "Skarbiec"
	icon_state = "nuke_storage"

/area/ai_monitored/nuke_storage
	name = "Skarbiec"
	icon_state = "nuke_storage"

/area/security/checkpoint
	name = "Punkt Kontroli Bezpieczeństwa"
	icon_state = "checkpoint"

/area/security/checkpoint/auxiliary
	icon_state = "checkpoint_aux"

/area/security/checkpoint/escape
	icon_state = "checkpoint_esc"

/area/security/checkpoint/supply
	name = "Posterunek Ochrony - Zaopatrzeń"
	icon_state = "checkpoint_supp"

/area/security/checkpoint/engineering
	name = "Posterunek Ochrony - Inżynieria"
	icon_state = "checkpoint_engi"

/area/security/checkpoint/medical
	name = "Posterunek Ochrony - Placówka Medyczna"
	icon_state = "checkpoint_med"

/area/security/checkpoint/science
	name = "Posterunek Ochrony - Naukowy"
	icon_state = "checkpoint_sci"

/area/security/checkpoint/science/research
	name = "Posterunek Ochrony - Departament Naukowy"
	icon_state = "checkpoint_res"

/area/security/checkpoint/customs
	name = "Odprawa Celna"
	icon_state = "customs_point"

/area/security/checkpoint/customs/auxiliary
	icon_state = "customs_point_aux"

/area/security/prison/vip
	name = "Skrzydło Więzienne VIP"
	icon_state = "sec_prison"

/area/security/prison/asteroid
	name = "Zewnętrzne Skrzydło Więzienne Asteroidy"
	icon_state = "sec_prison"

/area/security/prison/asteroid/service
	name = "Usługi Skrzydła Więziennego Zewnętrznej Asteroidy"
	icon_state = "sec_prison"

/area/security/prison/asteroid/arrival
	name = "Przyloty Skrzydła Więziennego Zewnętrznej Asteroidy"
	icon_state = "sec_prison"

/area/security/prison/asteroid/abbandoned
	name = "Tunele Konserwacyjne Skrzydła Więziennego Zewnętrznej Opuszczonej Asteroidy"
	icon_state = "sec_prison"
	mood_bonus = -2
	mood_message = "<span class='warning'>to miejsce daje mi dreszcze...\n</span>"

/area/security/prison/asteroid/shielded
	name = "Osłonięte Zewnętrzne Skrzydło Więzienne Asteroidy"
	icon_state = "sec_prison"

//Cargo

/area/quartermaster
	name = "Kwatermisztrz"
	icon_state = "quart"
	lighting_colour_tube = "#ffe3cc"
	lighting_colour_bulb = "#ffdbb8"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/quartermaster/sorting
	name = "Biuro Dostaw"
	icon_state = "cargo_delivery"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/quartermaster/warehouse
	name = "Magazyn"
	icon_state = "cargo_warehouse"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/quartermaster/office
	name = "Biuro Zapoatrzeń"
	icon_state = "cargo_office"

/area/quartermaster/storage
	name = "Zatoka Ładunkowa"
	icon_state = "cargo_bay"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/cargo/lobby
	name = "\improper Lobby Zapoatrzeń"
	icon_state = "cargo_lobby"

/area/quartermaster/qm
	name = "Biuro Kwatermisztrza"
	icon_state = "quart_office"

/area/quartermaster/qm_bedroom
	name = "Kwatera Kwatermisztrza"
	icon_state = "quart_private"

/area/quartermaster/miningdock
	name = "Dok Górniczy"
	icon_state = "mining_dock"

/area/quartermaster/miningoffice
	name = "Biuro Górnicze"
	icon_state = "mining"

/area/quartermaster/meeting_room
	name = "Sala Spotkań Zaopatrzeń"
	icon_state = "quart_perch"

/area/quartermaster/exploration_prep
	name = "Pokój Przygotowania Eksploracji"
	icon_state = "mining"

/area/quartermaster/exploration_dock
	name = "Dok Dksploracyjny"
	icon_state = "mining"

//Service

/area/janitor
	name = "Pomieszczenie Dla Służb Porządkowych"
	icon_state = "janitor"
	flags_1 = NONE
	mood_bonus = -1
	mood_message = "<span class='warning'>Czuje się tu brudno!\n</span>"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/hydroponics
	name = "Hydroponika"
	icon_state = "hydro"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/hydroponics/garden
	name = "Ogród"
	icon_state = "garden"
	mood_bonus = 2
	mood_message = "<span class='nicegreen'>Jest tu tak spokojnie!\n</span>"

/area/hydroponics/garden/abandoned
	name = "Opuszczony Ogród"
	icon_state = "abandoned_garden"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/hydroponics/garden/monastery
	name = "Ogród Klasztoru"
	icon_state = "hydro"


//Science

/area/science
	name = "Wydział Badawczy"
	icon_state = "science"
	lighting_colour_tube = "#f0fbff"
	lighting_colour_bulb = "#e4f7ff"
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/science/lobby
	name = "\improper Lobby Wydziału Badawczego"
	icon_state = "science_lobby"

/area/science/breakroom
	name = "\improper Pokój Wypoczynkowy Wydziału Badawczego"
	icon_state = "science_breakroom"

/area/science/lab
	name = "Badania i Rozwój"
	icon_state = "research"

/area/science/xenobiology
	name = "Laboratorium Ksenobiologii"
	icon_state = "xenobio"

/area/science/shuttle
	name = "Budowa Wahadłowca"
	lighting_colour_tube = "#ffe3cc"
	lighting_colour_bulb = "#ffdbb8"

/area/science/storage
	name = "Magazyn Toksyn"
	icon_state = "tox_storage"

/area/science/test_area
	name = "Obszar Testów Toksyn"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA
	icon_state = "tox_test"

/area/science/mixing
	name = "Laboratorium Mieszania Toksyn"
	icon_state = "tox_mix"

/area/science/mixing/chamber
	name = "Komora Mieszania Toksyn"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA
	icon_state = "tox_mix_chamber"

/area/science/misc_lab
	name = "Laboratorium Testowe"
	icon_state = "tox_misc"

/area/science/misc_lab/range
	name = "Obszar Testów Badawczych"
	icon_state = "tox_range"

/area/science/server
	name = "Serwerownia Wydziału Naukowego"
	icon_state = "server"

/area/science/explab
	name = "Laboratorium do Eksperymentów"
	icon_state = "exp_lab"

/area/science/robotics
	name = "Robotyka"
	icon_state = "robotics"

/area/science/robotics/mechbay
	name = "Warsztat Mechów"
	icon_state = "mechbay"

/area/science/robotics/lab
	name = "Laboratorium Robotyki"
	icon_state = "ass_line"

/area/science/research
	name = "Wydział Badawczy"
	icon_state = "science"

/area/science/research/abandoned
	name = "Opuszczone Laboratorium Robotyki"
	icon_state = "abandoned_sci"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/science/nanite
	name = "Laboratorium Nanitów"
	icon_state = "nanite_lab"

/area/science/shuttledock
	name = "Dok Wahadłowca Naukowego"
	icon_state = "sci_dock"

//Storage
/area/storage
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/storage/tools
	name = "Pomocniczy Magazyn z Narzędziami"
	icon_state = "tool_storage"

/area/storage/primary
	name = "Główny Magazyn Narzędziowy"
	icon_state = "primarystorage"

/area/storage/art
	name = "Magazyn Materiałów Plastycznych"
	icon_state = "art_storage"

/area/storage/tcom
	name = "Magazyn Telekomunikacji"
	area_flags = BLOBS_ALLOWED | UNIQUE_AREA
	icon_state = "green"

/area/storage/eva
	name = "Magazyn EVA"
	icon_state = "eva"
	clockwork_warp_allowed = FALSE

/area/storage/emergency/starboard
	name = "Awaryjny Magazyn Sterburty"
	icon_state = "emergencystorage"

/area/storage/emergency/port
	name = "Awaryjny Magazyn Burty"
	icon_state = "emergencystorage"

/area/storage/tech
	name = "Magazyn Techniczny"
	icon_state = "tech_storage"

//Construction

/area/construction
	name = "Plac Budowy"
	icon_state = "yellow"
	ambience_index = AMBIENCE_ENGI
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/construction/mining/aux_base
	name = "Konstrukcja Bazy Pomocniczej"
	icon_state = "aux_base_construction"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR

/area/construction/storage_wing
	name = "Skrzydło Magazynowe"
	icon_state = "storage_wing"

// Vacant Rooms
/area/vacant_room
	name = "Pusty Pokój"
	icon_state = "yellow"
	ambience_index = AMBIENCE_MAINT
	icon_state = "vacant_room"

/area/vacant_room/office
	name = "Puste Biuro"
	icon_state = "vacant_office"

/area/vacant_room/commissary
	name = "Pusty Sklepik Komisaryjny"
	icon_state = "vacant_commissary"

/area/vacant_room/commissary/commissary1
	name = "Pusty Sklepik Komisaryjny #1"
	icon_state = "vacant_commissary"

/area/vacant_room/commissary/commissary2
	name = "Pusty Sklepik Komisaryjny #2"
	icon_state = "vacant_commissary"

/area/vacant_room/commissary/commissaryFood
	name = "Pusty Sklepik Komisaryjny"
	icon_state = "vacant_commissary"

/area/vacant_room/commissary/commissaryRandom
	name = "Osobliwy Sklepik Komisaryjny"
	icon_state = "vacant_commissary"

//AI

/area/ai_monitored
	sound_environment = SOUND_AREA_STANDARD_STATION

/area/ai_monitored/security/armory
	name = "Zbrojownia"
	icon_state = "armory"
	ambience_index = AMBIENCE_DANGER
	mood_job_allowed = list(JOB_NAME_WARDEN)
	mood_bonus = 1
	mood_message = "<span class='nicegreen'>Dobrze być w domu.</span>"

/area/ai_monitored/storage/eva
	name = "Magazyn EVA"
	icon_state = "eva"
	ambience_index = AMBIENCE_DANGER

/area/ai_monitored/storage/satellite
	name = "Tunel Konserwacyjny Satelity SI"
	icon_state = "storage"
	ambience_index = AMBIENCE_DANGER

	//Turret_protected

/area/ai_monitored/turret_protected
	ambientsounds = list('sound/ambience/ambimalf.ogg', 'sound/ambience/ambitech.ogg', 'sound/ambience/ambitech2.ogg', 'sound/ambience/ambiatmos.ogg', 'sound/ambience/ambiatmos2.ogg')

/area/ai_monitored/turret_protected/ai_upload
	name = "Komora Programowania SI"
	icon_state = "ai_upload"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	mood_job_allowed = list(JOB_NAME_RESEARCHDIRECTOR, JOB_NAME_CAPTAIN)
	mood_bonus = 4
	mood_message = "<span class='nicegreen'>SI ulegnie mej woli!\n</span>"

/area/ai_monitored/turret_protected/ai_upload_foyer
	name = "Przedsionek Komory Programowania SI"
	icon_state = "ai_upload_foyer"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/area/ai_monitored/turret_protected/ai
	name = "Komora SI"
	icon_state = "ai_chamber"

/area/ai_monitored/turret_protected/aisat
	name = "Satelita SI"
	icon_state = "ai"
	sound_environment = SOUND_ENVIRONMENT_ROOM

/area/ai_monitored/turret_protected/aisat/atmos
	name = "Atmosferyka Satelity SI"
	icon_state = "ai"

/area/ai_monitored/turret_protected/aisat/foyer
	name = "Przedsionek Satelity SI"
	icon_state = "ai_foyer"

/area/ai_monitored/turret_protected/aisat/service
	name = "Usłógi Satelity SI"
	icon_state = "ai"

/area/ai_monitored/turret_protected/aisat/hallway
	name = "Korytarz Satelity SI"
	icon_state = "ai"

/area/aisat
	name = "Zewnętrze Satelity SI"
	icon_state = "yellow"

/area/ai_monitored/turret_protected/aisat/maint
	name = "Tunele Konserwacyjne Satelity SI"
	icon_state = "ai_maint"

/area/ai_monitored/turret_protected/aisat_interior
	name = "Przedpokój Satelity SI"
	icon_state = "ai_interior"
	sound_environment = SOUND_AREA_LARGE_ENCLOSED

/area/ai_monitored/turret_protected/AIsatextAS
	name = "Wschodnie Zewnętrzne Obszaru Satelity SI"
	icon_state = "ai_sat_east"

/area/ai_monitored/turret_protected/AIsatextAP
	name = "Zachodnie Zewnętrzne Obszaru Satelity SI"
	icon_state = "ai_sat_west"


// Telecommunications Satellite

/area/tcommsat
	clockwork_warp_allowed = FALSE
	clockwork_warp_fail = "For safety reasons, warping here is disallowed; the radio and bluespace noise could cause catastrophic results."
	ambientsounds = list('sound/ambience/ambisin2.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/ambigen10.ogg', 'sound/ambience/ambitech.ogg',\
											'sound/ambience/ambitech2.ogg', 'sound/ambience/ambitech3.ogg', 'sound/ambience/ambimystery.ogg')
	network_root_id = STATION_NETWORK_ROOT	// They should of unpluged the router before they left

/area/tcommsat/computer
	name = "Centrum Kontroli Telekomunikacji"
	icon_state = "tcom_sat_comp"
	sound_environment = SOUND_AREA_MEDIUM_SOFTFLOOR
	mood_job_allowed = list(JOB_NAME_CHIEFENGINEER, JOB_NAME_STATIONENGINEER)
	mood_bonus = 2
	mood_message = "<span class='nicegreen'>Jak dobrze widzieć że to jest sprawne.\n</span>"

/area/tcommsat/server
	name = "Serwerownia Telekomunikacji"
	icon_state = "tcom_sat_cham"

/area/tcommsat/relay
	name = "Przekaźnik Telekomunikacji"
	icon_state = "tcom_sat_cham"
