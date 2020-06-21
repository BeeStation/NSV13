GLOBAL_LIST_INIT(squad_styling, list(list("Apples","#C73232", 5), list("Butter" , "#CFB52B", 5), list("Charlie" , "#AE4CCD", 5), list("Duff" , "#5998FF", INFINITY)))
GLOBAL_DATUM_INIT(squad_manager, /datum/squad_manager, new)
//"Enum" that lets you define squads. Format: Name, colour theming.

#define RADIO_SQUAD "squadcomm"
#define FREQ_SQUAD 1452

/datum/squad_manager
	var/name = "Squad Manager"
	var/list/squads = list()

/datum/squad_manager/New()
	. = ..()
	for(var/I = 1; I <= GLOB.squad_styling.len; I++){
		var/datum/squad/S = new /datum/squad()
		S.name = "[GLOB.squad_styling[I][1]] Squad"
		S.colour = GLOB.squad_styling[I][2]
		S.max_members = GLOB.squad_styling[I][3]
		squads += S
	}

/datum/squad/New()
	. = ..()
	radio_connection = SSradio.add_object(src, FREQ_SQUAD , RADIO_SQUAD)

/datum/squad_manager/proc/get_squad(name)
	for(var/datum/squad/S in squads){
		if(S.name == name){
			return S
		}
	}

/datum/squad_manager/proc/get_joinable_squad()
	for(var/datum/squad/S in squads){
		if(S.members.len && S.members.len >= S.max_members){
			continue
		}
		else{
			return S
		}
	}

/datum/squad
	var/name = "Squad"
	var/list/members = list()
	var/max_members = 5
	var/mob/living/carbon/human/leader = null
	var/colour = null
	var/blurb = "<span class='warning'><br/>During <b>General Quarters</b> you must find a squad vendor, gear up, then report to your squad leader for orders.<br/> \
	As a <i>damage control party member</i> you are responsible for repairing the ship and ensuring that breaches are sealed, debris is cleared from the halls, and injured people are taken to the medical bay.<br/>\
	Although your assigned duty is damage control, you must listen to your squad leader, as they may receive orders to redirect your squad to another essential duty <br/>\
	<i>Squad vendors</i> open up during General Quarters, and allow you to acquire a kit containing tarpaulins for closing breaches, basic tools, metal foam and a distinctive uniform to tell your squad members apart.</span>"
	var/datum/radio_frequency/radio_connection
	var/list/eligible_jobs = list(MEDSCI, CIVILIAN)
	var/list/blacklist = list(MINER, CARGOTECH, QUARTERMASTER, RD_JF) //Cargo guys exist to feed munitions, and shouldn't be directly put in a squad unless they ask to join one. RD should be allowed to man the science dept. while the nerds go do stuff.

/datum/squad/proc/broadcast(msg, mob/living/carbon/human/sender)
	var/isLead = sender == leader
	var/display_name = (CONFIG_GET(flag/show_ranks)) ? SSjob.GetJob(sender.get_assignment("", "")).get_rank() + " [sender.name]" : sender.name
	msg = "<span style=\"color:[colour];[isLead ? ";font-size:13pt" : ""]\"><b>\[[name] [isLead ? " Lead" : ""]\] [display_name]</b> says, [msg]</span>"
	var/datum/signal/signal = new(list("message" = msg, "squad"=src.name))
	for(var/mob/M in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(M, sender)
		to_chat(M, "[link] [msg]")
	radio_connection.post_signal(src, signal, filter = RADIO_SQUAD)

/datum/squad/proc/set_leader(mob/living/carbon/human/H)
	leader = H
	to_chat(H, "<span class='sciradio'>You are the squad leader of [name]!. You have authority over the members of this squadron, and may direct them as you see fit. In general, you should use your squad members to help you repair damaged areas during general quarters</span>")
	src += H
	broadcast("[H.name] has been assigned to your squad as leader.") //Change order of this when done testing.

/obj/item/squad_pager
	name = "squad pager"
	desc = "A small device that allows you to listen to and broadcast over squad comms. Use :v to page your squad with a message."
	icon = 'nsv13/icons/obj/squad.dmi'
	icon_state = "squadpager"
	w_class = 1
	slot_flags = ITEM_SLOT_BELT
	var/datum/radio_frequency/radio_connection
	var/datum/squad/squad = null

/obj/item/squad_pager/Initialize(mapload, datum/squad/squad)
	. = ..()
	if(!squad)
		return
	src.squad = squad //Ahoy mr squadward! Ack ack ack.
	name = "[squad] pager"
	var/mutable_appearance/stripes = new()
	stripes.icon = icon
	stripes.icon_state = "squadpager_stripes"
	stripes.color = squad.colour
	add_overlay(new /mutable_appearance(stripes))
	radio_connection = SSradio.add_object(src, FREQ_SQUAD, RADIO_SQUAD)

/obj/item/squad_pager/receive_signal(datum/signal/signal)
	var/atom/ourLoc = (ismob(loc)) ? loc : loc.loc //You get two layers of recursion with this one. No more. (So you can have the pager in a backpack and still use it.
	if(signal.data["message"] && signal.data["squad"] == squad?.name && ismob(ourLoc))
		var/msg = signal.data["message"]
		to_chat(ourLoc, msg)
		playsound(loc, pick('nsv13/sound/effects/radio1.ogg','nsv13/sound/effects/radio2.ogg'), 100, TRUE)

/mob/living/carbon/human
	var/datum/squad/squad = null

//Add a member to our squad.
/datum/squad/proc/operator+=(mob/living/carbon/human/H)
	to_chat(H, "<span class='boldnotice'>You have been assigned to [name]!</span>[blurb]</span>")
	members += H
	H.squad = src
	var/obj/item/storage/backpack/bag = H.get_item_by_slot(SLOT_BACK)
	new /obj/item/squad_pager(bag, src)
	new /obj/item/clothing/suit/ship/squad(bag, src)
	new /obj/item/clothing/head/ship/squad(bag, src)

//Begin job overrides.

/datum/job/after_spawn(mob/living/H, mob/M, latejoin = FALSE)
	. = ..()
	addtimer(CALLBACK(src, .proc/register_squad, H), 2 SECONDS)

/datum/job/proc/register_squad(mob/living/H)
	if(!ishuman(H))
		return //No
	var/datum/squad/squad = GLOB.squad_manager.get_squad(H.client.prefs.preferred_squad)
	if(squad.members.len && squad.members.len >= squad.max_members) //Too many people! Make a new squad and pop us in it.
		squad = GLOB.squad_manager.get_joinable_squad()
	if(H.client.prefs.be_leader)
		if(!squad.leader)
			squad.set_leader(H)
			return
		else
			for(var/datum/squad/S in GLOB.squad_manager.squads)
				if(!S.leader)
					S.set_leader(H)
					return
	if(department_flag in squad.eligible_jobs)
		if(flag in squad.blacklist)
			return //Miners are annoying and don't live shipside.
		squad += H

/datum/saymode/squad
	key = MODE_KEY_SQUAD
	mode = MODE_SQUAD

/datum/saymode/squad/handle_message(mob/living/carbon/human/user, message, datum/language/language)
	if(!ishuman(user))
		return
	var/obj/item/squad_pager/page = locate(/obj/item/squad_pager) in user.get_contents()
	if(!page || !page.squad)
		return
	user.say("[message]")
	page.squad.broadcast(message, user)