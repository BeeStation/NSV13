//For code/controllers/subsystem/job.dm
/datum/controller/subsystem/job/proc/LoadRanks(rankfile="config/ranks/military.txt")
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

		if(missed.len == 0)
			return
		else if(missed.len < occupations.len)
			//Try to default rank-less jobs to another rank
			var/datum/job/A = select_substitute_rank()
			if(A)
				message_admins("Substituting rank [A.display_rank] for missing ranks")
				for(var/datum/job/J in missed)
					J.display_rank = A.display_rank
		else
			message_admins("No rank information found.")

/datum/controller/subsystem/job/proc/select_substitute_rank()
	//Try assistant first
	var/datum/job/A = SSjob.GetJob("Assistant")
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

	if (istype(speaker, /mob/living/carbon/human))
		var/mob/living/carbon/human/speakerMob = speaker
		job = speakerMob.get_assignment("", "")
	else if (istype(speaker, /atom/movable/virtualspeaker))
		var/atom/movable/virtualspeaker/VS = speaker
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

/client/proc/browse_rank_configs(path = "config/ranks/")
	path = browse_files(path)
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