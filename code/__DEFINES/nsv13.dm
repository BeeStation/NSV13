//Nsv13 - Some of our necessary defines. The rest are inline with upstream's files.

#define TRAIT_NODIGEST			"no_digest"
#define TRAIT_SEASICK			"seasick"
#define COMSIG_AI_UPDATE_LAWS 	"ai_law_update"
#define TRAIT_BINARY_SPEAKER	"speaks_binary"

#define COMSIG_PROCESS_BORGCHARGER_OCCUPANT "living_charge"		//sent from borg recharge stations: (amount, repairs)

//Lazy cables
#define CABLE_LAYER_1 "l1"
#define CABLE_LAYER_2 "l2"
#define CABLE_LAYER_3 "l3"

#define WRAP_AROUND_VALUE(value, min, max) ( min + ((value - min) % (max - min)) )
