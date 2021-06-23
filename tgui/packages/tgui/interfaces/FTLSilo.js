import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, ProgressBar, Slider } from '../components';
import { Window } from '../layouts';

export const FTLSilo = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      resizable
      theme="retro"
      width={560}
      height={500}>
      <Window.Content scrollable>
        <Section>
          <Section title="Controls">
            <Button
              color={!!data.active && 'green'}
              icon={data.active ? "times" : "power-off"}
              content="Toggle Power"
              onClick={() => act('toggle_power')} />
            <br />
            Power Allocation
            <Slider
              value={data.target_power}
              fillValue={data.current_power}
              minValue={data.min_power}
              maxValue={data.max_power}
              step={1}
              stepPixelSize={0.1}
              onDrag={(e, value) => act('target_power', {
                target: value,
              })}>
              {data.current_power / 1e+5 + ' KW'}
            </Slider>
          </Section>
          <Section title="Sensors">
            Status: <b>{data.stat}</b>
            <br />
            Internal Pressure
            <ProgressBar
              value={data.pressure}
              ranges={{
                good: [0, 0.2],
                average: [0.21, 0.75],
                bad: [0.76, Infinity],
              }} />
            Vessel Integrity: <b>{data.integrity}</b>
          </Section>
        </Section>
      </Window.Content>
    </Window>
  );
};
