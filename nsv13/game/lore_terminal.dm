GLOBAL_DATUM_INIT(lore_terminal_controller, /datum/lore_controller, new)

/obj/machinery/computer/lore_terminal
	name = "Seegson info-link terminal"
	desc = "A small CRT display with an inbuilt microcomputer which is loaded with an extensive database. These terminals contain eveyrthing from information about historical events to instruction manuals for common ship appliances."
	icon = 'nsv13/icons/obj/computers.dmi'
	icon_state = "terminal"
	pixel_y = 26 //So they snap to walls correctly
	density = FALSE
	anchored = TRUE
	idle_power_usage = 15
	var/access_tag = "ntcommon"  //Every subtype of this type will be readable by this console. Use this for away terms as seen here \/
	var/list/entries = list() //Every entry that we've got.
	var/in_use = FALSE //Stops sound spam
	var/datum/looping_sound/computer_click/soundloop

/obj/machinery/computer/lore_terminal/command //Put sensitive information on this one
	access_tag = "ntcommand"
	req_access = list(ACCESS_HEADS)

/obj/machinery/computer/lore_terminal/awaymission //Example for having a terminal preloaded with only a set list of files.
	access_tag = "awaymission_default"

/obj/machinery/computer/lore_terminal/Initialize()
	. = ..()
	get_entries()
	soundloop = new(list(src), FALSE)

/datum/looping_sound/computer_click
	mid_sounds = list('nsv13/sound/effects/computer/scroll1.ogg','nsv13/sound/effects/computer/scroll2.ogg','nsv13/sound/effects/computer/scroll3.ogg','nsv13/sound/effects/computer/scroll5.ogg')
	mid_length = 0.8 SECONDS
	volume = 30

/obj/machinery/computer/lore_terminal/proc/get_entries()
	for(var/X in GLOB.lore_terminal_controller.entries)
		var/datum/lore_entry/instance = X
		if(instance.access_tag == access_tag)
			entries += instance

/obj/machinery/computer/lore_terminal/attack_hand(mob/user)
	. = ..()
	if(!allowed(user))
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>Access denied</span>")
		return
	playsound(src, 'nsv13/sound/effects/computer/scroll_start.ogg', 100, 1)
	user.set_machine(src)
	var/dat
	if(!entries.len)
		get_entries()
	for(var/X in entries) //Allows you to remove things individually
		var/datum/lore_entry/content = X
		dat += "<a href='?src=[REF(src)];selectitem=\ref[content]'>[content.name]</a><br>"
	var/datum/browser/popup = new(user, "cd C:/entries/local", name, 300, 500)
	popup.set_content(dat)
	popup.open()


/obj/machinery/computer/lore_terminal/Topic(href, href_list)
	if(!in_range(src, usr))
		return
	if(in_use)
		var/sound = 'nsv13/sound/effects/computer/buzz2.ogg'
		playsound(src, sound, 100, 1)
		to_chat(usr, "<span class='warning'>ERROR: I/O function busy. A file is still loading...</span>")
		return
	var/datum/lore_entry/content = locate(href_list["selectitem"])
	if(!content || !content?.content)
		return
	var/clicks = length(content.content) //Split the content into characters. 1 character = 1 click
	var/dat = "<!DOCTYPE html>\
	<html>\
	<body background='https://cdn.discordapp.com/attachments/573966558548721665/612306341612093489/static.png'>\
	\
	<body onload='typeWriter()'>\
	\
	<h4>ACCESS FILE: C:/entries/local/[content.name]</h4>\
	<h3><i>Classification: [content.classified]</i></h3>\
	<h6>- � Seegson systems inc, 2257</h6>\
	<hr style='border-top: dotted 1px;' />\
	<h2>[content.title]</h2>\
	\
	<p id='demo'></p>\
	\
	<script>\
	var i = 0;\
	var txt = \"[content.content]\";\
	var speed = 10;\
	\
	function typeWriter() {\
	  if (i < txt.length) {\
	    var char = txt.charAt(i);\
	    if (char == '`') {\
	      document.getElementById('demo').innerHTML += '<br>';\
	    }\
	    else {\
	      document.getElementById('demo').innerHTML += txt.charAt(i);\
	    }\
	    i++;\
	    setTimeout(typeWriter, speed);\
	  }\
	}\
	</script>\
	\
	\
	<style>\
	body {\
	  background-color: black;\
	  background-image: radial-gradient(\
	    rgba(0, 20, 0, 0.75), black 120%\
	  );\
	  height: 100vh;\
	  margin: 0;\
	  overflow: hidden;\
	  padding: 2rem;\
	  color: #36f891;\
	  font: 1.3rem Lucida Console, monospace;\
	  text-shadow: 0 0 5px #355732;\
	  &::after {\
	    content: '';\
	    position: absolute;\
	    top: 0;\
	    left: 0;\
	    width: 100vw;\
	    height: 100vh;\
	    background: repeating-linear-gradient(\
	      0deg,\
	      rgba(black, 0.15),\
	      rgba(black, 0.15) 1px,\
	      transparent 1px,\
	      transparent 2px\
	    );\
	    pointer-events: none;\
	  }\
	}\
	::selection {\
	  background: #0080FF;\
	  text-shadow: none;\
	}\
	pre {\
	  margin: 0;\
	}\
	</style>\
	</body>\
	</html>"
	usr << browse(dat, "window=lore_console[content.name];size=600x600")
	playsound(src, pick('nsv13/sound/effects/computer/buzz.ogg','nsv13/sound/effects/computer/buzz2.ogg'), 100, TRUE)
	in_use = TRUE //Stops you from crashing the server with infinite sounds
	icon_state = "terminal_scroll"
	clicks = clicks/3
	var/loops = clicks/3 //Each click sound has 4 clicks in it, so we only need to click 1/4th of the time per character yeet.
	addtimer(CALLBACK(src, .proc/stop_clicking), loops)
	soundloop?.start()


/obj/machinery/computer/lore_terminal/proc/stop_clicking()
	soundloop?.stop()
	icon_state = "terminal"
	in_use = FALSE

/datum/lore_controller
	var/name = "Lore archive controller"
	var/list/entries = list() //All the lore entries we have.

/datum/lore_controller/New()
	. = ..()
	instantiate_lore_entries()

/datum/lore_controller/proc/instantiate_lore_entries()
	for(var/instance in subtypesof(/datum/lore_entry))
		var/datum/lore_entry/S = new instance
		entries += S

/datum/lore_entry
	var/name = "Loredoc.txt" //"File display name" that the term shows (C://blah/yourfile.bmp)
	var/title = null //What it's all about
	var/classified = "Declassified" //Fluff, is this a restricted file or not?
	var/content = null //You may choose to set this here, or via a .txt. file if it's long. Newlines / Enters will break it!
	var/path = null //The location at which we're stored. If you don't have this, you don't get content
	var/access_tag = "placeholder" //Set this to match the terminals that you want to be able to access it. EG "ntcommon" for declassified shit.

/datum/lore_entry/New()
	. = ..()
	if(path)
		content = file2text("[path]")

/*

TO GET THE COOL TYPEWRITER EFFECT, I HAD TO STRIP OUT THE HTML FORMATTING STUFF.
SPECIAL KEYS RESPOND AS FOLLOWS:

` = newline (br) (AKA when you press enter)
~ = horizontal line (hr)
� = bullet point

*/

/datum/lore_entry/nt
	name = "new_employees_memo.ntmail"
	title = "Intercepted message"
	path = "nsv13/lore_entries/welcome.txt"
	access_tag = "ntcommon"

/datum/lore_entry/nt/ragnarok
	name = "ragnarok_class.ntdoc"
	title = "Ragnarok Class Specifications"
	path = "nsv13/lore_entries/ragnarok.txt"

/datum/lore_entry/nt/firing_proceedure
	name = "firing_proceedure.ntdoc"
	title = "Ship-to-ship munitions"
	path = "nsv13/lore_entries/firing_proceedure.txt"

/datum/lore_entry/nt/stormdrive_operation
	name = "stormdrive_operation.ntdoc"
	title = "Setting up power"
	path = null
	content = "-Activate constrictors with an open hand ` -Open 'plasma input' valves to constrictors and set their pressure to 'MAX' ` -Assemble particle accelerator with a wrench, coil of wire and screwdriver. ` -Open reactor inlet valves and set their pressure to 'MAX'` `-Use the particle accelerator control console, set the setting to '2' and toggle its power `-When you have successfully started the reactor, it will begin emitting cherenkov radiation, giving off a 'blue glow' around the core. When the reactor is activated, turn off the particle accelerator to prevent power waste. `-It is recommended that engineers use control rod setting '2' for optimal power generation, however the control rods are not rated to withstand temperatures of over 200 degrees for long, and will thus require reinforcement with sheets of plasteel. ` If fuel fails to fill into the reactor, a backpressure surge has occurred. Turn off all inputs to the reactor and open the waste release valve with the reactor console to flush any air out of the system. When this is done, close the valve again and re-enable fuel supplies."

/datum/lore_entry/nt/meltdown_proceedures
	name = "meltdown_proceedures.ntmail"
	title = "Emergency proceedures regarding nuclear meltdowns:"
	path = null
	content = "SYSADMIN -> Allcrew@seegnet.nt. RE: Emergency Meltdown proceedures. ` The nuclear storm drive is an inherently safe engine, however this does not mean it is foolproof. Dilligence will mean the difference between having a safe, reliable power output which can last for decades, and a nuclear hellfire which can destroy the entire ship. `What to do during a meltdown: `-A reactor will melt down when the fission inside it produces an uncontrollable amount of heat (in excess of 300 degrees celsius). If this ever happens, a shipwide alarm will sound. If you hear this alarm, you must act quickly and calmly, as you will have approximately 1 - 2 minutes before the reactor explodes. `-To avert meltdown, simply locate the control console, and choose the 'SCRAM' setting (the button labelled AZ-5). This will immediately lower all control rods and attempt to cool the reactor. `-In the event of damaged control rods, IMMEDIATELY shut off all plasma constrictors, supply pumps and filters and evacuate the engineering section IMMEDIATELY to prevent unecessary loss of life. `-As a meltdown occurs, nuclear fuel is deposited all over the ship, and must be cleaned up with a shovel. This spent fuel is HIGHLY radioactive, and must be handled with extreme care. If the unthinkable comes to pass, instruct crew to seek shelter in maintenance and proceed to immediately evacuate the ship. To avoid complications, it is recommended that engineers equip radiation proof suits and gas masks, and proceed to clear a path to the evacuation arm with shovels. Remember: Stay safe through vigilance!"

/datum/lore_entry/nt/ship_weapon_maintenance
	name = "weapon_maintenance_proceedure.ntmail"
	title = "Ship-to-ship weapons maintenance and YOU"
	path = null
	content = "SYSADMIN -> Munitions@seegnet.nt. RE: Weapons Maintenance ` ATTENTIVE SHIP SYSTEM MAINTENANCE STARTS WITH YOU ` All primary ship-to-ship offensive weapons, including torpedo tubes and railguns require regular maintenance from skilled workers to remain in an optimal state. ` Reminder: Before commencing any maintenance on ship weaponry, ensure all relevant safety systems are engaged and the weapon is not loaded. ` -Unscrew the maintenance hatch on the primary external casing ` -Unbolt the internal maintenance panel ` -Use a crowbar to carefully lever out the internal panel ` -Apply 10 units of Oil to the exposed internal machinery ` -Replace and bolt the panel, fix the hatch back in place ` IF MAINTENANCE IS NOT PERFORMED REGULARLY, FAILURE COULD OCCUR DURING COMBAT, LEADING TO THE INJURY AND/OR DEATH OF YOURSELF AND OTHER CREW"


/datum/lore_entry/nt/fighter_maintenance
	name = "fighter_maintenance.ntmail"
	title = "FW: RE: How the frack do you put these hunks of junk into maintenance mode?"
	path = null
	content = "MAAMASTER -> Munitions@seegnet.nt FW: RE: How the FRACK? `Attention MAAs Fleetwide, it has come to our attention your underlings may have trouble remembering simple maintenance cycle proceedures, please foward them this message as a reminder.` `--------------------------------` `FORWARDED MESSAGE` `--------------------------------` `REDACTED@seegnet.nt -> REDACTED@seegnet.net How the FRACK?` `Hey, can you help me out big time?` `I know these fancy new fighters are supposed to have some sort of special maintenance mode that lets you access all of its components and stuff, but I can't work out how the FRACK you are supposed to make it do its thing.` `PLEASE HELP ME!` `Boss will literally lynch me if I don't get this done by the time he's back.` `--------------------------------` `REDACTED@seegnet.nt -> REDACTED@seegnet.net RE:How the FRACK?` `Let me break this down for you:` `First locate the maintenance panel on the belly of the fighter, yes you have to crawl under it, take a wrench and a crowbar with you.` `Second unbolt the panel, just don't lose the nuts otherwise you are toast.` `Third slide back the maintenance panel, this should kick the fighter to go into maintenance mode, use a crowbar for leverage if it gets stuck.` `Reverse the process to reset it into flight mode at the end, simple, yes?`"

/datum/lore_entry/nt/fighter_production
	name = "fighter_production.ntdoc"
	title = "Production and Assembly of Fighter Craft 101"
	path = null
	content = "Welcome to the NT Guide for Production and Assembly of Fighter Craft 101 `This step by step guide will familiarise you with the process of producing fighter craft components and assembling them into a serviceable fighter for the NT fleet.` `WORD OF CAUTION: This proceedure requires cooperation from several departments.` `EXTRA WORD OF CAUTION: Spreading of rumours regarding this proceedure will lead to personal redaction of REDACTED` `@#g#!&40((%%%% -=FILE CORRUPTION DETECTED=- Let me make this simpler for you to read. ~PMV` `Start by ensuring the research division of your assigned vessel has the latest and most up to date blueprints available.` `Generate a requision request for required components (APPENDIX A) and deliver it to cargo for fabrication.` `Await requision delivery at arranged location.` `` `Step by step assembly proccedure follows:` `-Open and assemble Fighter Fuselage.` `-Wrench bolts on Fighter Fuselage.` `-Weld joints together on Fighter Fuselage.` `-Locate and attach Fighter Empennage.` `-Wrench bolts on Fighter Empennage.` `-Weld joints together on Fighter Empennage.` `-Locate and attach first Fighter Wing.` `-Wrench bolts on Fighter Wing.` `-Weld joints together on Fighter Wing.` `-Locate and attach second Fighter Wing.` `-Wrench bolts on Fighter Wing.` `-Weld joints together on Fighter Wing.` `-Locate and install Fighter Landing Gear.` `-Wrench bolts on Fighter Landing Gear.` `-Locate and install Fighter Armour Plating.` `-Screw Fighter Armour Plating in place.` `-Weld joints on Fighter Armour Plating.` `-Install wiring into the Fighter.` `-Calibrate wiring with Multitool.` `-Locate and install Fighter Fuel Tank.` `-Wrench bolts on Fighter Fuel Tank.` `-Locate and install Fighter Fuel Lines.` `-Wrench bolts on Fighter Fuel Lines.` `-Locate and install first Fighter Engine.` `-Weld joints on Fighter Engine.` `-Locate and install second Fighter Engine.` `-Calibrate both Fighter Engines with a multitool.` `-Locate and install Fighter Cockpit.` `-Screw Fighter Cockpit in place.` `-Wrench bolts on Fighter Cockpit.` `-Install additional wiring into the Fighter.` `-Locate and install Fighter Avionics.` `-Screw the Fighter Avionics in place.` `-Calibrate the Fighter Avionics with a multitool.` `-Locate and install Fighter Targeting Sensors.` `-Screw the Fighter Targeting Sensors in place.` `-Calibrate the Fighter Targeting Sensors with a multitool.` `-Apply paint scheme of choice for the Fighter.` `-Choose a name for the Fighter.` `` `Your new fighter should now be complete.` `Enter maintenance mode to install ship ordinance, make repairs and refuel the vessel.` `____________` `APPENDIX A` `____________` `Fighter Components:` `-Fighter Fuselage Components Crate x1` `-Fighter Cockpit Components Box x1` `-Fighter Wing Components Box x2` `-Fighter Empennage Components Box x1` `-Fighter Landing Gear Components Box x1` `-Fighter Armour Plating x1` `-Fighter Fuel Tank x1` `-Fighter Avionics x1` `-Fighter Targeting Sensors x1` `-Fighter Fuel Line Kit x1` `-Fighter Engine x2`"

/datum/lore_entry/nt/fighters
	name = "fighter_operations.ntdoc"
	title = "Fighter operational proceedures"
	path = null
	content = "Pre flight checklist:`\
	Hit ignition switch`\
	Fuel pump switch`\
	Engage battery`\
	Engage APU`\
	Disengage throttle lock`\
	Throttle up VERY gently with brakes on so that engine takes over but you're still not moving.`\
	Lock canopy to avoid hazardous space exposure`\
	APU will automatically suspend, you are now flight ready.```\
	-------------------`\
	Shutdown sequence:`\
	Throttle off + brakes on`\
	Throttle lock on`\
	Disengage battery`\
	Disengage fuel pump (or engine gets flooded)`\
	Turn off ignition```\
	Vipers, Raptors and other small fighter craft run off of Tyrosene. This is standard fuel that's been enriched with extra hydrocarbons.`\
	If you run out of fuel:`\
	Activate the brakes and begin a shutdown of your fighter. Once you have received more fuel, begin startup sequence as expected. If you run out of fuel, you will be stuck adrift. It is highly recommended that you RTB when you hit 100 fuel as you'll have 30 seconds or so more burn time before you fizzle out.`\
	Tyrosene production:`\
	1 part hydrogen : 1 part carbon to make hydrocarbon heated to 333K. Mix hydrocarbon and welding fuel to produce tyrosene fuel and apply to tyrosene fuel tanks to allow for fighter refuel ops."

/datum/lore_entry/away_example
	title = "Intercepted log file"
	access_tag = "awayexample"

/datum/lore_entry/away_example/pilot_log
	name = "pilot_log.txt"
	content = "They're coming in hot! Prepare for flip and bur']###�$55%%% -=File Access Terminated=-"

/datum/lore_entry/away_example/weapons_log
	name = "weapon_systems_dump2259/11/25.txt"
	content = "Life support systems terminated. Railgun system status: A6E3. Torpedo system status: ~@##6#6#^^6 -=File Access Terminated=-"