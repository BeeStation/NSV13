import { classes } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Flex, LabeledList, Section, Tabs, Table } from '../components';
import { Window } from '../layouts';

export const MapDetails = (props, context) => {
  const { act, data } = useBackend(context);
  const { 
    choices = {},
  } = data;
  const [
    selectedChoice,
    setSelectedChoice,
  ] = useLocalState(context, 'choice');
  const selectedChoiceData = choices && choices[selectedChoice] || [];

  return (
    <Window
      width={800}
      height={600}>
      <Window.Content>
        <Flex>
          {/* Left side - list of maps to select from and the vote button */}
          <Flex.Item m={1} mr={1}>
            <Section fill fitted>
              <Tabs vertical>
                {Object.keys(choices).map(choice => (
                  <Tabs.Tab
                    key={choice}
                    selected={choice === selectedChoice}
                    onclick={() => setSelectedChoice(choice)}>
                    {choice} ({choices[choice].votes})
                  </Tabs.Tab>
                ))}
              </Tabs>
              <Button content="Vote" />
            </Section>
          </Flex.Item>
          {/* Map data pane */}
          <Flex.Item
            position="relative"
            grow={1}>
            <Section title={selectedChoice}>
              <Table>
                <Table.Row>
                  {/* Top left - Icon or image */}
                  <Table.Cell>
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
                  </Table.Cell>
                  {/* Top right - class, manufacturer, build date */}
                  <Table.Cell>
                    Ship Class:
                    Manufacturer:
                    Pattern Commission Date:
                  </Table.Cell>
                </Table.Row>
                {/* Middle - pros and cons */}
                <Table.Row>
                  <Table.Cell>
                    Pros
                  </Table.Cell>
                  <Table.Cell>
                    Cons
                  </Table.Cell>
                </Table.Row>
                {/* Loadout and stats */}
                <Table.Row>
                  <Table.Cell>
                    What&apos;s on the map
                  </Table.Cell>
                  <Table.Cell>
                    Dynamic stats
                  </Table.Cell>
                </Table.Row>
              </Table>
            </Section>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
