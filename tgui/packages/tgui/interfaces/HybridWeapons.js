// NSV13

import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, ProgressBar, Slider } from '../components';
import { Window } from '../layouts';
import { toFixed } from 'common/math';

export const HybridWeapons = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window resizable
      theme="ntos"
      width={560}
      height={600}>
      <Window.Content scrollable>
        <Section title="Weapon system controls:">
          <Button
            fluid
            icon={data.loaded ? "check-circle" : "square-o"}
            width="100"
            selected={data.loaded}
            content="I1 - Payload loaded"
            onClick={() => act('toggle_load')}
          />
          <Button
            fluid
            icon={data.chambered ? "check-circle" : "square-o"}
            width="100"
            selected={data.chambered}
            content="I2 - Payload chambered"
            onClick={() => act('chamber')}
          />
          <Button
            fluid
            icon={data.safety ? "power-off" : "times"}
            color={data.safety ? "green" : "red"}
            content="I3 - Weapon safeties"
            onClick={() => act('toggle_safety')}
          />
          <Button
            fluid
            icon="cog"
            color={data.slug_shell ? "orange" : "yellow"}
            content={data.slug_shell ? "I4 - Configuration: Shell Type" : "I4 - Configuration: Slug Type"}
            onClick={() => act('switch_type')}
          />
          <br />
          <Section title="Capacitor:">
            <Section title="Current Charge:">
              <ProgressBar
                value={data.capacitor_charge / data.capacitor_max_charge}
                ranges={{
                  good: [0.99, Infinity],
                  average: [0.5, 0.99],
                  bad: [-Infinity, 0.5],
                }} />
            </Section>
            <Section title="Power Allocation (Watts):">
              <Slider
                value={data.capacitor_current_charge_rate}
                minValue={0}
                maxValue={data.capacitor_max_charge_rate}
                step={1}
                stepPixelSize={0.0031}
                onDrag={(e, value) => act('capacitor_current_charge_rate', {
                  adjust: value,
                })} />
              <Section title="Available Power (Watts):">
                <ProgressBar
                  value={data.available_power}
                  minValue={0}
                  maxValue={2e+5}
                  color="yellow">
                  {toFixed(data.available_power)}
                </ProgressBar>
              </Section>
            </Section>
            <br />
            <Section title="Statistics:">
              <Section title="Ammunition:">
                <ProgressBar
                  value={(data.ammo/data.max_ammo * 100)* 0.01}
                  ranges={{
                    good: [0.5, Infinity],
                    average: [0.15, 0.5],
                    bad: [-Infinity, 0.15],
                  }} />
              </Section>
              <Section title="Gun condition:">
                <ProgressBar
                  value={(data.maint_req/25 * 100)* 0.01}
                  ranges={{
                    good: [0.5, Infinity],
                    average: [0.15, 0.5],
                    bad: [-Infinity, 0.15],
                  }} />
              </Section>
              <Section title="Magnetic Alignment:">
                <ProgressBar
                  value={data.alignment* 0.01}
                  ranges={{
                    good: [0.5, Infinity],
                    average: [0.15, 0.5],
                    bad: [-Infinity, 0.15],
                  }} />
              </Section>
            </Section>
          </Section>
        </Section>
      </Window.Content>
    </Window>
  );
};
