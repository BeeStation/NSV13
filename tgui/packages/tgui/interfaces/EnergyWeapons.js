import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, ProgressBar, Slider } from '../components';
import { Window } from '../layouts';

export const EnergyWeapons = (props, context) => {
  const { act, data } = useBackend(context);
  const maxHealthPriority = data.maxHealthPriority;
  const regenPriority = data.regenPriority;
  const progress = data.progress;
  const goal = data.goal;
  const powerAlloc = data.powerAlloc;
  const maxPower = data.maxPower;
  return (
    <Window resizable theme="ntos">
      <Window.Content scrollable>
        <Section title="Charge Status:"buttons={<Button
          fluid
          content={data.active ? "Disable Charging" : "Enable Charging"}
          icon="charging-station"
          color={data.active && "good"}
          onClick={() => act('activeToggle')} />}>
          <ProgressBar
            value={(progress / goal * 100) * 0.01}
            ranges={{
              good: [0.50, Infinity],
              average: [0.15, 0.50],
              bad: [-Infinity, 0.15],
            }} />
        </Section>
        <Section title="Settings:">
          Overcharge settings:
          <Slider
            value={powerAlloc}
            minValue={0}
            maxValue={maxPower}
            step={0.5}
            stepPixelSize={5}
            onDrag={(e, value) => act('power', {
              input: value,
            })} />
        </Section>
      </Window.Content>
    </Window>
  );
};
