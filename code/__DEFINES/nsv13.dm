//Nsv13 - Some of our necessary defines. The rest are inline with upstream's files.

#define TRAIT_NODIGEST			"no_digest"
#define TRAIT_SEASICK			"seasick"
#define TRAIT_BINARY_SPEAKER	"speaks_binary"
#define TRAIT_MUNITIONS_METABOLISM    "munitions-metabolism" //NSV13
#define TRAIT_MUTATEIMMUNE             "mutate_immune" //NSV13 - IPCs do not get human mutations
#define TRAIT_IPCRADBRAINDAMAGE        "rad_brain_damage" //NSV13 - IPCs take brain damage when exposed to radiation

#define COMSIG_AI_UPDATE_LAWS 	"ai_law_update"

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

#define COMSIG_ATOM_DAMAGE_ACT "comsig_atom_damage_act" //Used when an atom takes damage.

#define PASSDOOR (1<<7) //Can you pass doors?

//Math. Lame.
#define KPA_TO_PSI(A) (A/6.895)
#define PSI_TO_KPA(A) (A*6.895)
#define KELVIN_TO_CELSIUS(A) (A-273.15)
#define MEGAWATTS /1e+6
