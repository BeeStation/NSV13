#define INTERACTION_JSON_FOLDER "config/interactions/"

// Special values
#define INTERACTION_MAX_CHAR 255
#define INTERACTION_COOLDOWN 1 SECONDS

// If an interaction has this category it will not be shown to players
#define INTERACTION_CAT_HIDE "hide"

// If you add a new requirement you also need to implement its checking. See /datum/interaction/proc/allow_act
#define INTERACTION_REQUIRE_SELF_HAND "self_hand"
#define INTERACTION_REQUIRE_TARGET_HAND "target_hand"

// Interaction Types: Do we do it to ourself or someone else
#define INTERACTION_SELF "self"
#define INTERACTION_OTHER "other"
