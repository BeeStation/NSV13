# Starmap JSON loading
Version: 31/10/2021
Author: kjrm

Please update this file if you change any system props / json keys. This is intended to help people work on starmaps!

## Brief:

The NSV starmap system is capable of parsing a supplied JSON file to create new systems.
As of 31/10/2021, there are still a few hardcoded systems which, unfortunately, are non-negotiable. Such as "outpost 45". Please be careful when doing this by yourself!

I recommend using a beautifier tool such as:
https://codebeautify.org/jsonviewer
Which will let you both validate your json, and print it in a readable format.

Checklist:

- Any systems referenced in adjacency_list by name MUST exist.
- All systems MUST have the <required> props supplied, or the map will not load, and it will fallback to the default, hardcoded map.
- All hardcoded systems must be present, pending removal of this requirement.
- (If using startup_proc) Ensure that startup_proc is defined on parse_startup_proc.
- Ensure the json parses
- Escape all special chars (IE: "") with \

## Format:

The starmap json is simply a json encoded list of lists, where each list represents a system.
Each individual list element is directly serialized into a starsystem object.

An example system would be:

```
{"name":"Sol","desc":null,"threat_level":0,"alignment":"solgov","hidden":0,"system_type":"{\"tag\":\"planet_earth\",\"label\":\"Planetary system\"}","system_traits":5,"is_capital":1,"adjacency_list":"[\"Alpha Centauri\",\"Outpost 45\",\"Ross 154\"]","wormhole_connections":"[]","fleet_type":"/datum/fleet/solgov/earth","x":70,"y":50,"parallax_property":null,"visitable":0,"sector":1,"is_hypergate":0,"preset_trader":null,"audio_cues":"null"}
```

An example (Invalid) map setup COULD be:

```
{"name":"Staging","desc":"Used for round initialisation and admin event staging","threat_level":0,"alignment":"unaligned","hidden":1,"system_type":"null","system_traits":7,"is_capital":0,"adjacency_list":"[]","wormhole_connections":"[]","fleet_type":null,"x":0,"y":0,"parallax_property":null,"visitable":0,"sector":1,"is_hypergate":0,"preset_trader":null,"audio_cues":"null"},{"name":"Sol","desc":null,"threat_level":0,"alignment":"solgov","hidden":0,"system_type":"{\"tag\":\"planet_earth\",\"label\":\"Planetary system\"}","system_traits":5,"is_capital":1,"adjacency_list":"[\"Alpha Centauri\",\"Outpost 45\",\"Ross 154\"]","wormhole_connections":"[]","fleet_type":"/datum/fleet/solgov/earth","x":70,"y":50,"parallax_property":null,"visitable":0,"sector":1,"is_hypergate":0,"preset_trader":null,"audio_cues":"null"}
```

## Props:

Definitions:
	LIST<T> = List containing type (T)
	LIST<K,V> = Assoc list of type K, V (Arbitrary)

Ensure that the following are supplied as keys:

\<required>

	name (STRING, The system's name)
	desc (STRING, A short description of the system, shown upon entering it.)
	x (INT32, The x coordinate position of this system)
	y (INT32, The y coordinate position of this system)
	alignment (STRING, The alignment of the system, as text. Check starmap.dm for support. IE: "nanotrasen", "unaligned")
	hidden (BOOL, is the system visible on the map?)
	sector (INT32, the sector this system is in.)
	adjacency_list (LIST<STRING>, the adjacency matrix of all systems. English: list of all the names of the systems that this sector is joined to.)

\</required>

The rest can be supplied if you wish, otherwise, they have safe default values.

\<optional>

	threat_level (INT32, Threat level, check defines)
	is_capital (BOOL, fluff to display a "capital" label under the system name on the map)
	fleet_type (TYPE, preset starting fleet for this system)
	parallax_property (STRING, Parallax property for this system, IE, the background effect. Check support in starsystem.dm)
	visitable (BOOL, is this system even navigable to?)
	is_hypergate (BOOL, is this system marked as a hypergate?)
	preset_trader (TYPE, typepath of a preset trader to start in this system)
	system_traits (BITFIELD / FLAG, all system traits of this system, check support)
	system_type (LIST, The type of this system, check support)
	audio_cues (LIST<STRING> Music files (media links, URLs), randomly picks one to play when entered.)
	wormhole_connections (LIST<STRING> Any systems connected to this system by wormhole. Shows a different line on the map for this)
	startup_proc ((#DEFINE, STRING) -> FUNC<T>, A string referencing a proc that should be run after this system is created. Specialist systems like The Badlands have extra startup behaviour. Format is: STARSYS_PROC_YOURPROC. This is a very advanced use-case, please be careful! Check starsystem.dm if unsure...)

\</optional>
