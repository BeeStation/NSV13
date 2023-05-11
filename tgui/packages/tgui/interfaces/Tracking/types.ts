export type TrackingData = {
  carbon: Array<Trackable>;
  simple_mob: Array<Trackable>;
};

export type Trackable = {
  role_icon?: string;
  name?: string;
  ref: string;
};
