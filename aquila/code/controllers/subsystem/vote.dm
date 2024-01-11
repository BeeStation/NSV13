/datum/controller/subsystem/vote/submit_vote(vote)
	. = ..()
	sound_to_playing_players('aquila/sound/misc/Vote.ogg')

// tu nie musimy napisywać całego procu
/datum/controller/subsystem/vote/get_result()
	sound_to_playing_players('aquila/sound/misc/Vote_success.ogg')
	. = ..()

/datum/controller/subsystem/vote/initiate_vote(vote_type, initiator_key, forced=FALSE, popup=FALSE)
	. = ..()
	sound_to_playing_players('aquila/sound/misc/Vote_started.ogg')
