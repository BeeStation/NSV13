import { useBackend, useLocalState } from '../backend';
import { Button, Section, Stack, LabeledList, Modal, Dropdown, Tabs, Box, Input, Flex, ProgressBar, Collapsible, Icon, Divider, Table } from '../components';
import { Window, NtosWindow } from '../layouts';

export const CrimeBook = (props, context) => {
  const { act, data } = useBackend(context);

  return (
    <Window
     resizable
     width={560}
     height={600}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item grow basis={0}>
            <CrimeLibrary />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  )
}

const CrimeLibrary = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    crime = [],
  } = data;

  return (
    <Section title="Crimes">
      <Table>
        {crime.map(offence => (
          <Table.Row key={offence.name}>
            <Table.Cell>
              <Section label="Crime">
                {offence.name}
                {offence.desc}
              </Section>
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  )
}
