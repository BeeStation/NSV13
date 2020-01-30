//#define LOWMEMORYMODE //uncomment this to load centcom and runtime station and thats it.

#include "map_files\generic\CentCom.dmm"

#ifndef LOWMEMORYMODE
	#ifdef ALL_MAPS
		#include "map_files\Mining\Lavaland.dmm"
		#include "map_files\debug\runtimestation.dmm"
		#include "map_files\Aegis\aegis1.dmm"
		#include "map_files\Aegis\aegis2.dmm"
		#include "map_files\Aegis\aegis3.dmm"
		#include "map_files\Aegis\ao1.dmm"
		#include "map_files\Aegis\ao2.dmm"
		#include "map_files\Aegis\ao3.dmm"
		#include "map_files\Valkyrie\valkyrie1.dmm"
		#include "map_files\Valkyrie\valkyrie2.dmm"
		#include "map_files\Valkyrie\valkyrie3.dmm"
		#include "map_files\Hammerhead\Hammerhead.dmm"

		#ifdef TRAVISBUILDING
			#include "templates.dm"
		#endif
	#endif
#endif
