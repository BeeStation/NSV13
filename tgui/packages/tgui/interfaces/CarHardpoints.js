import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, LabeledList, ProgressBar, Section } from '../components';
import { Window } from '../layouts';

export const CarHardpoints = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      resizable
      width={400}
      height={400}>
      <Window.Content scrollable>
        <Section title="Hardpoints:">
          {Object.keys(data.hardpoints).map(key => {
            let value = data.hardpoints[key];
            return (
              <Section title={value.name} key={key}>
                <Button
                  content="Eject"
                  icon="eject"
                  onClick={() => act('remove_hardpoint', { target: value.name })} />
                <Button
                  content="Examine"
                  icon="bullseye"
                  onClick={() => act('interact', { target: value.name })} />
                <ProgressBar
                  value={(value.capacity/value.max_capacity * 100)* 0.01}
                  ranges={{
                    good: [0, 0.25],
                    average: [0.8, 0.9],
                    bad: [0.9, Infinity],
                  }} />
              </Section>);
          })}
        </Section>
        <Section title="Loaded cargo:">
          {Object.keys(data.contents).map(key => {
            let value = data.contents[key];
            return (
              <Button key={key}
                content={value.name}
                icon="search"
              />);
          })}
        </Section>
      </Window.Content>
    </Window>
  );
};
