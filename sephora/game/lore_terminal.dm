GLOBAL_DATUM_INIT(lore_terminal_controller, /datum/lore_controller, new)

/obj/machinery/computer/lore_terminal
	name = "Seegson info-link terminal"
	desc = "A small CRT display with an inbuilt microcomputer which is loaded with an extensive database. These terminals contain eveyrthing from information about historical events to instruction manuals for common ship appliances."
	icon = 'sephora/icons/obj/computers.dmi'
	icon_state = "terminal"
	pixel_y = 26 //So they snap to walls correctly
	density = FALSE
	anchored = TRUE
	var/access_tag = "ntcommon"  //Every subtype of this type will be readable by this console. Use this for away terms as seen here \/
	var/list/entries = list() //Every entry that we've got.
	var/in_use = FALSE //Stops sound spam

/obj/machinery/computer/lore_terminal/command //Put sensitive information on this one
	access_tag = "ntcommand"
	req_access = list(ACCESS_HEADS)

/obj/machinery/computer/lore_terminal/awaymission //Example for having a terminal preloaded with only a set list of files.
	access_tag = "awaymission_default"

/obj/machinery/computer/lore_terminal/Initialize()
	. = ..()
	get_entries()

/obj/machinery/computer/lore_terminal/proc/get_entries()
	for(var/X in GLOB.lore_terminal_controller.entries)
		var/datum/lore_entry/instance = X
		if(instance.access_tag == access_tag)
			entries += instance

/obj/machinery/computer/lore_terminal/attack_hand(mob/user)
	. = ..()
	if(!allowed(user))
		var/sound = pick('sephora/sound/effects/computer/error.ogg','sephora/sound/effects/computer/error2.ogg','sephora/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>Access denied</span>")
		return
	playsound(src, 'sephora/sound/effects/computer/scroll_start.ogg', 100, 1)
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
		var/sound = 'sephora/sound/effects/computer/buzz2.ogg'
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
	<h2>ACCESS FILE: C:/entries/local/[content.name]</h2>\
	<h6>- © Seegson systems inc, 2257</h6>\
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
	    document.getElementById('demo').innerHTML += txt.charAt(i);\
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
	playsound(src, pick('sephora/sound/effects/computer/buzz.ogg','sephora/sound/effects/computer/buzz2.ogg'), 100, TRUE)
	var/sound = 'sephora/sound/effects/computer/scroll_short.ogg'
	in_use = TRUE //Stops you from crashing the server with infinite sounds
	icon_state = "terminal_scroll"
	clicks = clicks/3 //Account for spaces
	var/i = 0
	while(i < clicks)
		playsound(src, sound, 20, TRUE)
		i ++
		stoplag()
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
	var/content = null //You may choose to set this here, or via a .txt. file if it's long. Newlines / Enters will break it!
	var/path = null //The location at which we're stored. If you don't have this, you don't get content
	var/access_tag = "placeholder" //Set this to match the terminals that you want to be able to access it. EG "ntcommon" for declassified shit.

/datum/lore_entry/New()
	. = ..()
	if(path)
		content = file2text("[path]")

/datum/lore_entry/nt
	name = "new_employees_memo.ntdoc"
	path = "sephora/lore_entries/welcome.txt"
	access_tag = "ntcommon"

/datum/lore_entry/nt/ragnarok
	name = "ragnarok_class.ntdoc"
	path = "sephora/lore_entries/ragnarok.txt"

/datum/lore_entry/nt/firing_proceedure
	name = "firing_proceedure.ntdoc"
	path = "sephora/lore_entries/firing_proceedure.txt"

/datum/lore_entry/away_example
	access_tag = "awayexample"

/datum/lore_entry/away_example/pilot_log
	name = "pilot_log.txt"
	content = "They're coming in hot! Prepare for flip and bur']###£$55%%% -=File Access Terminated=-"

/datum/lore_entry/away_example/weapons_log
	name = "weapon_systems_dump2259/11/25.txt"
	content = "Life support systems terminated. Railgun system status: A6E3. Torpedo system status: ~@##6#6#^^6 -=File Access Terminated=-"