/*ALL DEFINES FOR AIS, CYBORGS, AND SIMPLE ANIMAL BOTS*/

#define DEFAULT_AI_LAWID "default"

//NSV13 - Borg Skin Framework - Start
#define SKIN_ICON "skin_icon"
#define SKIN_ICON_STATE "skin_icon_state"
#define SKIN_LIGHT_KEY "skin_light_key"
#define SKIN_HAT_OFFSET "skin_hat_offset"
#define SKIN_FEATURES "skin_features" //for the new system of borg making

/// Cyborgs with unique sprites for when they get totally broken down.
#define R_TRAIT_UNIQUEWRECK	"unique_wreck"

/// To store all the different cyborg modules, instead of creating that for each cyborg.
GLOBAL_LIST_EMPTY(cyborg_module_list)
/// To store all of the different base cyborg module icons, instead of creating them every time the pick_module() proc is called.
GLOBAL_LIST_EMPTY(cyborg_base_modules_icon_list)
/// To store all of the different cyborg module icons, instead of creating them every time the be_transformed_to() proc is called.
GLOBAL_LIST_EMPTY(cyborg_all_modules_icon_list)

//NSV13 - Borg Skin Framework - End

//Bot defines, placed here so they can be read by other things!
#define BOT_STEP_DELAY 4 //Delay between movemements
#define BOT_STEP_MAX_RETRIES 5 //Maximum times a bot will retry to step from its position

#define DEFAULT_SCAN_RANGE		7	//default view range for finding targets.

//Mode defines
#define BOT_IDLE 			0	//!  idle
#define BOT_HUNT 			1	//!  found target, hunting
#define BOT_PREP_ARREST 	2	//!  at target, preparing to arrest
#define BOT_ARREST			3	//!  arresting target
#define BOT_START_PATROL	4	//!  start patrol
#define BOT_PATROL			5	//!  patrolling
#define BOT_SUMMON			6	//!  summoned by PDA
#define BOT_CLEANING 		7	//!  cleaning (cleanbots)
#define BOT_REPAIRING		8	//!  repairing hull breaches (floorbots)
#define BOT_MOVING			9	//!  for clean/floor/med bots, when moving.
#define BOT_HEALING			10	//!  healing people (medbots)
#define BOT_RESPONDING		11	//!  responding to a call from the AI
#define BOT_DELIVER			12	//!  moving to deliver
#define BOT_GO_HOME			13	//!  returning to home
#define BOT_BLOCKED			14	//!  blocked
#define BOT_NAV				15	//!  computing navigation
#define BOT_WAIT_FOR_NAV	16	//!  waiting for nav computation
#define BOT_NO_ROUTE		17	//! no destination beacon found (or no route)

//Bot types
#define SEC_BOT				(1<<0)	//!  Secutritrons (Beepsky) and ED-209s
#define MULE_BOT			(1<<1)	//!  MULEbots
#define FLOOR_BOT			(1<<2)	//!  Floorbots
#define CLEAN_BOT			(1<<3)	//!  Cleanbots
#define MED_BOT				(1<<4)	//!  Medibots
#define HONK_BOT			(1<<5)	//!  Honkbots & ED-Honks
#define FIRE_BOT			(1<<6)  //!  Firebots

//AI notification defines
#define		NEW_BORG     1
#define		NEW_MODULE   2
#define		RENAME       3
#define		AI_SHELL     4
#define		DISCONNECT   5

//Assembly defines
#define ASSEMBLY_FIRST_STEP 	0
#define ASSEMBLY_SECOND_STEP 	1
#define ASSEMBLY_THIRD_STEP     2
#define ASSEMBLY_FOURTH_STEP    3
#define ASSEMBLY_FIFTH_STEP     4

//NSV13 - Start - Navbeacon Refactor
//bot navigation beacon defines
#define NAVBEACON_PATROL_MODE "patrol"
#define NAVBEACON_PATROL_NEXT "next_patrol"
#define NAVBEACON_DELIVERY_MODE "delivery"
#define NAVBEACON_DELIVERY_DIRECTION "dir"
//NSV13 - End
