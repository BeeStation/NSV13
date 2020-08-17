/**
Simple localisation by Kmc2000!

What is this?
Localisation allows you to translate in-game objects and their descriptions into different languages as you need. I'm building this with our russian friends in mind, which should hopefully make life a bit easier for them.

How do I use this?
Simply "tick" the localisation file (.dm) that you want to use. For each object that you want to change the description on, give it an "apply_localisation()" proc, and then change the names / descriptions as required. Multiple languages at once are as yet unsupported!

Examples can be seen in the other localisation files under this folder.

*/

//Defines for testing purposes, if you want to debug whether things are being localised correctly.
#define LOCALISATION_SUCCESS 1
#define LOCALISATION_FAILURE 0

/atom/Initialize(mapload, ...)
	. = ..()
	apply_localisation() //Override names on creation. You may need to put this on specific items if they initialize their names late...

/**
Template method to translate fields on an object into whatever language you require. This is put on /datum, however /datum does NOT initialize(). If you need to change the localisation of a datum (you shouldn't have to) then you'll need to extend this to /datum/New()
*/

/datum/proc/apply_localisation()
	return LOCALISATION_FAILURE //By default, we don't localise, as our primary language is english.
