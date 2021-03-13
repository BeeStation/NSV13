import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, ProgressBar, Slider } from '../components';
import { Window } from '../layouts';

export const HybridWeapons = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window resizable theme="ntos">
      <Window.Content>
        {!sudo_mode && (
          <Section title="Weapon system controls:">
            <Button
              fluid
              icon={loaded ? "check-circle" : "square-o"}
              width="100"
              selected={loaded}
              content="I1 - Payload loaded"
              onClick={() => act('toggle_load')}
            />
            <Button
              fluid
              icon={chambered ? "check-circle" : "square-o"}
              width="100"
              selected={chambered}
              content="I2 - Payload chambered"
              onClick={() => act('chamber')}
            />
            <Button
              fluid
              icon={safety ? "power-off" : "times"}
              color={safety ? "green" : "red"}
              content="I3 - Weapon safeties"
              onClick={() => act('toggle_safety')}
            />
            <Section title="Capacitor:">
              <Section title="Current Charge:">
                <ProgressBar
                  value={}
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
                  stepPixelSize={0.0002}
                  onDrag={(e, value) => act('capacitor_charge_rate', {
                    adjust: value,
                  })} />
              <Section title="Available Power (Watts):">
                <ProgressBar
                  value={availablePower}
                  minValue={0}
                  maxValue={1e+6}
                  color="yellow">
                  {toFixed(availablePower)}
                </ProgressBar>
              </Section>
            </Section>
            <Section title="Statistics:">
              <Section title="Ammunition:">
                <ProgressBar
                  value={(ammo/max_ammo * 100)* 0.01}
                  ranges={{
                    good: [0.5, Infinity],
                    average: [0.15, 0.5],
                    bad: [-Infinity, 0.15],
                  }} />
              </Section>
              <Section title="Gun condition:">
                <ProgressBar
                  value={(maint_req/25 * 100)* 0.01}
                  ranges={{
                    good: [0.5, Infinity],
                    average: [0.15, 0.5],
                    bad: [-Infinity, 0.15],
                  }} />
              </Section>
              <Section title="Magnetic Alignment:">
                <ProgressBar
                  value={(maint_req/25 * 100)* 0.01}
                  ranges={{
                    good: [0.5, Infinity],
                    average: [0.15, 0.5],
                    bad: [-Infinity, 0.15],
                  }} />
              </Section>
            </Section>
          </Section>
        ) || (
          <Section title="Weapon linking:">
            <Button
              fluid
              icon="search"
              content="Auto-link to nearby weapons"
              onClick={() => act('search')}
            />
            <Button
              fluid
              icon={tool_buffer ? "link" : "square-o"}
              selected={tool_buffer}
              content={`Link to: ${tool_buffer_name}`}
              onClick={() => act('link')}
            />
            <Button
              fluid
              icon={tool_buffer ? "exclamation-triangle" : "square-o"}
              color={tool_buffer ? "bad" : null}
              content={`Clear multitool buffer: ${tool_buffer_name}`}
              onClick={() => act('fflush')}
            />
            <Button
              fluid
              icon={has_linked_gun ? "check-circle" : "square-o"}
              selected={has_linked_gun}
              content="Weapon linked."
              onClick={() => act('unlink')}
            />
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
