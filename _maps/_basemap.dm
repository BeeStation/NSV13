//#define LOWMEMORYMODE //uncomment this to load centcom and runtime station and thats it.

#include "map_files\generic\CentCom.dmm"

#ifndef LOWMEMORYMODE
	#ifdef ALL_MAPS
		#include "map_files\Mining\Lavaland.dmm"
		#include "map_files\debug\runtimestation.dmm"
<<<<<<< HEAD
		#include "map_files\Deltastation\DeltaStation2.dmm"
		#include "map_files\MetaStation\MetaStation.dmm"
		#include "map_files\PubbyStation\PubbyStation.dmm"
		#include "map_files\BoxStation\BoxStation.dmm"
		#include "map_files\Donutstation\Donutstation.dmm"
		#include "map_files\KiloStation\KiloStation.dmm"
=======
		#include "map_files\Aegis\aegis1.dmm"
		#include "map_files\Aegis\aegis2.dmm"
		#include "map_files\Aegis\aegis3.dmm"
		#include "map_files\Aegis\ao1.dmm"
		#include "map_files\Aegis\ao2.dmm"
		#include "map_files\Aegis\ao3.dmm"
		#include "map_files\Valkyrie\Valkyrie.dmm"
		#include "map_files\Hammerhead\Hammerhead.dmm"
>>>>>>> 6019aa33c0e954c94587c43287536eaf970cdb36

		#ifdef TRAVISBUILDING
			#include "templates.dm"
		#endif
	#endif
#endif
