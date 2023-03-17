/* Drive pylon states.
 * defined as strings for tgui use
 * Make sure to change drive tgui accordingly if you ever need to change these
*/
#define PYLON_STATE_OFFLINE "offline"
#define PYLON_STATE_SHUTDOWN "shutdown"
#define PYLON_STATE_STARTING "starting"
#define PYLON_STATE_WARMUP "warmup"
#define PYLON_STATE_SPOOLING "spooling"
#define PYLON_STATE_ACTIVE "active"

// FTL Drive Computer States. (Legacy only)
#define FTL_STATE_IDLE 1
#define FTL_STATE_SPOOLING 2
#define FTL_STATE_READY 3
#define FTL_STATE_JUMPING 4
