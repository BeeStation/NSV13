import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, ProgressBar, Knob } from '../components';
import { Window } from '../layouts';

export const CryogenicFuel = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      resizable
      width={400}
      height={400}>
      <Window.Content scrollable>
        <Section>
          Fuel level:
          <ProgressBar
            value={(data.fuel/data.maxfuel * 100)* 0.01}
            ranges={{
              good: [-Infinity, 0.40],
              average: [0.40, 0.7],
              bad: [0.7, Infinity],
            }} />
          Target fuel level:
          <ProgressBar
            value={(data.targetfuel/data.targetmaxfuel * 100)* 0.01}
            ranges={{
              good: [-Infinity, 0.40],
              average: [0.40, 0.7],
              bad: [0.7, Infinity],
            }} />
          <br />
          <br />
          <Button
            content="Stop fuelling"
            icon="times"
            color="average"
            onClick={() =>
              act('stopfuel')} />
          <Button
            content="Fuel inlet"
            icon={data.transfer_mode ? "power-off" : "square-o"}
            selected={data.transfer_mode}
            onClick={() =>
              act('transfer_mode')} />
        </Section>
      </Window.Content>
    </Window>
  );
};
