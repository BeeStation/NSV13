import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, ProgressBar, Slider } from '../components';
import { Window } from '../layouts';

export const FTLSilo = (props, context) => {
  const { act, data } = useBackend(context);
  const PowerStr = (data.current_power > 1000 ? data.current_power / 1000 + ' MW' : data.current_power + ' KW');
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
            <Button
              color={data.converting ? "green" : "average"}
              icon={data.converting ? "times" : "square-o"}
              disabled={!data.active}
              content={"Switch to " + (data.converting ? "refining" : "output") + "mode"}
              onClick={() => act('toggle_mode')} />
            <br />
            Power Allocation
            <Slider
              value={data.target_power}
              fillValue={data.current_power}
              minValue={data.min_power}
              maxValue={data.max_power}
              step={10}
              stepPixelSize={1}
              onDrag={(e, value) => act('target_power', {
                target: value,
              })}>
              {PowerStr}
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
            Vessel Integrity: <b>{data.integrity}%</b>
          </Section>
        </Section>
      </Window.Content>
    </Window>
  );
};
