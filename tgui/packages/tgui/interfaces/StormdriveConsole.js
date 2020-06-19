import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, ProgressBar, Slider } from '../components';
import { Window } from '../layouts';
import { toFixed } from 'common/math';

export const StormdriveConsole = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window resizable theme="ntos">
      <Window.Content scrollable>
        <Section>
          <Section 
            title="Control presets:">
            <Fragment>
              <Button
                fluid
                content="AZ-1 - FULL RAISE"
                icon="exclamation-triangle"
                color="bad"
                onClick={() => act('rods_1')} />
              <Button
                fluid
                content="AZ-2 - RAISE"
                icon="temperature-high"
                color="average"
                onClick={() => act('rods_2')} />
              <Button
                fluid
                content="AZ-3 - HALF"
                icon="temperature-low"
                color="brown"
                onClick={() => act('rods_3')} />
              <Button
                fluid
                content="AZ-4 - LOWERED"
                icon="snowflake"
                color="blue"
                onClick={() => act('rods_4')} />
              <Button
                fluid
                content="AZ-5 - SCRAM"
                icon="radiation-alt"
                color="bad"
                onClick={() => act('rods_5')} />
              <Button
                fluid
                content="AZ-6 - MAINTENANCE MODE"
                icon="cog"
                color={data.reactor_maintenance && "green"}
                onClick={() => act('maintenance')} />
              <Button
                fluid
                content="AZ-7 - FUEL DUMP"
                icon="gas-pump"
                color={data.pipe_open && "green"}
                onClick={() => act('pipe')} />
            </Fragment>
          </Section>
          <Section title="Tuning:">
            <Slider
              value={data.control_rod_percent}
              minValue={0}
              maxValue={100}
              step={1}
              stepPixelSize={5}
              onDrag={(e, value) => act('control_rod_percent', {
                adjust: value,
              })} />
          </Section>
          <Section title="Statistics:">
            Heat:
            <ProgressBar
              value={(data.heat/1000 * 100)* 0.01}
              ranges={{
                good: [],
                average: [0.5, 0.7],
                bad: [0.7, Infinity],
              }} >
              {toFixed(data.heat) + ' °C'}
            </ProgressBar>
            Rod Integrity:
            <ProgressBar
              value={(data.rod_integrity/100 * 100)* 0.01}
              ranges={{
                good: [0.9, Infinity],
                average: [0.15, 0.9],
                bad: [-Infinity, 0.15],
              }} />
            Power output:
            <ProgressBar
              value={(data.last_power_produced/data.theoretical_maximum_power)* 0.01}
              ranges={{
                good: [0.9, Infinity],
                average: [0.15, 0.9],
                bad: [-Infinity, 0.15],
              }}>
              {data.last_power_produced/1e+6 + ' MW'}
            </ProgressBar>
            Fuel
            <ProgressBar
              value={(data.fuel/100 * 100)* 0.01}
              ranges={{
                good: [0.9, Infinity],
                average: [0.15, 0.9],
                bad: [-Infinity, 0.15],
              }}>
              {data.fuel + ' mol'}
            </ProgressBar>
          </Section>
        </Section>
      </Window.Content>
    </Window>
  );
};
