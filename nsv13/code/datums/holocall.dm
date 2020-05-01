/obj/item/disk/holodisk/hammerhead_cryo
	name = "Engineering Audit Log HH-593"
	desc = "A holodisk containing a recording of a work order being carried out during servicing."
	preset_image_type = /datum/preset_holoimage/engineer
	preset_record_text = {"
	NAME Almayer Gervais
	DELAY 10
	SAY So tell me, why are we dumping a load of stasis beds in the dormitories?
	DELAY 20
	PRESET /datum/preset_holoimage/engineer/ce/rig
	NAME Oscar Leonidas
	SAY Why does NT do anything strange, they've probably hit some kinda delay in a project.
	DELAY 10
	SAY And instead of admitting they made a mistake, they ship something. Even if it's wildly off spec.
	DELAY 20
	NAME Almayer Gervais
	PRESET /datum/preset_holoimage/engineer/rig
	SAY Sounds pretty scummy.
	DELAY 5
	SAY Oh well, work orders are work orders, we got them all hooked up?
	PRESET /datum/preset_holoimage/engineer/ce/rig
	NAME Oscar Leonidas
	SAY Yeah they're all set, Next up's uh... Something about a transit tube?
	DELAY 15
	SAY Ah who cares, Let's get moving
	DELAY 20
	PRESET /datum/preset_holoimage/corgi
	NAME Burst Data
	LANGUAGE /datum/language/eal
	SAY START NTINTEL METADATA
	SAY RECORDED 12-17-0000
	SAY SECURITY CLASS UNCLASSIFIED
	SAY END NTINTEL METADATA
"}

/obj/item/disk/holodisk/enterprise_log
	name = "SGC Enterprise Audit Log CV-9654"
	desc = "It has a large label on it reading 'CLASSIFIED' underneath a symbol of a large sun surrounded by wings."
	preset_image_type = /datum/preset_holoimage/engineer
	preset_record_text = {"
	NAME Joshua Griggs
	DELAY 10
	SAY You got a minute? I need a hand removing this circuit. Damn thing's stuck
	DELAY 20
	PRESET /datum/preset_holoimage/engineer/ce/rig
	NAME Stewart Caltrone
	SAY Try a screwdriver.
	DELAY 20
	NAME Joshua Griggs
	PRESET /datum/preset_holoimage/engineer
	SAY Thanks. So why are we stripping out these shield relays anyway?
	DELAY 20
	PRESET /datum/preset_holoimage/engineer/ce/rig
	NAME Stewart Caltrone
	SAY Quiet down airman. That's classified. But I'll tell you something... I wouldn't trust a Nanotrasen crew with more complicated than a paperclip.
	DELAY 20
	NAME Joshua Griggs
	PRESET /datum/preset_holoimage/engineer
	SAY That's true...but don't you think it's a little dishonest how we're hiding this from them?
	DELAY 20
	PRESET /datum/preset_holoimage/engineer/ce/rig
	NAME Stewart Caltrone
	SAY It's a need to know basis. Central is lending them this ship on humanitarian grounds and nothing more. To be honest, the Syndicate have only openly declared hostilities towards Nanotrasen, not us. This isn't really a SolGov problem at all.
	DELAY 20
	NAME Joshua Griggs
	PRESET /datum/preset_holoimage/engineer
	SAY I guess. Just doesn't sit right with me. I just hope that whichever crew that ends up inheriting this ship takes good care of it.
	DELAY 20
	PRESET /datum/preset_holoimage/captain
	NAME Dayton Lux
	SAY Airmen, you've got a job to do. Cut the chatter and move down to frame 5 J-7, the supervisor wants to see you.
	DELAY 20
	NAME Joshua Griggs
	PRESET /datum/preset_holoimage/engineer
	SAY Sir yes sir!
	DELAY 20
	SAY START METADATA
	SAY RECORDED 12-17-0000
	SAY SECURITY CLASS: CLASSIFIED
	SAY END METADATA
"}

/obj/item/disk/holodisk/enterprise_log/two
	name = "SGC Enterprise Audit Log CV-9658"
	desc = "A diskette with a symbol of a large sun surrounded by wings. A date has been hastily scrawled onto it with a permanent marker."
	preset_image_type = /datum/preset_holoimage/researcher
	preset_record_text = {"
	NAME Stewart Lance
	DELAY 20
	SAY So..you hear about NT's new Hammerhead class of ships?
	DELAY 20
	PRESET /datum/preset_holoimage/engineer
	NAME Joshua Griggs
	SAY I heard that they're big. What of it?
	DELAY 20
	PRESET /datum/preset_holoimage/researcher
	NAME Stewart Lance
	SAY Y'know, the ones that replaced their godawful Aegis class...
	DELAY 20
	PRESET /datum/preset_holoimage/engineer
	NAME Joshua Griggs
	SAY Not really. That's not really my department. I'm here to maintain SolGov ships, not worry about whatever the hell Nanotrasen are up to.
	DELAY 20
	PRESET /datum/preset_holoimage/researcher
	NAME Stewart Lance
	SAY That's fair... well rumour has it that the Hammerhead's prototype was built in a week. Least that's what I heard from my cousin Francis.
	DELAY 20
	PRESET /datum/preset_holoimage/engineer
	NAME Joshua Griggs
	SAY A week!? how the hell can you plan and produce a ship in a week?!
	DELAY 20
	PRESET /datum/preset_holoimage/researcher
	NAME Stewart Lance
	SAY And get this....the Aegis prototype was produced in a weekend.
	DELAY 20
	PRESET /datum/preset_holoimage/engineer
	NAME Joshua Griggs
	SAY Jesus. I knew NT liked to cut corners, but that's just something else. I'm starting to think I made the right choice when I signed on with SolGov.
	DELAY 20
	PRESET /datum/preset_holoimage/captain
	NAME Dayton Lux
	SAY Engineer, Researcher. Are you done cleaning out the Akulas yet? The supervisor needs someone to unload the cargo shuttle.
	DELAY 20
	PRESET /datum/preset_holoimage/engineer
	NAME Joshua Griggs
	SAY Yessir. I'll take care of it.
	DELAY 20
	SAY START METADATA
	SAY RECORDED 12-19-0000
	SAY SECURITY CLASS: CLASSIFIED
	SAY END METADATA
"}

/datum/preset_holoimage/curator
	outfit_type = /datum/outfit/job/curator

/obj/item/disk/holodisk/galactica_history
	name = "SGC Solaria History #1 - A battleship to surpass them all!"
	desc = "An informational holodisk carrying information about the history of the SGV Solaria."
	preset_image_type = /datum/preset_holoimage/curator
	preset_record_text = {"
	SAY LOADING INFORMATIONAL HOLOTAPE #1
	SAY WELCOME TO THE SOLARIA.
	NAME Joe 'Schlomo' Speedwagon
	SAY Welcome to the SGV Solaria! I'm Joe, and I'll be your guide.
	DELAY 30
	SAY This is the first of several informational holotapes recorded by VICKER media on behalf of the Solarian Government.
	DELAY 30
	SAY We start our journey 30 years ago, when this ship was first built. She was designed as a battleship to head the SolGov fleet in a response to Nanotrasen's aggressive military expansion in the 2210s, and boasted an impressive amount of firepower.
	DELAY 30
	SAY Estimates put this ship's firepower on par with three Nanotrasen Aegis class light cruisers, however it has since been decommissioned and turned into a museum due to its historical significance!
	DELAY 30
	SAY In the next installment, you can find out about the Solaria's importance in several key conflicts. But for now, goodbye! And please, enjoy the museum...
	DELAY 30
	SAY END OF RECORDING. PLEASE INSERT NEXT FLOPPY DISK.
"}

/obj/item/disk/holodisk/galactica_history/history
	name = "SGC Solaria History #2 - Historical significance"
	desc = "An informational holodisk carrying information about the history of the SGV Solaria, part 2 in the series."
	preset_image_type = /datum/preset_holoimage/curator
	preset_record_text = {"
	SAY LOADING INFORMATIONAL HOLOTAPE #2
	SAY WELCOME TO THE SOLARIA.
	NAME Joe 'Schlomo' Speedwagon
	SAY Welcome to the SGV Solaria! I'm Joe, and I'll be your guide.
	DELAY 30
	SAY This is the second installment of several informational holotapes recorded by VICKER media on behalf of the Solarian Government.
	DELAY 30
	SAY The Solaria participated in many border skirmishes, however as she was created primarily as a peacekeeping ship, she rarely saw heavy combat.
	DELAY 30
	SAY Most famously, the Solaria dealt a crushing blow to the Jovian felinid-abduction rings, taking on an entire fleet of transport ships by itself!
	DELAY 30
	SAY Unfortunately, that's all I've got time for today. Tune in to the next installment to find out all about the Solaria's technical specifications. For now, goodbye! And please, enjoy the museum...
	DELAY 30
	SAY END OF RECORDING. PLEASE INSERT NEXT FLOPPY DISK.
"}

/obj/item/disk/holodisk/galactica_history/tech_specs
	name = "SGC Solaria History #3 - Technical Specifications"
	desc = "An informational holodisk carrying information about the history of the SGV Solaria, the final part in the series."
	preset_image_type = /datum/preset_holoimage/curator
	preset_record_text = {"
	SAY LOADING INFORMATIONAL HOLOTAPE #3
	SAY WELCOME TO THE SOLARIA.
	NAME Joe 'Schlomo' Speedwagon
	SAY Welcome to the SGV Solaria! I'm Joe, and I'll be your guide.
	DELAY 30
	SAY This is the final installment of several informational holotapes recorded by VICKER media on behalf of the Solarian Government.
	DELAY 30
	SAY Last installment, I told you all about the Solaria's rich history, but now it's time to talk tech!
	DELAY 30
	SAY The Solaria boasts 8 Gauss cannon, 4 electromagnetic railguns, and even more torpedo tubes!
	DELAY 30
	SAY She's rated to withstand a thermonuclear blast of up to 200MT, though this has never been tested!
	DELAY 30
	SAY The Solaria is capable of long range faster-than-light travel, and boasted an experimental class 2 stormdrive at its peak, capable of delivering megawatts of power! Though unfortunately, after decomissioning, the Solaria's stormdrive was replaced with a more stable fission reactor.
	DELAY 30
	SAY Thank you for joining me on this journey, and hopefully your quest for knowledge doesn't end here! There's plenty of reading material for you around the museum, or you can look at some of the ship's departments - preserved exactly as they would've been used 30 years ago!.
	DELAY 30
	SAY This is me, Joe Speedwagon, Signing off.
	SAY END OF SERIES.
"}
