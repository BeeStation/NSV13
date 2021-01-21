//#define LOWMEMORYMODE //uncomment this to load centcom and runtime station and thats it.

#include "map_files\generic\CentCom.dmm"

#ifndef LOWMEMORYMODE
	#ifdef ALL_MAPS
		//Debug/Special Maps
		#include "map_files\Mining\Lavaland.dmm"
		#include "map_files\debug\runtimestation.dmm"

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

		//Eclipse
		#include "map_files\Eclipse\Eclipse1.dmm"
		#include "map_files\Eclipse\Eclipse2.dmm"

		#ifdef CIBUILDING
			#include "templates.dm"
		#endif
	#endif
#endif
