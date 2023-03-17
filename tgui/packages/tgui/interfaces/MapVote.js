import { classes } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import { Button, Flex, LabeledList, Section, Tabs, Table,
  Box,
  Icon,
  Collapsible,
} from '../components';
import { Window } from '../layouts';
import { AdminPanel, TimePanel } from './Vote.js';

export const MapVote = (props, context) => {
  const { act, data } = useBackend(context);
  const { mode, question, lower_admin, choices, selectedChoice, mapvote_banned } = data;
  const [
    selectedChoiceIndex,
    setSelectedChoiceIndex,
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
        {!!lower_admin && <AdminPanel />}
        <TimePanel />
        <Flex>
          <Flex.Item mt={1} mr={1} mb={1}>
            <Section fill fitted>
              <Tabs vertical>
                {choices.map((choice, i) => (
                  <Tabs.Tab
                    key={i}
                    selected={i === selectedChoiceIndex}
                    icon={i === (selectedChoice-1) ? "vote-yea" : ""}
                    onclick={() => {
                      setSelectedChoiceIndex(i);
                      setSelectedChoiceName(choice.name);
                    }}>
                    {choice.name} ({choice.votes})
                  </Tabs.Tab>
                ))}
              </Tabs>
              <Button fluid
                disabled={mapvote_banned === 1}
                onClick={() => {
                  act("vote", {
                    index: selectedChoiceIndex+1,
                  });
                }}>
                Vote
              </Button>
            </Section>
          </Flex.Item>
          <MapData />
        </Flex>
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
      mt={1}
      mb={1}
      grow={1}
      basis={0}>
      <Section title={!!selectedChoiceName && (selectedChoiceName + " by " + selectedChoiceData.mapper)}>
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
                  <Section title="Equipment">
                    {!!selectedChoiceData.equipment && selectedChoiceData.equipment.map(thing => (
                      <>
                        {thing}<br />
                      </>
                    ))}
                  </Section>
                </Table.Cell>
                <Table.Cell>
                  <Section title="Performance History">
                    Missions completed: {selectedChoiceData.successRate}<br />
                    Ships evacuated: {selectedChoiceData.evacRate}<br />
                    On eternal patrol: {selectedChoiceData.lossRate}<br />
                    <br />
                    Engine stability: {selectedChoiceData.engineStability}<br />
                    Hull durability: {selectedChoiceData.durability}
                  </Section>
                </Table.Cell>
              </Table.Row>
            </Table>
          </>
        )}
      </Section>
    </Flex.Item>
  );
};
