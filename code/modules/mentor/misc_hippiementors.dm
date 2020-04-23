GLOBAL_LIST_EMPTY(mentors) //all clients whom are admins
GLOBAL_PROTECT(mentors)

/client/New()
    . = ..()
    mentor_datum_set()

/client/proc/is_mentor() // admins are mentors too.
    if(mentor_datum || check_rights_for(src, R_ADMIN,0))
        return TRUE

/client/proc/hippie_client_procs(href_list)
    if(href_list["mentor_msg"])
        var/datum/admin_help/AH = locate(href_list["mentor_msg"])
        AH.try_action("reply", src)
        return TRUE
    if(href_list["mentor_view"])
        var/client/C = locate(href_list["mentor_view"])
        C.current_ticket.try_action("ticket", src)
        return TRUE


/client/proc/mentor_datum_set(admin)
    mentor_datum = GLOB.mentor_datums[ckey]
    if(!mentor_datum && check_rights_for(src, R_ADMIN,0)) // admin with no mentor datum?let's fix that
        new /datum/mentors(ckey)
    if(mentor_datum)
        if(!check_rights_for(src, R_ADMIN,0) && !admin)
            GLOB.mentors |= src // don't add admins to this list too.
        mentor_datum.owner = src
        add_mentor_verbs()
        mentor_memo_output("Show")

/proc/log_mentor(text)
    GLOB.mentorlog.Add(text)
    WRITE_LOG(GLOB.world_game_log, "MENTOR: [text]")