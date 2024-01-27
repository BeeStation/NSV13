/client/var/last_ambience = null
//AQUILA EDIT entire names and mood messages translated into polish
/area
	ambient_buzz = 'nsv13/sound/ambience/shipambience.ogg' //If you want an ambient sound to play on loop while theyre in a specific area, set this. Defaults to the classic "engine rumble"

/area/space
	ambient_buzz = null

/area/space/instanced
	area_flags = HIDDEN_AREA

/area/maintenance
	ambient_buzz = 'nsv13/sound/ambience/maintenance.ogg'
	ambientsounds = list('nsv13/sound/ambience/leit_motif.ogg','nsv13/sound/ambience/wind.ogg','nsv13/sound/ambience/wind2.ogg','nsv13/sound/ambience/wind3.ogg','nsv13/sound/ambience/wind4.ogg','nsv13/sound/ambience/wind5.ogg','nsv13/sound/ambience/wind6.ogg')

/area/medical
	ambient_buzz = 'nsv13/sound/ambience/medbay.ogg'
	ambientsounds = list()

/area/ai_monitored
	ambient_buzz = 'nsv13/sound/ambience/computer_core.ogg'
	ambientsounds = list()

/area/bridge
	ambient_buzz = 'nsv13/sound/ambience/bridge.ogg'
	ambientsounds = list()

/area/science
	ambient_buzz = 'nsv13/sound/ambience/computer_core.ogg'
	ambientsounds = list()

/area/crew_quarters/dorms/nsv/dorms_1
	name = "Drugi Pokład Kwatery Dzioba"
	icon_state = "Sleep"
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED

/area/crew_quarters/dorms/nsv/dorms_2
	name = "Drugi Pokład Kwatery Rufy"
	icon_state = "Sleep"
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED

/area/crew_quarters/dorms/nsv/state_room
	name = "Kabina Korporacyjna"
	icon_state = "Sleep"

/area/crew_quarters/dorms/nsv/nature_deck
	name = "Pokład z Naturą"
	icon_state = "hydro"
	mood_bonus = 3
	mood_message = "<span class='nicegreen'>Jest tutaj pięknie!\n</span>"

/area/medical/nsv/clinic
	name = "Drugi Pokład Klinika Medyczna"
	icon_state = "medbay"

/area/medical/nsv/psychology
	name = "Gabinet Psychologa"
	icon_state = "medbay"

/area/medical/nsv/trauma
	name = "Ośrodek Leczenia Traumy"
	icon_state = "medbay"

/area/medical/nsv/plumbing
	name = "Produkcja Chemiczna"
	icon_state = "chem"

/area/science/nsv/astronomy
	name = "Laboratorium Astrometryczne"
	icon_state = "astrometrics"

/area/nsv/engine/corridor
	name = "Korytarz Inżynieryjny"
	icon_state = "aux_base_construction"

/area/nsv/engine/engine_room/core
	name = "Maszynownia"
	icon_state = "engine_core"

/area/nsv/engine/engine_room/auxiliary
	name = "Wyposażenie Pomocnicze Silnika"
	icon_state = "engine_foyer"

/area/engine/atmos/port_atmos
	name = "Burta Atmosferyka"
	icon_state = "atmos"

/area/engine/atmos/starboard_atmos
	name = "Sterburta Atmosferyka"
	icon_state = "atmos"

/area/maintenance/nsv/ftlroom
	name = "Pokój Kontroli Napędu Nadświetlnego"
	icon_state = "ftl_room"

/area/maintenance/nsv/turbolift/abandonedshaft
	name = "Opuszczony Szyb Windy"
	icon_state = "maint_bridge"

/area/maintenance/nsv/deck1/airlock/forward/port
	name = "Pierwszy Pokład Burta Przednie Śluzy"
	icon_state = "maint_bridge"

/area/maintenance/nsv/deck1/airlock/forward/starboard
	name = "Pierwszy Pokład Sterburta Przednie Śluzy"
	icon_state = "maint_bridge"

/area/maintenance/nsv/deck1/airlock/aft/port
	name = "Pierwszy Pokład Burta Bakburta Śluzy"
	icon_state = "maint_bridge"

/area/maintenance/nsv/deck1/airlock/aft/starboard
	name = "Pierwszy Pokład Sterburta Bakburta Śluzy"
	icon_state = "maint_bridge"

/area/maintenance/nsv/deck1/port
	name = "Pierwszy Pokład Burta Tunel Techniczny"
	icon_state = "pmaint"

/area/maintenance/nsv/deck1/central
	name = "Pierwszy Pokład Centralny Tunel Techniczny"
	icon_state = "maintcentral"

/area/maintenance/nsv/deck1/starboard
	name = "Pierwszy Pokład Sterburta Tunel Techniczny"
	icon_state = "smaint"

/area/maintenance/nsv/deck1/starboard/aft
	name = "Pierwszy Pokład Sterburta Bakburta Tunel Techniczny"
	icon_state = "smaint"

/area/maintenance/nsv/deck1/starboard/fore
	name = "Pierwszy Pokład Sterburta Dziób Tunel Techniczny"

/area/maintenance/nsv/deck1/aft
	name = "Pierwszy Pokład Aft Tunel Techniczny"
	icon_state = "amaint"

/area/maintenance/nsv/deck1/port/aft
	name = "Pierwszy Pokład Burta Bakburta Tunel Techniczny"
	icon_state = "pmaint"

/area/maintenance/nsv/deck1/port/fore
	name = "Pierwszy Pokład Burta Dzioba Tunel Techniczny"
	icon_state = "pmaint"

/area/maintenance/nsv/deck2/port
	name = "Drugi Pokład Tunel Techniczny"
	icon_state = "pmaint"

/area/maintenance/nsv/deck2/starboard
	name = "Drugi Pokład Sterburta Tunel Techniczny"
	icon_state = "smaint"

/area/maintenance/nsv/deck2/airlock/forward/port
	name = "Drugi Pokład Burta Przednie Śluzy"
	icon_state = "maint_bridge"

/area/maintenance/nsv/deck2/airlock/forward/starboard
	name = "Drugi Pokład Sterburta Przednie Śluzy"
	icon_state = "maint_bridge"

/area/maintenance/nsv/deck2/airlock/aft/port
	name = "Drugi Pokład Burta Bakburta Śluzy"
	icon_state = "maint_bridge"

/area/maintenance/nsv/deck2/airlock/aft/starboard
	name = "Drugi Pokład Sterburta Bakburta Śluzy"
	icon_state = "maint_bridge"

/area/maintenance/nsv/deck2/frame1/port
	name = "Drugi Pokład Pierwsza Rama Dziób Tunel Techniczny"
	icon_state = "pmaint"

/area/maintenance/nsv/deck2/frame1/starboard
	name = "Drugi Pokład Pierwsza Rama Sterburta Tunel Techniczny"
	icon_state = "smaint"

/area/maintenance/nsv/deck2/frame1/central
	name = "Drugi Pokład Pierwsza Rama Centralny Tunel Techniczny"
	icon_state = "maintcentral"

/area/maintenance/nsv/deck2/frame2/port
	name = "Drugi Pokład Druga Rama Tunel Techniczny"
	icon_state = "pmaint"

/area/maintenance/nsv/deck2/frame2/starboard
	name = "Drugi Pokład Druga Rama Sterburta Tunel Techniczny"
	icon_state = "smaint"

/area/maintenance/nsv/deck2/frame2/central
	name = "Drugi Pokład Druga Rama Centralny Tunel Techniczny"
	icon_state = "maintcentral"

/area/maintenance/nsv/deck2/frame3/port
	name = "Drugi Pokład Trzecia Rama Dziób Tunel Techniczny"
	icon_state = "pmaint"

/area/maintenance/nsv/deck2/frame3/starboard
	name = "Drugi Pokład Trzecia Rama Sterburta Tunel Techniczny"
	icon_state = "smaint"

/area/maintenance/nsv/deck2/frame3/central
	name = "Drugi Pokład Trzecia Rama Centralny Tunel Techniczny"
	icon_state = "maintcentral"

/area/maintenance/nsv/deck2/frame4/port
	name = "Drugi Pokład Czwarta Rama Tunel Techniczny"
	icon_state = "pmaint"

/area/maintenance/nsv/deck2/frame4/starboard
	name = "Drugi Pokład Czwarta Rama Sterburta Tunel Techniczny"
	icon_state = "smaint"

/area/maintenance/nsv/deck2/frame4/central
	name = "Drugi Pokład Czwarta Rama Centralny Tunel Techniczny"
	icon_state = "maintcentral"

/area/maintenance/nsv/deck2/frame5/port
	name = "Drugi Pokład Piąta Rama Burta Tunel Techniczny"
	icon_state = "pmaint"

/area/maintenance/nsv/deck2/frame5/starboard
	name = "Drugi Pokład Piąta Rama Sterburta Tunel Techniczny"
	icon_state = "smaint"

/area/maintenance/nsv/deck2/frame5/central
	name = "Drugi Pokład Piąta Rama Centralny Tunel Techniczny"
	icon_state = "maintcentral"

/area/maintenance/nsv/deck3/frame1/port
	name = "Trzeci Pokład Pierwsza Rama Burta Tunel Techniczny"
	icon_state = "pmaint"

/area/maintenance/nsv/deck3/frame1/starboard
	name = "Trzeci Pokład Pierwsza Rama Sterburta Tunel Techniczny"
	icon_state = "smaint"

/area/maintenance/nsv/deck3/frame2/port
	name = "Trzeci Pokład Druga Rama Burta Tunel Techniczny"
	icon_state = "pmaint"

/area/maintenance/nsv/deck3/frame2/starboard
	name = "Trzeci Pokład Druga Rama Sterburta Tunel Techniczny"
	icon_state = "smaint"

/area/maintenance/nsv/deck3/frame3/port
	name = "Trzeci Pokład Trzecia Rama Burta Dziób Tunel Techniczny"
	icon_state = "pmaint"

/area/maintenance/nsv/deck3/frame3/starboard
	name = "Trzeci Pokład Trzecia Rama Sterburta Tunel Techniczny"
	icon_state = "smaint"

/area/maintenance/nsv/deck3/frame3/central
	name = "Trzeci Pokład Trzecia Rama Centralny Tunel Techniczny"
	icon_state = "maintcentral"

/area/maintenance/nsv/deck3/frame4/central
	name = "Trzeci Pokład Czwarta Rama Centralny Tunel Techniczny"
	icon_state = "maintcentral"

/area/maintenance/nsv/bridge
	name = "Tunel Techniczny Dziobu Mostka"
	icon_state = "maint_bridge"

/area/maintenance/nsv/deck2/starboard/fore
	name = "Drugi Pokład Sterburta Dziób Tunel Techniczny"
	icon_state = "smaint"

/area/maintenance/nsv/deck2/starboard/aft
	name = "Drugi Pokład Sterburta Bakburta Tunel Techniczny"
	icon_state = "amaint"

/area/maintenance/nsv/deck2/port/fore
	name = "Drugi Pokład Burta Dzioba Tunel Techniczny"
	icon_state = "pmaint"

/area/maintenance/nsv/deck2/port/aft
	name = "Drugi Pokład Burta Bakburta Tunel Techniczny"
	icon_state = "amaint"

/area/maintenance/nsv/weapons
	name = "Tunel Techniczny Komory Uzbrojenia"
	icon_state = "amaint"

/area/maintenance/nsv/hangar
	name = "Tunel Techniczny Hangaru"
	icon_state = "amaint"

/area/maintenance/nsv/port_substation
	name = "Podstacja Burty"
	icon_state = "amaint"

/area/maintenance/nsv/central_substation
	name = "Centralna Podstacja"
	icon_state = "amaint"

/area/maintenance/nsv/starboard_substation
	name = "Sterburta Podstacja"
	icon_state = "amaint"

/area/hallway/nsv/deck2/forward
	name = "Drugi Pokład Dziób Korytarz"
	icon_state = "hallF"

/area/hallway/nsv/deck2/primary
	name = "Drugi Pokład Główny Korytarz"
	icon_state = "hallP"

/area/hallway/nsv/deck1/aft
	name = "Pierwszy Pokład Rufa Korytarz"
	icon_state = "hallP"

/area/hallway/nsv/deck2/aft
	name = "Drugi Pokład Rufa Korytarz"
	icon_state = "hallP"

/area/maintenance/nsv/mining_ship
	has_gravity = TRUE
	ambient_buzz = 'nsv13/sound/ambience/maintenance.ogg'

/area/maintenance/nsv/mining_ship/central
	name = "Tunele Techniczne Rocinante"
	icon_state = "maintcentral"

/area/maintenance/nsv/mining_ship/forward
	name = "Tunele Techniczne Dziobu Rocinante"
	icon_state = "maintcentral"

/area/maintenance/nsv/mining_ship/aft
	name = "Tunele Techinczne Rufy Rocinante"
	icon_state = "maintcentral"

/area/hallway/nsv/deck2/frame1/port
	name = "Drugi Pokład Pierwsza Rama Burta Korytarz"
	icon_state = "hallF"

/area/hallway/nsv/deck2/frame1/central
	name = "Drugi Pokład Pierwsza Rama Centralny Korytarz"
	icon_state = "hallC"

/area/hallway/nsv/deck2/frame1/starboard
	name = "Drugi Pokład Pierwsza Rama Sterburta Korytarz"
	icon_state = "hallF"

/area/hallway/nsv/deck2/frame2/port
	name = "Drugi Pokład Druga Rama Burta Korytarz"
	icon_state = "hallP"

/area/hallway/nsv/deck2/frame2/central
	name = "Drugi Pokład Druga Rama Centralny Korytarz"
	icon_state = "hallC"

/area/hallway/nsv/deck2/frame2/starboard
	name = "Drugi Pokład Druga Rama Sterburta Korytarz"
	icon_state = "hallS"

/area/hallway/nsv/deck2/frame3/port
	name = "Drugi Pokład Trzecia Rama Burta Korytarz"
	icon_state = "hallC"

/area/hallway/nsv/deck2/frame3/central
	name = "Drugi Pokład Trzecia Rama Centralny Korytarz"
	icon_state = "hallC"

/area/hallway/nsv/deck2/frame3/starboard
	name = "Drugi Pokład Trzecia Rama Sterburta Korytarz"
	icon_state = "hallC"

/area/hallway/nsv/deck2/frame4/port
	name = "Drugi Pokład Czwarta Rama Burta Korytarz"
	icon_state = "hallP"

/area/hallway/nsv/deck2/frame4/starboard
	name = "Drugi Pokład Czwarta Rama Sterburta Korytarz"
	icon_state = "hallS"

/area/hallway/nsv/deck2/frame4/central
	name = "Drugi Pokład Czwarta Rama Centralny Korytarz"
	icon_state = "hallC"

/area/hallway/nsv/deck2/frame5/port
	name = "Drugi Pokład Piąta Rama Burta Korytarz"
	icon_state = "hallP"

/area/hallway/nsv/deck2/frame5/starboard
	name = "Drugi Pokład Piąta Rama Sterburta Korytarz"
	icon_state = "hallS"

/area/hallway/nsv/deck2/frame5/central
	name = "Drugi Pokład Piąta Rama Centralny Korytarz"
	icon_state = "hallC"

/area/hallway/nsv/deck3/frame1/port
	name = "Trzeci Pokład Pierwsza Rama Burta Korytarz"
	icon_state = "hallP"

/area/hallway/nsv/deck3/frame1/starboard
	name = "Trzeci Pokład Pierwsza Rama Sterburta Korytarz"
	icon_state = "hallS"

/area/hallway/nsv/deck3/frame1/central
	name = "Trzeci Pokład Pierwsza Rama Centralny Korytarz"
	icon_state = "hallC"

/area/hallway/nsv/deck3/frame2/central
	name = "Drugi Pokład Druga Rama Centralny Korytarz"
	icon_state = "hallC"

/area/hallway/nsv/deck3/frame2/port
	name = "Drugi Pokład Druga Rama Burta Korytarz"
	icon_state = "hallP"

/area/hallway/nsv/deck3/frame2/starboard
	name = "Drugi Pokład Druga Rama Sterburta Korytarz"
	icon_state = "hallS"

/area/hallway/nsv/deck3/frame3/port
	name = "Trzeci Pokład Trzecia Rama Burta Korytarz"
	icon_state = "hallP"

/area/hallway/nsv/deck3/frame3/starboard
	name = "Trzeci Pokład Trzecia Rama Sterburta Korytarz"
	icon_state = "hallS"

/area/hallway/nsv/deck3/frame3/central
	name = "Trzeci Pokład Trzecia Rama Centralny Korytarz"
	icon_state = "hallC"

/area/hallway/nsv/deck3/frame4/central
	name = "Trzeci Pokład Czwarta Rama Centralny Korytarz"
	icon_state = "hallC"

/area/hallway/nsv/deck3/frame4/port
	name = "Trzeci Pokład Czwarta Rama Burta Korytarz"
	icon_state = "hallP"

/area/hallway/nsv/deck3/frame4/starboard
	name = "Trzeci Pokład Czwarta Rama Sterburta Korytarz"
	icon_state = "hallS"

/area/hallway/nsv/stairwell/lower
	name = "Dolne Schody"
	icon_state = "hallS"

/area/hallway/nsv/stairwell/upper
	name = "Górne Schody"
	icon_state = "hallS"

/area/hallway/nsv/deck1/hallway
	name = "Pierwszy Pokład Główny Korytarz"
	icon_state = "hallC"

/area/hallway/nsv/deck1/frame1/central
	name = "Pierwszy Pokład Pierwsza Rama Centralny Korytarz"
	icon_state = "hallC"

/area/hallway/nsv/deck1/frame1/starboard
	name = "Pierwszy Pokład Pierwsza Rama Sterburta Korytarz"
	icon_state = "hallS"

/area/hallway/nsv/deck1/frame2/port
	name = "Pierwszy Pokład Druga Rama Burta Korytarz"
	icon_state = "hallP"

/area/hallway/nsv/deck1/frame2/central
	name = "Pierwszy Pokład Druga Rama Centralny Korytarz"
	icon_state = "hallC"

/area/hallway/nsv/deck1/frame2/starboard
	name = "Pierwszy Pokład Druga Rama Sterburta Korytarz"
	icon_state = "hallS"

/area/hallway/nsv/deck1/frame3/central
	name = "Pierwszy Pokład Trzecia Rama Centralny Korytarz"
	icon_state = "hallC"

/area/hallway/nsv/deck1/frame4/central
	name = "Pierwszy Pokład Czwarta Rama Centralny Korytarz"
	icon_state = "hallC"

/area/crew_quarters/nsv/observation
	name = "Hol Obserwacyjny"
	icon_state = "Sleep"

/area/crew_quarters/nsv/officerquarters
	name = "Kwatery Oficerów Pokładowych"
	icon_state = "Sleep"

/area/nsv/hanger/deck3/starboard
	name = "Trzeci Pokład Sterburta Hangar"
	icon_state = "hallS"

/area/nsv/hanger/notkmcstupidhanger/launchtube/left
	name = "Wyrzutnie 1 & 2"
	icon_state = "hallP"

/area/nsv/hanger/notkmcstupidhanger/launchtube/right
	name = "Wyrzutnie 3 & 4"
	icon_state = "hallS"

/area/nsv/hanger/notkmcstupidhanger/launchtube/left/airlock
	name = "Hangar Śluza 1"

/area/nsv/hanger/notkmcstupidhanger/launchtube/right/airlock
	name = "Hangar Śluza 2"

/area/nsv/hanger/notkmcstupidhanger/hangar
	name = "Hangar"
	icon_state = "hallC"

/area/nsv/hanger/notkmcstupidhanger/pilot
	name = "Hol Pilotów"
	icon_state = "shuttlered"

/area/nsv/hanger/notkmcstupidhanger/atc
	name = "Kontrola Lotów"
	icon_state = "shuttlered"

/area/nsv/hanger/deck2/port
	name = "Drugi Pokład Burta Hanger"
	icon_state = "hallP"

/area/nsv/hanger/deck2/starboard
	name = "Drugi Pokład Sterburta Hanger"
	icon_state = "hallS"

/area/nsv/hanger/mining
	name = "Hangar Wydobywczy"
	icon_state = "hallS"

/area/nsv/weapons
	name = "Komora Uzbrojenia"
	icon_state = "weapons_bay"

/area/nsv/weapons/ordnance
	name = "Obsługa Uzbrojenia"
	icon_state = "magazine"

/area/nsv/weapons/gauss
	name = "Komory Gaussa"
	icon_state = "gauss"

/area/nsv/weapons/port
	name = "Burta Komora Uzbrojenia"
	icon_state = "weapons_bay"

/area/nsv/weapons/starboard
	name = "Sterburta Komora Uzbrojenia"
	icon_state = "weapons_bay"

/area/nsv/weapons/fore
	name = "Fore Komora Uzbrojenia"
	icon_state = "weapons_bay"

/area/nsv/weapons/artillery
	name = "Artyleria"
	icon_state = "artillery"

/area/nsv/weapons/access_corridor
	name = "Korytarz Dostępu Amunicji"
	icon_state = "hallF"

/area/nsv/magazine
	name = "Magazyn Statku"
	icon_state = "magazine"

/area/nsv/magazine/port
	name = "Burta Magazyn"
	icon_state = "magazine"

/area/nsv/magazine/starboard
	name = "Sterburta Magazyn"
	icon_state = "magazine"

/area/nsv/briefingroom
	name = "Sala Odpraw"
	icon_state = "hallP"

/area/nsv/crew_quarters/heads/maa
	name = "Biuro Bosmanmata"
	icon_state = "shuttlegrn"

/area/nsv/squad
	name = "Pokój Wyposażenia Drużyn"
	icon_state = "shuttlegrn"

/area/ai_monitored/records
	name = "Pomieszczenie Archiwum"
	icon_state = "nuke_storage"

/area/security/locker_room
	name = "Szatnia Ochrony"
	icon_state = "checkpoint1"

/area/nsv/shuttle

/area/nsv/shuttle/bridge
	name = "Mostek Promu Wydobywczego"
	icon_state = "bridge"

/area/nsv/shuttle/central
	name = "Prom Wydobywczy"
	icon_state = "hallC"

/area/nsv/shuttle/storage
	name = "Składownia Sprzętu Promu Wydobywczego"
	icon_state = "storage"

/area/nsv/shuttle/atmospherics
	name = "Atmosferyka Promu Wydobywczego"
	icon_state = "atmos"

/area/nsv/shuttle/airlock/aft
	name = "Prom Wydobywczy Śluzy Rufa"
	icon_state = "hallA"

/area/nsv/shuttle/airlock/port
	name = "Śluzy Dzioba Promu Wydobywczego"
	icon_state = "hallP"

/area/nsv/shuttle/airlock/starboard
	name = "Śluzy Sterburta Promu Wydobywczego"
	icon_state = "hallS"

/area/nsv/shuttle/fob
	has_gravity = STANDARD_GRAVITY //good luck trying to fit a gen here.

/area/nsv/shuttle/fob/bridge
	name = "Mostek Bazy Górniczej"
	icon_state = "bridge"

/area/nsv/shuttle/fob/central
	name = "Prom Wydobywczy"
	icon_state = "hallC"

/area/nsv/shuttle/fob/storage
	name = "Prom Wydobywczy Składownia Sprzętu Bazy"
	icon_state = "storage"

/area/nsv/shuttle/fob/atmospherics
	name = "Prom Wydobywczy Tunel Techniczny"
	icon_state = "atmos"

/area/nsv/shuttle/fob/airlock/aft
	name = "Prom Wydobywczy Śluzy Rufy"
	icon_state = "hallA"

/area/nsv/shuttle/fob/airlock/port
	name = "Prom Wydobywczy Śluzy Dzioba"
	icon_state = "hallP"

/area/nsv/shuttle/fob/airlock/starboard
	name = "Prom Wydobywczy Sterburta Śluzy"
	icon_state = "hallS"

/area/nsv/shuttle/fob/quarters
	name = "Prom Wydobywczy Kwatery Załogi"
	icon_state = "hallC"

/area/nsv/shuttle/fob/lounge
	name = "Prom Wydobywczy Hol"
	icon_state = "hallP"

/area/nostromo
	name = "DMC Rocinante"
	ambientsounds = list('nsv13/sound/ambience/leit_motif.ogg','nsv13/sound/ambience/wind.ogg','nsv13/sound/ambience/wind2.ogg','nsv13/sound/ambience/wind3.ogg','nsv13/sound/ambience/wind4.ogg','nsv13/sound/ambience/wind5.ogg','nsv13/sound/ambience/wind6.ogg')
	icon_state = "mining"
	has_gravity = TRUE

/area/nostromo/maintenance/exterior
	name = "Zewnętrze Rocinante"
	icon_state = "space_near"

/area/nostromo/maintenance/hangar
	name = "Hangar Rocinante"
	icon_state = "hallS"

/area/nostromo/medbay
	name = "Izba Chorych Rocinante"
	ambient_buzz = 'nsv13/sound/ambience/medbay.ogg'
	icon_state = "medbay"

/area/nostromo/science
	name = "Wydział Naukowy Rocinante"
	ambient_buzz = 'nsv13/sound/ambience/computer_core.ogg'
	icon_state = "toxlab"

/area/nostromo/tcomms
	name = "Rdzeń TE/LE/KOMM Rocinante"
	ambient_buzz = 'nsv13/sound/ambience/computer_core.ogg'
	icon_state = "tcomsatcham"

/area/nostromo/bridge
	name = "Pokład Nawigacyjny Rocinante"
	ambient_buzz = 'nsv13/sound/ambience/bridge.ogg'
	icon_state = "bridge"

/area/nostromo/hangar/port
	name = "Pokład Burty Hangaru Rocinante"
	ambient_buzz = 'nsv13/sound/ambience/bridge.ogg'
	icon_state = "hallP"

/area/nostromo/hangar/starboard
	name = "Pokład Sterburty Hangaru Rocinante"
	ambient_buzz = 'nsv13/sound/ambience/bridge.ogg'
	icon_state = "hallS"

/area/nostromo/engineering
	name = "Inżynieria Rocinante"
	ambient_buzz = 'nsv13/sound/ambience/bridge.ogg'
	icon_state = "engine"

/area/nostromo/engineering/atmospherics
	name = "Atmosferyka Rocinante"
	ambient_buzz = 'nsv13/sound/ambience/bridge.ogg'
	icon_state = "atmos"

/area/nostromo/galley
	name = "Kuchnia Rocinante"
	ambient_buzz = 'nsv13/sound/ambience/bridge.ogg'
	icon_state = "kitchen"

/area/nostromo/galley/coldroom
	name = "Chłodnia Rocinante"
	icon_state = "kitchen_cold"

/area/nostromo/crew_quarters
	name = "Kwatery Rocinante"
	icon_state = "Sleep"
	mood_bonus = 3
	mood_message = "<span class='nicegreen'>Nie ma to jak kwatery!\n</span>"

/area/nostromo/mining
	name = "Dok Górniczy Rocinante"
	icon_state = "mining"

/area/nostromo/security
	name = "Ochrona Rocinante"
	icon_state = "security"
	ambience_index = AMBIENCE_DANGER

/area/engine/engineering/reactor_core
	name = "Rdzeń Reaktora Atomowego"
	icon_state = "engine_core"

/area/engine/engineering/reactor_control
	name = "Kontrola Reaktora"
	icon_state = "reactor_control"

/area/engine/engineering/ftl_room
	name = "Rdzeń Napędu Nadświetlnego"
	icon_state = "ftl_room"

/area/maintenance/nsv/bunker
	name = "Schron Atomowy"
	icon_state = "bunker"
	ambientsounds = list('nsv13/sound/ambience/leit_motif.ogg','nsv13/sound/ambience/wind.ogg','nsv13/sound/ambience/ship_damage/creak1.ogg','nsv13/sound/ambience/ship_damage/creak2.ogg','nsv13/sound/ambience/ship_damage/creak3.ogg','nsv13/sound/ambience/ship_damage/creak4.ogg','nsv13/sound/ambience/ship_damage/creak5.ogg','nsv13/sound/ambience/ship_damage/creak6.ogg','nsv13/sound/ambience/ship_damage/creak7.ogg')
	light_color = "#e69602"
