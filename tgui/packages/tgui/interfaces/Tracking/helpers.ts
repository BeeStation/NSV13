import { filter } from '../../../common/collections';
import { flow } from '../../../common/fp';
import { HEALTH } from './constants';
import type { Trackable } from './types';

/** Returns the display color for certain health percentages */
const getHealthColor = (health: number) => {
  switch (true) {
    case health > HEALTH.Good:
      return 'good';
    case health > HEALTH.Average:
      return 'average';
    default:
      return 'bad';
  }
};

export const getMostRelevant = (
  searchQuery: string,
  trackables: Trackable[][]
) => {
  const mostRelevant: Trackable = flow([
    // Filters out anything that doesn't match search
    filter<Trackable>((trackable) =>
      isJobOrNameMatch(trackable, searchQuery)
    ),
    // Makes a single Trackables list for an easy search
  ])(trackables.flat())[0];

  return mostRelevant;
};

/**
 * ### getDisplayColor
 * Displays color for buttons based on the health count. Toggleable.
 * @param {Trackable} item - The point of interest.
 * @param {string} color - OPTIONAL: The color to default to.
 */
export const getDisplayColor = (
  item: Trackable,
  color?: string
) => {
  const { health } = item;
  if (typeof health !== 'number') {
    return color ? 'good' : 'grey';
  }
  return getHealthColor(health);
};

/** Checks if a full name or job title matches the search. */
export const isJobOrNameMatch = (
  trackable: Trackable,
  searchQuery: string
) => {
  if (!searchQuery) {
    return true;
  }
  const { name, job } = trackable;

  return (
    name?.toLowerCase().includes(searchQuery?.toLowerCase())
    || job?.toLowerCase().includes(searchQuery?.toLowerCase())
    || false
  );
};
