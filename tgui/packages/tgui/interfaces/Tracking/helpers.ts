import { filter, sortBy } from '../../../common/collections';
import { flow } from '../../../common/fp';
import type { Trackable } from './types';

export const getMostRelevant = (
  searchQuery: string,
  trackables: Trackable[][]
) => {
  const mostRelevant: Trackable = flow([
    // Filters out anything that doesn't match search
    filter<Trackable>((trackable) =>
      trackable.name?.toLowerCase().includes(searchQuery?.toLowerCase())
    ),
    // Makes a single Trackables list for an easy search
  ])(trackables.flat())[0];

  return mostRelevant;
};
