//#define LOWMEMORYMODE //uncomment this to load centcom and runtime station and thats it.

#include "map_files\generic\CentCom.dmm"

#ifndef LOWMEMORYMODE
	#ifdef ALL_MAPS
		//Debug/Special Maps
		#include "map_files\Mining\Lavaland.dmm"
		#include "map_files\debug\runtimestation.dmm"

		//Hammerhead
		#include "map_files\Hammerhead\Hammerhead.dmm"

		//Aetherwhisp
		#include "map_files\Aetherwhisp\Aetherwhisp2.dmm"
		#include "map_files\Aetherwhisp\Aetherwhisp1.dmm"

		//Gladius
		#include "map_files\Gladius\Gladius1.dmm"
		#include "map_files\Gladius\Gladius2.dmm"

		//Tycoon
		#include "map_files\Tycoon\Tycoon1.dmm"
		#include "map_files\Tycoon\Tycoon2.dmm"

		//Jeppison
		#include "map_files\Jeppison\Jeppison1.dmm"
		#include "map_files\Jeppison\Jeppison2.dmm"

		//Vago
		#include "map_files\Vago\vagodeck1.dmm"
		#include "map_files\Vago\vagodeck2.dmm"

		//Jolly Sausage
		#include "map_files\jollysausage\todger.dmm"
		#ifdef TRAVISBUILDING
			#include "templates.dm"
		#endif
	#endif
#endif
