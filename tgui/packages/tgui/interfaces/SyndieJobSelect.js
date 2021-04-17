import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, LabeledList, NumberInput, Section } from '../components';
import { Window } from '../layouts';

export const SyndieJobSelect = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      resizable
      theme="syndicate"
      width={500}
      height={500}>
      <Window.Content scrollable>
        <Section title="Selected role:">
          <p>{data.selected_role}</p>
        </Section>
        <Section title="Available Roles:">
          {Object.keys(data.roles).map(key => {
            let value = data.roles[key];
            return (
              <Section key={key} title={value.name} buttons={
                <Button
                  content="Select"
                  icon="check-circle"
                  onClick={() => act('select', { role_id: value.id })} />
              }>
                <p>{value.desc}</p>
              </Section>
            );
          })}
        </Section>
      </Window.Content>
    </Window>
  );
};
