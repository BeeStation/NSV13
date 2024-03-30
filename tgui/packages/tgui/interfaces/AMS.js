// NSV13

import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Button, NumberInput, Section } from '../components';
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
        <Section title="Target Source:">
          <Button
            content={data.data_source}
            icon="bullseye"
            onClick={() => act('data_source')} />
        </Section>
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
        <Section title="Shots to fire:">
          <NumberInput
            animated
            value={parseInt(data.shot_limit, 10)}
            unit="shots"
            width="125px"
            minValue={1}
            maxValue={100}
            step={1}
            onChange={(e, value) => act('set_shot_limit', {
              shot_limit: value,
            })} />
        </Section>
      </Window.Content>
    </Window>
  );
};
