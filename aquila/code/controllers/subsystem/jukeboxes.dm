/datum/track
	var/name = "undefined"
	var/path = null
	var/length = null

/datum/jukebox
	var/song_id = null
	var/channel = null
	var/speed_factor = 1
	var/obj/jukebox = null
	var/listeners = list()

SUBSYSTEM_DEF(jukeboxes)
	name = "Jukeboxes"
	wait = 5
	var/list/song_lib = list()
	var/list/song_lib_ranch = list()
	var/list/datum/track/songs = list()
	var/list/datum/jukebox/active_jukeboxes = list()
	var/list/free_channels = list()
	var/falloff = 7

/datum/controller/subsystem/jukeboxes/proc/add_jukebox(obj/jukebox_obj, selection, speed_factor = 1)
	if(selection > songs.len)
		CRASH("[src] tried to play a song with a nonexistant track")
	if(free_channels.len == 0)
		return null
	var/channel = pick(free_channels)
	free_channels -= channel
	active_jukeboxes.len++
	var/datum/jukebox/jukebox = new /datum/jukebox()
	jukebox.song_id = selection
	jukebox.channel = channel
	jukebox.jukebox = jukebox_obj
	jukebox.speed_factor = speed_factor
	active_jukeboxes[active_jukeboxes.len] = jukebox

	var/sound/song_played = sound(songs[jukebox.song_id].path)
	song_played.status = SOUND_MUTE | SOUND_STREAM

	for(var/mob/M in GLOB.player_list)
		if(!M.client)
			continue
		if(!(M.client.prefs.toggles & PREFTOGGLE_SOUND_INSTRUMENTS))
			continue

		M.playsound_local(get_turf(jukebox_obj), null, MUSIC_VOLUME, falloff_distance = falloff, channel = jukebox.channel, S = song_played, frequency = jukebox.speed_factor)
		sleep(5)
	return channel

/datum/controller/subsystem/jukeboxes/proc/remove_jukebox(channel)
	var/datum/jukebox/jukebox = null
	var/id = 1
	for(var/datum/jukebox/i in active_jukeboxes)
		if(i.channel == channel)
			jukebox = i
			break
		id++
	ASSERT(jukebox != null)
	for(var/mob/M in GLOB.player_list)
		if(!M.client)
			continue
		M.stop_sound_channel(channel)
		sleep(5)
	//idk if we have to del the jukebox datum
	active_jukeboxes.Cut(id, id+1)
	free_channels += channel
	return TRUE

/datum/controller/subsystem/jukeboxes/Initialize()
	var/list/tracks = flist("config/jukebox_music/sounds/")
	for(var/S in tracks)
		if(S == "exclude")
			continue
		var/datum/track/T = new()
		T.path = file("config/jukebox_music/sounds/[S]")
		var/list/tokens = splittext(S, "+")
		if(tokens.len != 2)
			warning("failed to load song [S]")
			continue
		T.name = tokens[1]
		T.length = text2num(tokens[2]) * 10 //seconds to deciseconds
		if(T.length == null)
			warning("failed to load song, couldn't load length [S]")
			continue
		songs |= T
		song_lib[T.name] = songs.len
		if(findtext(T.name, "ram") > 0 && findtext(T.name, "ranch") > 0)
			song_lib_ranch[T.name] = songs.len
	song_lib = sortList(song_lib)
	song_lib_ranch = sortList(song_lib_ranch)
	for(var/i in CHANNEL_JUKEBOX_START to CHANNEL_JUKEBOX_END)
		free_channels |= i
	return ..()

/datum/controller/subsystem/jukeboxes/fire()
	if(!active_jukeboxes.len)
		return
	for(var/datum/jukebox/jukebox in active_jukeboxes)
		var/datum/track/juketrack = songs[jukebox.song_id]
		if(!istype(juketrack))
			CRASH("Invalid jukebox track datum.")
		var/obj/jukebox_obj = jukebox.jukebox
		if(!istype(jukebox_obj))
			CRASH("Nonexistant or invalid object associated with jukebox.")
		var/sound/song_played = sound(juketrack.path)

		for(var/mob/M in GLOB.player_list)
			if(!M.client)
				continue

			song_played.status = SOUND_UPDATE | SOUND_STREAM
			if(!(M.client.prefs.toggles & PREFTOGGLE_SOUND_INSTRUMENTS))
				song_played.status |= SOUND_MUTE

			if(jukebox_obj.z != M.z)
				song_played.status |= SOUND_MUTE	//Setting volume = 0 doesn't let the sound properties update at all, which is lame.

			M.playsound_local(get_turf(jukebox_obj), null, MUSIC_VOLUME, falloff_distance = falloff, channel = jukebox.channel, S = song_played, frequency = jukebox.speed_factor)
			CHECK_TICK
	return
