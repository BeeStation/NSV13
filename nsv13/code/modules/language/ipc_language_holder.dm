/// Allows IPCs to speak common and machine language, not every language
/datum/language_holder/ipc
	understood_languages = list(/datum/language/common = list(LANGUAGE_ATOM),
								/datum/language/machine = list(LANGUAGE_ATOM))

	spoken_languages = list(/datum/language/common = list(LANGUAGE_ATOM),
							/datum/language/machine = list(LANGUAGE_ATOM))
