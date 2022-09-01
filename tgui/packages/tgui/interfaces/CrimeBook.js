import { useBackend } from '../backend';
import { Button, Section, Stack, LabeledList, Box, Table } from '../components';
import { Window } from '../layouts';

export const CrimeBook = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    crime_mode_lookup,
    punishment,
  } = data;

  return (
    <Window
      resizable
      width={720}
      height={850}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Stack fill>
              <Stack.Item grow basis={0}>
                <Section
                  title="Suggested Punishments"
                  minWidth="353px">
                  <Punishment pun={punishment} />
                </Section>
              </Stack.Item>
              <Stack.Item grow basis={0}>
                <Section
                  title="Selected Crimes"
                  minWidth="300px">
                  <SelectedCrime crime={crime_mode_lookup} />
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item grow={2} basis={0}>
            <CrimeLibrary />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const CrimeLibrary = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    crime = [],
  } = data;

  return (
    <Section title="Select your crimes!">
      <Table>
        {crime.map(offence => (
          <Table.Row key={offence.name}>
            <Table.Cell bold color="label">
              <Button
                mt={0.5}
                color={offence.level}
                textColor="white"
                content={offence.name}
                onClick={() => act('crime_click', {
                  id: offence.name,
                })} />
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

const SelectedCrime = (props, context) => {
  const { crime } = props;
  const { act } = useBackend(context);
  if (!crime) {
    return <Box>No crimes selected!</Box>
  };

  return (
    <LabeledList>
      <LabeledList.Item>
        {crime.map(crimes => (
          <Button
            mt={0.5}
            color={crimes.level}
            textColor="white"
            content={crimes.name}
            onClick={() => act('remove_click', {
              id: crimes.name,
            })} />
        ))}
      </LabeledList.Item>
    </LabeledList>
  );
};

const Punishment = (props, context) => {
  const { pun } = props;
  const { act } = useBackend(context);
  if (!pun) {
    return <Box>No punishments, Yay!</Box>
  }

  return (
    <LabeledList>
      <LabeledList.Item bold label="Sentence">
        {pun.sentence}
      </LabeledList.Item>
      {pun.jail && (
        <LabeledList.Item bold label="Time">
          {pun.jail.time} minutes
        </LabeledList.Item>
      )}
      {pun.fine && (
        <LabeledList.Item bold label="Credit Fine">
          {pun.fine.fine}
        </LabeledList.Item>
      )}
    </LabeledList>
  )
}
