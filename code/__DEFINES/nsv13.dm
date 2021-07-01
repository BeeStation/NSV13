//Nsv13 - Some of our necessary defines. The rest are inline with upstream's files.

#define TRAIT_NODIGEST			"no_digest"
#define TRAIT_SEASICK			"seasick"
#define TRAIT_MARINE_METABOLISM "marine-metabolism"
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

#define HARDPOINT_SLOT_PRIMARY "Primary"
#define HARDPOINT_SLOT_SECONDARY "Secondary"
#define HARDPOINT_SLOT_UTILITY "Utility"
#define HARDPOINT_SLOT_ARMOUR "Armour"
#define HARDPOINT_SLOT_DOCKING "Docking Module"
#define HARDPOINT_SLOT_CANOPY "Canopy"
#define HARDPOINT_SLOT_FUEL "Fuel Tank"
#define HARDPOINT_SLOT_ENGINE "Engine"
#define HARDPOINT_SLOT_RADAR "Radar"
#define HARDPOINT_SLOT_OXYGENATOR "Atmospheric Regulator"
#define HARDPOINT_SLOT_BATTERY "Battery"
#define HARDPOINT_SLOT_APU "APU"
#define HARDPOINT_SLOT_FTL "FTL"
#define HARDPOINT_SLOT_UTILITY_PRIMARY "Primary Utility"
#define HARDPOINT_SLOT_UTILITY_SECONDARY "Secondary Utility"

#define ALL_HARDPOINT_SLOTS list(HARDPOINT_SLOT_PRIMARY, HARDPOINT_SLOT_SECONDARY,HARDPOINT_SLOT_UTILITY, HARDPOINT_SLOT_ARMOUR, HARDPOINT_SLOT_FUEL, HARDPOINT_SLOT_ENGINE, HARDPOINT_SLOT_RADAR, HARDPOINT_SLOT_CANOPY, HARDPOINT_SLOT_OXYGENATOR,HARDPOINT_SLOT_DOCKING, HARDPOINT_SLOT_BATTERY, HARDPOINT_SLOT_APU, HARDPOINT_SLOT_FTL)
#define HARDPOINT_SLOTS_STANDARD list(HARDPOINT_SLOT_PRIMARY, HARDPOINT_SLOT_SECONDARY, HARDPOINT_SLOT_ARMOUR, HARDPOINT_SLOT_FUEL, HARDPOINT_SLOT_ENGINE, HARDPOINT_SLOT_RADAR,HARDPOINT_SLOT_CANOPY, HARDPOINT_SLOT_OXYGENATOR,HARDPOINT_SLOT_DOCKING, HARDPOINT_SLOT_BATTERY, HARDPOINT_SLOT_APU, HARDPOINT_SLOT_FTL)
#define HARDPOINT_SLOTS_UTILITY list(HARDPOINT_SLOT_UTILITY_PRIMARY,HARDPOINT_SLOT_UTILITY_SECONDARY, HARDPOINT_SLOT_ARMOUR, HARDPOINT_SLOT_FUEL, HARDPOINT_SLOT_ENGINE, HARDPOINT_SLOT_RADAR,HARDPOINT_SLOT_CANOPY, HARDPOINT_SLOT_OXYGENATOR,HARDPOINT_SLOT_DOCKING, HARDPOINT_SLOT_BATTERY, HARDPOINT_SLOT_APU, HARDPOINT_SLOT_FTL)

#define LOADOUT_DEFAULT_FIGHTER /datum/component/ship_loadout
#define LOADOUT_UTILITY_ONLY /datum/component/ship_loadout/utility

#define ENGINE_RPM_SPUN 8000

#define COMSIG_SHIP_BOARDED "ship_boarded"

//Gaming
#define shares_overmap(A, B) (A.get_overmap() == B.get_overmap())
#define SHARES_OVERMAP_ALLIED(A,B) (A.get_overmap()?.faction == B.get_overmap()?.faction)

#define YEAR_OFFSET 241
