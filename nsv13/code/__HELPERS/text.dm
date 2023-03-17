
/**
*	Range explained:
*	Range coressponds to the index at which to loop around from.
*	For example, a range of 5 means that instead of index 6 being Foxtrot, it will be Alpha-2
*	Range should never be above the list length (26)
**/

/// Converts a number into it's coressponding index in the phonetic alphabet (1 = Alpha, 26 = Zulu by default)
/proc/index2phonetic(index, range = 26)
	// I know it's "Alfa" not "Alpha" but sometimes ignorance is bliss
	var/static/list/nato = list(
		"Alpha",
		"Bravo",
		"Charlie",
		"Delta",
		"Echo",
		"Foxtrot",
		"Golf",
		"Hotel",
		"India",
		"Juliet",
		"Kilo",
		"Lima",
		"Mike",
		"November",
		"Oscar",
		"Papa",
		"Quebec",
		"Romeo",
		"Sierra",
		"Tango",
		"Uniform",
		"Victor",
		"Whiskey",
		"X-ray",
		"Yankee",
		"Zulu"
		)
	if(index > range)
		return nato[index % range] + "-" + num2text(FLOOR(index, range) + 1) // 27 turns into Alpha-2, 53 turns into Alpha-3, etc.
	return nato[index]

/// Converts a number into it's coressponding index in Greek letters (1= Alpha, 24 = Omega by default)
/proc/index2greek(index, range = 24)
	var/static/list/greek = list(
		"Alpha",
		"Beta",
		"Gamma",
		"Delta",
		"Epsilon",
		"Zeta",
		"Eta",
		"Theta",
		"Iota",
		"Kappa",
		"Lambda",
		"Mu",
		"Nu",
		"Xi",
		"Omnicron",
		"Pi",
		"Rho",
		"Sigma",
		"Tau",
		"Upsilon",
		"Phi",
		"Chi",
		"Psi",
		"Omega"
		)
	if(index > range)
		return greek[index % range] + "-" + num2text(FLOOR(index, range) + 1)
	return greek[index]
