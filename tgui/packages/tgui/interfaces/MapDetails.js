import { classes } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Flex, List, LabeledList, Section, Tabs, Table } from '../components';
import { Window } from '../layouts';

export const MapDetails = (props, context) => {
  const { act, data } = useBackend(context);
  const { choices, mapInfo } = data;
  const [
    selectedChoice,
    setSelectedChoice,
  ] = useLocalState(context, 'choice');
  const selectedChoiceData = mapInfo && mapInfo[selectedChoice] || [];

  return (
    <Window
      width={800}
      height={600}>
      <Window.Content>
        <Flex>
          {/* Left side - list of maps to select from and the vote button */}
          <Flex.Item m={1}>
            <Section fill fitted>
              <Tabs vertical>
                {Object.keys(choices).map(choice => (
                  <Tabs.Tab
                    key={choice}
                    selected={choice === selectedChoice}
                    onclick={() => setSelectedChoice(choice)}>
                    {choice} ({choices[choice]})
                  </Tabs.Tab>
                ))}
              </Tabs>
              <Button content="Vote" fluid />
            </Section>
          </Flex.Item>
          {/* Map data pane */}
          <Flex.Item
            position="relative"
            m={1}
            grow={1}
            basis={0}>
            <Section title={selectedChoice}>
              {!!selectedChoice && (
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
                        Mission completion rate: {selectedChoiceData.completionRate}<br />
                        Engine stability: {selectedChoiceData.engineStability}
                      </Table.Cell>
                    </Table.Row>
                  </Table>
                </>
              )}
            </Section>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
