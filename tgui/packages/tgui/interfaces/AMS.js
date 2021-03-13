import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Button, Section } from '../components';
import { Window } from '../layouts';

export const AMS = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      resizable
      theme="hackerman"
      width={500}
      height={500}>
      <Window.Content scrollable>
        <Section title="AMS Modes:">
          {Object.keys(data.categories).map(key => {
            let value = data.categories[key];
            return (
              <Section key={key} title={value.name} buttons={
                <Button
                  content={value.enabled ? "Enabled" : "Disabled"}
                  icon={value.enabled ? "check-circle" : "times"}
                  selected={value.enabled}
                  onClick={() => act('select', { target: value.id })} />
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
