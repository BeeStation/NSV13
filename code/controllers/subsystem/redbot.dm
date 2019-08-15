/* 
USAGE:

Notices can be sent directly into discord by calling the send_discord_message(var/channel, var/message, var/priority_type) function. 

##################
# HOW THIS WORKS #
##################

Messages are exported from the world and interpreted by the bot. The messages contain two identifies as well as the body content described below. 

[-] The Channel identifies where message should go in Discord according to how the bot is configured
[-] The Priority_Type determines the type of message being sent. While required, this does not currently do anything. Development to incorporate special types of
    embeds and status is planned. 
[-] The Message contains the actual body content for the discord embed

Supported channels:

    - admin
    - mentor

EXAMPLE:

SSredbot.send_discord_message("admin", "Ticket #[id] created by [usr.ckey] ([usr.real_name]): [name]", "ticket") ==> Ticket notification sent to the admin channel in Discord

Documentation + the Redbot cogs for this subsystem are found at: https://github.com/crossedfall/crossed-cogs/tree/ss13/master
*/

SUBSYSTEM_DEF(redbot)
	name = "Bot Comms"
	flags = SS_NO_FIRE

/datum/controller/subsystem/redbot/Initialize(timeofday)
	var/comms_key = CONFIG_GET(string/comms_key)
	var/bot_ip = CONFIG_GET(string/bot_ip)
	var/round_id = GLOB.round_id
	if(config && bot_ip)
		var/query = "http://[bot_ip]/?serverStart=1&roundID=[round_id]&key=[comms_key]"
		world.Export(query)
	return ..()

/datum/controller/subsystem/redbot/proc/send_discord_message(var/channel, var/message, var/priority_type)
	var/bot_ip = CONFIG_GET(string/bot_ip)
	var/list/adm = get_admin_counts()
	var/list/allmins = adm["present"]
	. = allmins.len
	if(!config || !bot_ip)
		return
	if(priority_type && !.)
		send_discord_message(channel, "@here - A new [priority_type] requires/might need attention, but there are no admins online.")
	var/list/data = list()
	data["key"] = CONFIG_GET(string/comms_key)
	data["announce_channel"] = channel
	data["announce"] = message
	world.Export("http://[bot_ip]/?[list2params(data)]")