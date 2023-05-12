import { filter, sortBy } from '../../../common/collections';
import { flow } from '../../../common/fp';
import { useBackend, useLocalState } from '../../backend';
import { Button, Collapsible, Icon, Input, LabeledList, NoticeBox, Section, Stack, Box } from '../../components';
import { Window } from '../../layouts';
import { getMostRelevant, getDisplayColor, isJobOrNameMatch } from './helpers';
import type { Trackable, TrackingData } from './types';

export const Tracking = (props, context) => {
  return (
    <Window title="Tracking" width={400} height={550}>
      <Window.Content scrollable>
        <Stack fill vertical>
          <Stack.Item>
            <TrackableSearch />
          </Stack.Item>
          <Stack.Item mt={0.2} grow>
            <Section fill>
              <TrackableContent />
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

/** Controls filtering out the list of trackables via search */
const TrackableSearch = (props, context) => {
  const { act, data } = useBackend<TrackingData>(context);
  const {
    carbon = [],
    simple_mob = [],
  } = data;

  const [searchQuery, setSearchQuery] = useLocalState<string>(
    context,
    'searchQuery',
    ''
  );

  /** Gets a list of Trackables, then filters the most relevant to track */
  const trackMostRelevant = (searchQuery: string) => {
    const mostRelevant = getMostRelevant(searchQuery, [
      carbon,
      simple_mob,
    ]);

    if (mostRelevant !== undefined) {
      act('track', {
        name: mostRelevant.name,
      });
    }
  };

  return (
    <Section>
      <Stack>
        <Stack.Item>
          <Icon name="search" />
        </Stack.Item>
        <Stack.Item grow>
          <Input
            autofocus
            fluid
            onEnter={(e, value) => trackMostRelevant(value)}
            onInput={(e) => setSearchQuery(e.target.value)}
            placeholder="Search..."
            value={searchQuery}
          />
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item>
          <Button
            color="transparent"
            icon="sync-alt"
            onClick={() => act('refresh')}
            tooltip="Refresh"
            tooltipPosition="bottom-start"
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

/**
 * The primary content display for points of interest.
 * Renders a scrollable section replete with subsections for each
 * trackable group.
 */
const TrackableContent = (props, context) => {
  const { data } = useBackend<TrackingData>(context);
  const {
    carbon = [],
    simple_mob = [],
  } = data;
  return (
    <Stack vertical>
      <TrackableSection color="blue" section={carbon} title="Humanoid Organics" />
      <TrackableSection section={simple_mob} title="Non-sapient Organics" />
    </Stack>
  );
};

/**
 * Displays a collapsible with a map of trackable items.
 * Filters the results if there is a provided search query.
 */
const TrackableSection = (
  props: {
    color?: string;
    section: Trackable[];
    title: string;
  },
  context
) => {
  const { color, section = [], title } = props;

  if (!section.length) {
    return null;
  }
  const [searchQuery] = useLocalState<string>(context, 'searchQuery', '');

  const filteredSection: Trackable[] = flow([
    filter<Trackable>((trackable) =>
      isJobOrNameMatch(trackable, searchQuery)
    ),
    sortBy<Trackable>((trackable) => trackable.name.toLowerCase()
    ),
  ])(section);

  if (!filteredSection.length) {
    return null;
  }

  return (
    <Stack.Item>
      <Collapsible
        bold
        color={color ?? 'grey'}
        open={!!color}
        title={title + ` - (${filteredSection.length})`}>
        {filteredSection.map((poi, index) => {
          return <TrackableItem color={color} item={poi} key={index} />;
        })}
      </Collapsible>
    </Stack.Item>
  );
};

/** Renders a trackable button */
const TrackableItem = (
  props: { color?: string; item: Trackable },
  context
) => {
  const { act } = useBackend<TrackingData>(context);
  const { color, item } = props;
  const { role_icon, health, name, ref } = item;

  return (
    <Button
      color={getDisplayColor(item, color)}
      onClick={() => act('track', { name: name })}
      tooltip={(!!health) && <TrackableTooltip item={item} />}
      tooltipPosition="bottom-start">
      {role_icon && (
        <Box inline
          ml={-0.5}
          style={{ "transform": "translateY(2.5px)" }}
          className={`job-icon16x16 job-icon-${role_icon}`} />
      )}
      {nameToUpper(name).slice(0, 44) /** prevents it from overflowing */}
    </Button>
  );
};

/** Displays some info on the mob as a tooltip. */
const TrackableTooltip = (props: { item: Trackable }) => {
  const { item } = props;
  const { name, job, health } = item;

  const displayHealth = !!health && health >= 0 ? `${health}%` : 'Critical';

  return (
    <>
      <NoticeBox textAlign="center" nowrap>
        Last Known Data
      </NoticeBox>
      <LabeledList>
        <>
          {!!name && (
            <LabeledList.Item label="Name">{name}</LabeledList.Item>
          )}
          {!!job && (
            <LabeledList.Item label="Job">{job}</LabeledList.Item>
          )}
          {!!health && (
            <LabeledList.Item label="Health">
              {displayHealth}
            </LabeledList.Item>
          )}
        </>
      </LabeledList>
    </>
  );
};

/**
 * Returns a string with the first letter in uppercase.
 * Unlike capitalize(), has no effect on the other letters
 */
const nameToUpper = (name: string): string =>
  name.replace(/^\w/, (c) => c.toUpperCase());
