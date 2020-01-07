//For code/controllers/subsystem/job.dm
/datum/controller/subsystem/job/proc/LoadRanks()
	var/rankfile = "[global.config.directory]/ranks/[CONFIG_GET(string/rank_file)]"
	message_admins("Rankfile is [rankfile]")

	if (fexists("[rankfile]"))
		var/rankstext = file2text("[rankfile]")
		for(var/datum/job/J in occupations)
			var/regex/jobs = new("[J.title]=(.+)")
			jobs.Find(rankstext)
			J.display_rank = jobs.group[1]

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
		rank = "[J? J.get_rank() : ] "

	return rank