/// Kind of shitty but bitflags are even more cheesy when you can only have one state at a time.
GLOBAL_LIST_INIT(busy_states, list(STATE_FEEDING, STATE_CHAMBERING, STATE_FIRING))
