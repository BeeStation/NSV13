// firing should always be the highest and progress states should be below their completed states (i.e feeding lower than fed)
// make sure to update the busy_states global variable if adding new states
#define STATE_NOTLOADED 1
// STATE_LOADING isn't here because ship weapons currently using a seperate 'loading' variable. TODO: change that
#define STATE_LOADED 2
#define STATE_FEEDING 3
#define STATE_FED 4
#define STATE_CHAMBERING 5
#define STATE_CHAMBERED 6
#define STATE_FIRING 7

// Maintenance states
#define MSTATE_CLOSED 0
#define MSTATE_UNSCREWED 1
#define MSTATE_UNBOLTED 2
#define MSTATE_PRIEDOUT 3
