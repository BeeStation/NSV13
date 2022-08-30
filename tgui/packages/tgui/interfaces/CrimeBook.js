import { useBackend, useLocalState } from '../backend';
import { Button, Section, Stack, LabeledList, Modal, Dropdown, Tabs, Box, Input, Flex, ProgressBar, Collapsible, Icon, Divider } from '../components';
import { Window, NtosWindow } from '../layouts';

export const CrimeBook = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    crime,
  } = data;

  return (
    <Window
     resizable
     width={560}
     height={600}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item grow basis={0}>
            <Section
              title="Crime lookup"
              minWidth="300px">
                <LabeledList>
                  <LabeledList.Item label="Crime">
                    {crime.name}
                  </LabeledList.Item>
                  <LabeledList.Item label="Description">
                    {crime.desc}
                  </LabeledList.Item>
                </LabeledList>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  )
}
