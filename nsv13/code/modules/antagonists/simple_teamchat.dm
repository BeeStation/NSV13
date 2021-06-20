GLOBAL_LIST_EMPTY(simple_teamchats)

//Super simple teamchat, just add the component to a thing to give it access, and allow it to speak. Can be applied to an item if you want a ""radio"" without using radio shitcode.

//Define your teamchat keys here. Used to index each teamchat.
#define TEAMCHAT_KEY_DEFAULT "Default Teamchat"
#define TEAMCHAT_KEY_BLOODLING "Alien Hivemind"
#define TEAMCHAT_KEY_APPLES "Apples"
#define TEAMCHAT_KEY_BUTTER "Butter"
#define TEAMCHAT_KEY_CHARLIE "Charlie"
#define TEAMCHAT_KEY_DUFF "Duff"

//Action buttons for teamchat. Just the one type, customize it on the component itself.
/datum/action/teamchat
	name = "Broadcast Message"
	desc = "Send a message to the assigned channel."
	var/atom/holder = null
	var/datum/component/simple_teamchat/teamspeak = null

/datum/action/teamchat/proc/can_use(mob/living/user)
	return (user && user.mind && user.stat == CONSCIOUS)

/datum/action/teamchat/Trigger()
	action(holder)

/datum/action/teamchat/proc/action(mob/living/user)
	if(!teamspeak)
		return FALSE
	if(isliving(user))
		if(!can_use(user))
			to_chat(user, "<span class='warning'>You can't do that right now...</span>")
			return FALSE
	else
		user = holder.loc //Alright, seems like they clicked the item's action instead.
	teamspeak.enter_message(user)


/datum/component/simple_teamchat
	var/name = "default"
	var/key = TEAMCHAT_KEY_DEFAULT
	var/datum/action/teamchat/chatAction = null
	var/button_icon = null
	var/icon_icon = 'nsv13/icons/mob/actions/actions_teamchat.dmi'
	var/button_icon_state = null //The button's icon_state
	var/background_icon_state = null
	var/list/sound_on_send = null //Play a sound when they're messaging this channel?
	var/list/sound_on_receipt = null //Play a sound when a message is received by someone? (WARNING: MAY GET ANNOYING)
	var/telepathic = TRUE //Should the user speak their message when they enter it? Or if youre mimicking radio, can it be heard "in your head" or over a comm.

/datum/component/simple_teamchat/proc/get_user()
	RETURN_TYPE(/mob/living)
	var/atom/movable/holder = parent
	return (isliving(holder) || !isatom(holder)) ? holder : holder.loc

/datum/component/simple_teamchat/Initialize()
	. = ..()
	if(isatom(parent))
		chatAction = new
		if(button_icon)
			chatAction.button_icon = button_icon
		if(icon_icon)
			chatAction.icon_icon = icon_icon
		if(button_icon_state)
			chatAction.button_icon_state = button_icon_state
		if(background_icon_state)
			chatAction.background_icon_state = background_icon_state
		chatAction.name = "[key] Chat"
		chatAction.holder = parent //This gets a bit weird, but the holder may be the item that's a "radio".
		chatAction.teamspeak = src //The chat action holds a ref to the component, to allow you to have multiple teamchats at once (See: global squad pager.)

	addtimer(CALLBACK(src, .proc/finalise_chat), 1 SECONDS)
	//GLOB.simple_teamchats[key] += src //Register this chat by its key.
	if(isliving(parent))
		chatAction.Grant(parent)
		return
	if(istype(parent, /obj/item))
		var/obj/item/holder = parent
		RegisterSignal(holder, COMSIG_ITEM_EQUIPPED, .proc/on_equip)
		RegisterSignal(holder, COMSIG_ITEM_DROPPED, .proc/on_drop)
		if(isliving(holder.loc)) //Account for items pre-spawned on people...
			on_equip(holder, holder.loc, null)
		return
	//For datums using the component, we don't want them to have actions!
	qdel(chatAction)

/datum/component/simple_teamchat/proc/finalise_chat()
	LAZYADD(GLOB.simple_teamchats[key], src)

//For "radios". You keep
/datum/component/simple_teamchat/proc/on_equip(datum/source, mob/equipper, slot)
	//Nope :)
	if(slot && slot == ITEM_SLOT_BACKPACK)
		on_drop(source, equipper)
		return
	chatAction.Grant(equipper)

/datum/component/simple_teamchat/proc/on_drop(datum/source, mob/user)
	chatAction.Remove(user)

/datum/component/simple_teamchat/Destroy(force, silent)
	LAZYREMOVE(GLOB.simple_teamchats[key], src)
	if(chatAction)
		if(chatAction.holder)
			chatAction.Remove(chatAction.holder)
		else
			chatAction.Remove(get_user())
		qdel(chatAction)
	. = ..()

/datum/component/simple_teamchat/proc/style_message(atom/movable/sender, msg)
	if(isatom(sender))
		return "<span class='boldnotice'>([key]) [sender.compose_rank(sender)] [sender]: </span><span class='warning'>[msg]</span>"
	return "<span class='boldnotice'>([key]) [sender]: </span><span class='warning'>[msg]</span>"

//Overloadable method, see the radio dependent teamchat.
/datum/component/simple_teamchat/proc/can_message()
	return TRUE

/datum/component/simple_teamchat/proc/enter_message(datum/user)
	if(!can_message())
		return FALSE
	var/str = stripped_input(user,"Enter a message:", "[key]", "", MAX_MESSAGE_LEN)
	if(!str)
		return FALSE
	log_say("[key]: [user] transmitted: [str]")
	send_message(user, str)

/datum/component/simple_teamchat/proc/send_message(atom/movable/user, text, list/receipt_sound_override)
	if(!can_message())
		return FALSE
	if(sound_on_send && isatom(user))
		playsound(user.loc, pick(sound_on_send), 100, 1)
	for(var/datum/component/simple_teamchat/teamspeak in GLOB.simple_teamchats[key])
		teamspeak.receive_message(user, text, receipt_sound_override)
	if(!telepathic && isatom(user))
		user.say(text)
	if(isatom(user))
		for(var/mob/M in GLOB.dead_mob_list)
			to_chat(M, "[FOLLOW_LINK(M, user)] [style_message(user, text)]")


/datum/component/simple_teamchat/proc/receive_message(atom/movable/sender, text, list/receipt_sound_override)
	var/mob/user = get_user()
	if(!isliving(user))
		return FALSE

	text = style_message(sender, text)
	if(!receipt_sound_override)
		receipt_sound_override = sound_on_receipt
	if(receipt_sound_override && isatom(user))
		playsound(user.loc, pick(receipt_sound_override), 100, 1)
	if(telepathic)
		to_chat(user, text)
	else
		//You can hear the sound coming out the radio...
		user.visible_message(text, \
							text, null, 1)

//Teamchat that behaves just like a radio would.

/datum/component/simple_teamchat/radio_dependent
	telepathic = FALSE
	sound_on_receipt = list('sound/effects/radio1.ogg','sound/effects/radio2.ogg')

/datum/component/simple_teamchat/radio_dependent/can_message()
	var/obj/machinery/telecomms/relay/ourBroadcaster = null
	//Precondition: Comms must be online.
	for(var/obj/machinery/telecomms/B in GLOB.telecomms_list)
		if(istype(B, /obj/machinery/telecomms/relay) || istype(B, /obj/machinery/telecomms/hub)  || istype(B, /obj/machinery/telecomms/server))
			if(B.is_operational() && B.on)
				if(isatom(get_user()) && B.z != get_user().z)
					continue
				ourBroadcaster = B
				break
	if(ourBroadcaster && ourBroadcaster.on)
		return TRUE
	//Play a static sound to signify that it failed.
	if(isatom(get_user()))
		playsound(get_user().loc, 'nsv13/sound/effects/radiostatic.ogg', 100, FALSE)
	return FALSE

/datum/component/simple_teamchat/radio_dependent/squad
	var/datum/squad/squad = null
	dupe_mode = COMPONENT_DUPE_ALLOWED //For the global squad pager.

/datum/component/simple_teamchat/radio_dependent/squad/Apples
	name = "Apples Squad"
	button_icon_state = "Apples"
	key = TEAMCHAT_KEY_APPLES

/datum/component/simple_teamchat/radio_dependent/squad/Butter
	name = "Butter Squad"
	button_icon_state = "Butter"
	key = TEAMCHAT_KEY_BUTTER

/datum/component/simple_teamchat/radio_dependent/squad/Charlie
	name = "Charlie Squad"
	button_icon_state = "Charlie"
	key = TEAMCHAT_KEY_CHARLIE

/datum/component/simple_teamchat/radio_dependent/squad/Duff
	name = "Duff Squad"
	button_icon_state = "Duff"
	key = TEAMCHAT_KEY_DUFF

/datum/component/simple_teamchat/radio_dependent/squad/style_message(atom/movable/sender, msg)
	if(isatom(sender))
		return "<span class='boldnotice'>([key]) [sender.compose_rank(sender)] [sender] ([sender == squad?.leader ? "SL" : "M"]): </span><span class='warning'>[msg]</span>"
	return "<span class='boldnotice'>([key]) [sender] (Overwatch): </span><span class='warning'>[msg]</span>"

//datum/component/simple_teamchat/radio_dependent/squad/style_message(atom/movable/sender, msg)
	//return "<span style=\"color:[squad.colour]><b>([key]) [sender.compose_rank(sender)][sender == squad.leader ? " (SL) " : ""]:</b> <i>[msg]</i></span>"

/datum/component/simple_teamchat/bloodling
	background_icon_state = "bg_changeling"
	button_icon_state = "bloodling"
	key = TEAMCHAT_KEY_BLOODLING

/datum/component/simple_teamchat/bloodling/style_message(atom/movable/sender, msg)
	return "<span class='noticealien'><b>([key]) [sender]</b>: [msg]</span>"
