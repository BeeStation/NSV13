export type TrackingData = {
  carbon: Trackable[];
  simple_mob: Trackable[];
};

export type Trackable = {
  health?: number;
  job?: string;
  role_icon?: string ;
  name?: string;
  ref: string;
};
