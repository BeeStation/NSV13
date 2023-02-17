import { classes } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import { Button, Flex, LabeledList, Section, Tabs, Table,
  Box,
  Icon,
  Collapsible,
} from '../components';
import { Window } from '../layouts';

export const MapVote = (props, context) => {
  const { act, data } = useBackend(context);
  const { mode, question, lower_admin, choices, mapInfo } = data;
  const [
    selectedChoice,
    setSelectedChoice,
  ] = useLocalState(context, 'choice');
  const [
    selectedChoiceName,
    setSelectedChoiceName,
  ] = useLocalState(context, 'choiceName');

  return (
    <Window
      theme="generic"
      title={`Vote${
        mode
          ? `: ${
            question
              ? question.replace(/^\w/, c => c.toUpperCase())
              : mode.replace(/^\w/, c => c.toUpperCase())
          }`
          : ""
      }`}
      width={800}
      height={600} >
      <Window.Content overflowY="scroll">
        <Flex>
          <Flex.Item mr={1} mb={1}>
            <Section fill fitted>
              <Tabs vertical>
                {choices.map((choice, i) => (
                  <Tabs.Tab
                    key={i}
                    selected={i === selectedChoice}
                    onclick={() => {
                      setSelectedChoice(i);
                      setSelectedChoiceName(choice.name);
                    }}>
                    {choice.name} ({choice.votes})
                  </Tabs.Tab>
                ))}
              </Tabs>
              <Button
                onClick={() => {
                  act("vote", {
                    index: selectedChoice + props.startIndex + 1,
                  });
                }}>
                Vote
              </Button>
            </Section>
          </Flex.Item>
          <MapData />
        </Flex>
        {!!lower_admin && <AdminPanel />}
        <TimePanel />
      </Window.Content>
    </Window>
  );
};

const MapData = (props, context) => {
  const { data } = useBackend(context);
  const { mapInfo } = data;
  const [
    selectedChoiceName,
    setSelectedChoiceName,
  ] = useLocalState(context, 'choiceName');
  const selectedChoiceData = mapInfo && mapInfo[selectedChoiceName] || [];

  return (
    <Flex.Item
      position="relative"
      mb={1}
      grow={1}
      basis={0}>
      <Section title={selectedChoiceName}>
        {!!selectedChoiceName && (
          <>
            <Section>
              {/* Top left - Icon or image */}
              <Flex direction="row">
                <Flex.Item m={1}>
                  {selectedChoiceData.img ? (
                    <img
                      src={`data:image/jpeg;base64,${selectedChoiceData.img}`}
                      style={{
                        'vertical-align': 'middle',
                        'horizontal-align': 'middle',
                      }} />
                  ) : (
                    <span
                      className={classes([
                        'ship32x32',
                        selectedChoiceData.path,
                      ])}
                      style={{
                        'vertical-align': 'middle',
                        'horizontal-align': 'middle',
                      }} />
                  )}
                </Flex.Item>
                {/* Top right - class, manufacturer, design date */}
                <Flex.Item m={1} mb={5} grow={1}>
                  <LabeledList collapsing>
                    <LabeledList.Item label="Ship Class">
                      {selectedChoiceData.shipClass}
                    </LabeledList.Item>
                    <LabeledList.Item label="Manufacturer">
                      {selectedChoiceData.manufacturer}
                    </LabeledList.Item>
                    <LabeledList.Item label="Pattern Commission Date">
                      {selectedChoiceData.patternDate}
                    </LabeledList.Item>
                  </LabeledList>
                </Flex.Item>
              </Flex>
              {/* Description */}
              {selectedChoiceData.description}
            </Section>
            <Table>
              {/* Middle - pros and cons */}
              <Table.Row>
                <Table.Cell>
                  <Section title="Strengths">
                    {!!selectedChoiceData.strengths && (
                      <ul>
                        {selectedChoiceData.strengths.map(strength => (
                          <li key={strength}>
                            {strength}
                          </li>
                        ))}
                      </ul>
                    )}
                  </Section>
                </Table.Cell>
                <Table.Cell>
                  <Section title="Weaknesses">
                    {!!selectedChoiceData.weaknesses && (
                      <ul>
                        {selectedChoiceData.weaknesses.map(weakness => (
                          <li key={weakness}>
                            {weakness}
                          </li>
                        ))}
                      </ul>
                    )}
                  </Section>
                </Table.Cell>
              </Table.Row>
              {/* Loadout and stats */}
              <Table.Row>
                <Table.Cell>
                  What&apos;s on the map
                </Table.Cell>
                <Table.Cell>
                  % returned / evacuated / destroyed: {selectedChoiceData.successRate}<br />
                  Engine stability: {selectedChoiceData.engineStability} %
                </Table.Cell>
              </Table.Row>
            </Table>
          </>
        )}
      </Section>
    </Flex.Item>
  );
};

// Collapsible panel for admin actions.
const AdminPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const { avm, avr, avmap, voting, upper_admin } = data;
  return (
    <Section mb={1} title="Admin Options">
      <Collapsible title="Start a Vote">
        <Flex basis={0} mt={2} justify="space-between">
          <Flex.Item>
            <Box mb={1}>
              <Button
                disabled={!upper_admin || !avmap}
                onClick={() => act("map")} >
                Map
              </Button>
              {!!upper_admin && (
                <Button.Checkbox
                  ml={1}
                  color="red"
                  checked={!avmap}
                  onClick={() => act("toggle_map")} >
                  Disable{!avmap ? "d" : ""}
                </Button.Checkbox>
              )}
            </Box>
            <Box mb={1}>
              <Button
                disabled={!upper_admin || !avr}
                onClick={() => act("restart")} >
                Restart
              </Button>
              {!!upper_admin && (
                <Button.Checkbox
                  ml={1}
                  color="red"
                  checked={!avr}
                  onClick={() => act("toggle_restart")} >
                  Disable{!avr ? "d" : ""}
                </Button.Checkbox>
              )}
            </Box>
            <Box mb={1}>
              <Button
                disabled={!upper_admin || !avm}
                onClick={() => act("gamemode")} >
                Gamemode
              </Button>
              {!!upper_admin && (
                <Button.Checkbox
                  ml={1}
                  color="red"
                  checked={!avm}
                  onClick={() => act("toggle_gamemode")} >
                  Disable{!avm ? "d" : ""}
                </Button.Checkbox>
              )}
            </Box>
          </Flex.Item>
          <Flex.Item>
            <Button disabled={!upper_admin} onClick={() => act("custom")}>
              Create Custom Vote
            </Button>
          </Flex.Item>
        </Flex>
      </Collapsible>
      <Collapsible title="View Voters">
        <Box mt={2} width="100%" height={6} overflowY="scroll">
          {voting.map(voter => {
            return <Box key={voter}>{voter}</Box>;
          })}
        </Box>
      </Collapsible>
    </Section>
  );
};

// Countdown timer at the bottom. Includes a cancel vote option for admins
const TimePanel = (props, context) => {
  const { act, data } = useBackend(context);
  const { upper_admin, time_remaining } = data;

  return (
    <Section>
      <Flex justify="space-between">
        {!!upper_admin && (
          <Button
            onClick={() => {
              act("cancel");
            }}
            color="red" >
            Cancel Vote
          </Button>
        )}
        <Box fontSize={1.5} textAlign="right">
          Time Remaining: {time_remaining}s
        </Box>
      </Flex>
    </Section>
  );
};
