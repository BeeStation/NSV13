#define METACOINS_MINIMUM 0

/client/proc/cmd_admin_mod_metacoins(client/C in GLOB.clients, var/operation)
	set category = "Adminbus"
	set name = "Modify Metacoins"

	if(!check_rights(R_ADMIN))
		return

	var/msg = ""
	var/log_text = ""

	if(operation == "zero")
		log_text = "Set to 0"
		C.set_metacoin_count(METACOINS_MINIMUM)
	else
		var/prompt = "Please enter the amount of metacoins to [operation]:"

		if(operation == "set")
			prompt = "Please enter the new metacoins amount:"

		msg = input("Message:", prompt) as num|null

		if (!msg)
			return

		if(operation == "set")
			log_text = "Set to [num2text(msg)]"
			C.set_metacoin_count(clamp(msg,METACOINS_MINIMUM,INFINITY))
		else if(operation == "add")
			log_text = "Added [num2text(msg)]"
			C.inc_metabalance(msg)
		else if(operation == "subtract")
			log_text = "Subtracted [num2text(msg)]"
			C.inc_metabalance(-msg)
		else
			to_chat(src, "Invalid operation for metacoins modification: [operation] by user [key_name(usr)]")
			return

	log_admin("[key_name(usr)]: Modified [key_name(C)]'s metacoins [log_text]")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)]: Modified [key_name(C)]'s metacoins ([log_text])</span>")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Modify Metacoins") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
