//For code/controllers/subsystem/job.dm
/datum/controller/subsystem/job/proc/LoadRanks(rankfile="config/ranks/military.txt")
	if (fexists("[rankfile]"))
		var/rankstext = file2text("[rankfile]")
		for(var/datum/job/J in occupations)
			var/regex/jobs = new("[J.title]=(.+)")
			jobs.Find(rankstext)
			J.display_rank = "[jobs.group[1] ? jobs.group[1] : ""]"

//For code/game/say.dm - show ranks in speech
/atom/movable/proc/compose_rank(atom/movable/speaker)
	if (!CONFIG_GET(flag/show_ranks))
		return

	var/job
	var/rank = ""

	if (istype(speaker, /mob/living/carbon/human))
		var/mob/living/carbon/human/speakerMob = speaker
		job = speakerMob.get_assignment()
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