GLOBAL_LIST_INIT(pecking_order, world.file2list("config/ranks/pecking_order.txt"))

//For code/controllers/subsystem/job.dm
/datum/controller/subsystem/job/proc/LoadRanks(rankfile="config/ranks/royal_navy.txt")
	if (fexists("[rankfile]"))
		var/rankstext = file2text("[rankfile]")

		var/list/missed = list()
		for(var/datum/job/J in occupations)
			var/regex/jobs = new("[J.title]=(.+)")
			jobs.Find(rankstext)
			stoplag() //In case someone gives us a really huge file

			if(jobs.group && jobs.group[1])
				J.display_rank = "[jobs.group[1]]"
			else
				message_admins("No rank found for: [J.title]")
				missed += J
				J.display_rank = ""
		if(!length(missed))
			return
		else if(length(missed) < length(occupations))
			//Try to default rank-less jobs to another rank
			var/datum/job/A = select_substitute_rank()
			if(A)
				message_admins("Substituting rank [A.display_rank] for missing ranks")
				for(var/datum/job/J in missed)
					J.display_rank = A.display_rank
		else
			message_admins("No rank information found.")

/proc/check_outranks(atom/movable/us, atom/movable/them)
	if (!CONFIG_GET(flag/show_ranks) || !GLOB.pecking_order?.len || them == us)
		return
	var/myRank = us.compose_rank(us)
	var/myClout = 0
	if(!myRank || myRank == "")
		myClout = -100
	var/theirClout = 0
	var/theirRank = them.compose_rank(them)
	if(!theirRank || theirRank == "")
		theirClout = -100
	theirRank = replacetext(theirRank, " ", "")
	myRank = replacetext(myRank, " ", "")
	//Unsupported ranks.
	if(!(LAZYFIND(GLOB.pecking_order, myRank)) || !(LAZYFIND(GLOB.pecking_order, theirRank)))
		return FALSE
	for(var/I = 1; I <= GLOB.pecking_order.len; I++)
		var/theRank = GLOB.pecking_order[I]
		if(theRank == myRank)
			myClout = I
		if(theRank == theirRank)
			theirClout = I
	//We live in a clout based society :(
	if(myClout == theirClout)
		return "<span class='notice'>You are the same rank as them.</span>"
	if(myClout > theirClout)
		return "<span class='boldnotice'>You outrank them as a [theirRank].</span>"
	if(myClout < theirClout)
		return "<span class='boldwarning'>They outrank you as a [myRank].</span>"
	return "<span class='warning'>You've forgotten how ranks work.</span>"

/**
Checks two text ranks, see which one outranks the other. Used for squad rank assignment (to avoid accidental demotions)
*/
/proc/check_rank_pecking_order(myRank, theirRank)
	if(!LAZYFIND(GLOB.pecking_order, myRank) || !LAZYFIND(GLOB.pecking_order, theirRank))
		return FALSE
	var/myClout = 0
	var/theirClout = 0
	for(var/I = 1; I <= GLOB.pecking_order.len; I++)
		var/theRank = GLOB.pecking_order[I]
		if(theRank == myRank)
			myClout = I
			continue
		if(theRank == theirRank)
			theirClout = I
	return myClout > theirClout

/mob/living/carbon/human/examine(mob/user)
	. = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/outranks = check_outranks(src, H)
		if(outranks)
			. += outranks

/datum/controller/subsystem/job/proc/select_substitute_rank()
	//Try assistant first
	var/datum/job/A = SSjob.GetJob(JOB_NAME_ASSISTANT)
	if(A && A.display_rank)
		return A

	//Get a random good one
	var/list/remaining = occupations.Copy()
	while(remaining.len > 0)
		stoplag()
		A = pick(remaining)
		if(A.display_rank)
			return A
		remaining -= A


//For code/game/say.dm - show ranks in speech
/atom/movable/proc/compose_rank(atom/movable/speaker)
	if (!CONFIG_GET(flag/show_ranks))
		return

	var/job
	var/rank = ""
	//Otherwise if we're composing for someone else...
	if (istype(speaker, /mob/living/carbon/human))
		var/mob/living/carbon/human/speakerMob = speaker
		//Squads can override our ranks to be beyond our station.
		job = speakerMob.get_assignment("", "")
	//Or it's radiocode jank shitcode.
	else if (istype(speaker, /atom/movable/virtualspeaker))
		var/atom/movable/virtualspeaker/VS = speaker
		if(VS.squad_rank)
			return "[VS.squad_rank] "
		job = VS.GetJob()

	if (job)
		var/datum/job/J = SSjob.GetJob(job)
		rank = "[J ? "[J.get_rank()] " : ""]"

	return rank

///////////////////////////////////////
// Admin verb to switch rank structure
/client/proc/changeranks()
	set name = "Change Ranks"
	set desc = "Set the rank structure for the current round."
	set category = "Admin"

	browse_rank_configs()

/client/proc/browse_rank_configs()
	var/path = browse_files(RANK_DIR)
	if(!path)
		return

	if(file_spam_check())
		return

	message_admins("[key_name_admin(src)] accessed file: [path]")
	switch(alert("View (in game), Open (in your system's text editor), or Load?", path, "View", "Open", "Load"))
		if ("View")
			src << browse("<pre style='word-wrap: break-word;'>[html_encode(file2text(file(path)))]</pre>", list2params(list("window" = "viewfile.[path]")))
		if ("Open")
			src << run(file(path))
		if ("Load")
			message_admins("[key_name_admin(src)] changed rank configuration to: [path]")
			SSjob.LoadRanks(path)
		else
			return
	to_chat(src, "Attempting to send [path].")
	return
