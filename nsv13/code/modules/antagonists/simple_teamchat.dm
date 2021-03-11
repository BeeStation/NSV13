GLOBAL_LIST_EMPTY(simple_teamchats)

//Super simple teamchat, just add the component to a thing to give it access, and allow it to speak. Can be applied to an item if you want a ""radio"" without using radio shitcode.

//Define your teamchat keys here. Used to index each teamchat.
#define TEAMCHAT_KEY_DEFAULT "Default Teamchat"
#define TEAMCHAT_KEY_BLOODLING "Alien Hivemind"

//Action buttons for teamchat. Just the one type, customize it on the component itself.
/datum/action/teamchat
	name = "Broadcast Message"
	desc = "Send a message to the assigned channel."
	var/atom/holder = null

/datum/action/teamchat/proc/can_use(mob/living/user)
	return (user && user.mind && user.stat == CONSCIOUS)

/datum/action/teamchat/Trigger()
	action(holder)

/datum/action/teamchat/proc/action(mob/living/user)
	var/datum/component/simple_teamchat/teamspeak = user.GetComponent(/datum/component/simple_teamchat)
	if(!teamspeak)
		return FALSE
	if(isliving(user))
		if(!can_use(user))
			to_chat(user, "<span class='warning'>You can't do that right now...</span>")
			return FALSE
	else
		user = user.loc //Alright, seems like they clicked the item's action instead.
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
	return (isliving(holder)) ? holder : holder.loc

/datum/component/simple_teamchat/Initialize(...)
	. = ..()
	chatAction = new
	if(button_icon)
		chatAction.button_icon = button_icon
	if(icon_icon)
		chatAction.icon_icon = icon_icon
	if(button_icon_state)
		chatAction.button_icon_state = button_icon_state
	if(background_icon_state)
		chatAction.background_icon_state = background_icon_state
	chatAction.name = "[key] chat"
	chatAction.holder = parent //This gets a bit weird, but the holder may be the item that's a "radio".
	if(isliving(parent))
		chatAction.Grant(parent)
		return
	if(istype(parent, /obj/item))
		var/obj/item/holder = parent
		RegisterSignal(holder, COMSIG_ITEM_EQUIPPED, .proc/on_equip)
		RegisterSignal(holder, COMSIG_ITEM_DROPPED, .proc/on_drop)
		if(isliving(holder.loc)) //Account for items pre-spawned on people...
			on_equip(holder, holder.loc, null)
		if(!GLOB.simple_teamchats[key])
			GLOB.simple_teamchats[key] = list()
		GLOB.simple_teamchats[key] += src //Register this chat by its key.
		return
	return COMPONENT_INCOMPATIBLE

//For "radios". You keep
/datum/component/simple_teamchat/proc/on_equip(datum/source, mob/equipper, slot)
	//Nope :)
	if(slot && slot == SLOT_IN_BACKPACK)
		on_drop(source, equipper)
		return
	chatAction.Grant(equipper)

/datum/component/simple_teamchat/proc/on_drop(datum/source, mob/user)
	chatAction.Remove(user)

/datum/component/simple_teamchat/Destroy(force, silent)
	LAZYREMOVE(GLOB.simple_teamchats[key], src)
	. = ..()


/datum/component/simple_teamchat/proc/style_message(atom/movable/sender, msg)
	return "<span class='boldnotice'>([key]) [sender.name]:</span><span class='warning'>[msg]</span>"

//Overloadable method, see the radio dependent teamchat.
/datum/component/simple_teamchat/proc/can_message()
	return TRUE

/datum/component/simple_teamchat/proc/enter_message(mob/living/user)
	if(!can_message())
		return FALSE
	var/str = stripped_input(user,"Enter a message:", "[key]", "", MAX_MESSAGE_LEN)
	send_message(user, str)

/datum/component/simple_teamchat/proc/send_message(mob/living/user, text)
	if(sound_on_send)
		playsound(user.loc, pick(sound_on_send), 100, 1)
	for(var/datum/component/simple_teamchat/teamspeak in GLOB.simple_teamchats[key])
		teamspeak.receive_message(user, text)
	if(!telepathic)
		user.say(text)

/datum/component/simple_teamchat/proc/receive_message(sender, text)
	var/mob/user = get_user()
	if(!isliving(user))
		return FALSE
	if(sound_on_receipt)
		playsound(user.loc, pick(sound_on_receipt), 100, 1)
	if(telepathic)
		to_chat(user, style_message(sender, text))
	else
		//You can hear the sound coming out the radio...
		user.visible_message(style_message(sender, text), \
							style_message(sender, text), null, 1)

//Teamchat that behaves just like a radio would.

/datum/component/simple_teamchat/radio_dependent
	telepathic = FALSE
	sound_on_receipt = list('nsv13/sound/effects/radio1.ogg','nsv13/sound/effects/radio2.ogg')

/datum/component/simple_teamchat/radio_dependent/can_message()
	var/obj/machinery/telecomms/relay/ourBroadcaster = null
	//Precondition: Comms must be online.
	for(var/obj/machinery/telecomms/B in GLOB.telecomms_list)
		if(istype(B, /obj/machinery/telecomms/relay) || istype(B, /obj/machinery/telecomms/hub)  || istype(B, /obj/machinery/telecomms/server))
			if(B.is_operational() && B.on && B.z == get_user().z)
				ourBroadcaster = B
				break
	if(ourBroadcaster && ourBroadcaster.on)
		return TRUE
	//Play a static sound to signify that it failed.
	playsound(get_user().loc, 'nsv13/sound/effects/radiostatic.ogg', 100, FALSE)
	return FALSE

/datum/component/simple_teamchat/bloodling
	background_icon_state = "bg_changeling"
	button_icon_state = "bloodling"
	key = TEAMCHAT_KEY_BLOODLING
