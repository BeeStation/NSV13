//Nsv13 - Some of our necessary defines. The rest are inline with upstream's files.

#define TRAIT_NODIGEST			"no_digest"
#define TRAIT_SEASICK			"seasick"
#define TRAIT_BINARY_SPEAKER	"speaks_binary"

#define COMSIG_AI_UPDATE_LAWS 	"ai_law_update"
#define COMSIG_MOB_ATTACK_HAND_TURF "mob_attack_hand_turf"	//Called on mob, params: turf

#define MOVESPEED_ID_SWIMMING "SWIMMING_SPEED_MOD"

//Lazy cables
#define CABLE_LAYER_1 "l1"
#define CABLE_LAYER_2 "l2"
#define CABLE_LAYER_3 "l3"

#define WRAP_AROUND_VALUE(value, min, max) ( min + ((value - min) % (max - min)) )
#define COMSIG_ALERT_LEVEL_CHANGE "alert_level_changed" //For general quarters

#define COLOR_PUCE "#CC8899"

#define CONQUEST_ROLE_ADMIRAL "Admiral"
#define CONQUEST_ROLE_CAPTAIN "Captain"
#define CONQUEST_ROLE_BRIDGE "Bridge Staff"
#define CONQUEST_ROLE_REQUISITIONS "Requisitions"
#define CONQUEST_ROLE_TECHNICIAN "Technician"
#define CONQUEST_ROLE_CAG "CAG"
#define CONQUEST_ROLE_PILOT "Pilot"
#define CONQUEST_ROLE_SERGEANT "Sergeant"
#define CONQUEST_ROLE_CLOWN "Clown"
#define CONQUEST_ROLE_LINECOOK "Line Cook"
#define CONQUEST_ROLE_GRUNT "Autofill"

GLOBAL_DATUM_INIT(conquest_role_handler, /datum/conquest_role_handler, new)
