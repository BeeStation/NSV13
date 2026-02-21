// NSV13

import { toTitleCase } from 'common/string';
import { useBackend } from '../backend';
import { Box, Button, NumberInput, ProgressBar, Section, Slider, Table } from '../components';
import { Window } from '../layouts';
import { round, scale } from 'common/math';
import { toFixed } from 'common/math';

export const RailgunCanisterCharger = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    canister_charge,
    canister_name,
    canister_charge_rate,
    canister_max_charge_rate,
    canister_integrity,
    charging,
    discharging,
    available_power,
  } = data;
  return (
    <Window
      width={440}
      height={450}>
      <Window.Content scrollable>
        <Section title="Canister Statistics">
          <Button
            content={canister_name ? canister_name : "Nil Canister Detected"}
            icon="exclamation-triangle"
            color={canister_name ? "average" : "bad"}
            onClick={() => act('eject')} />
          <br />
          Canister Integrity:
          <ProgressBar
            value={canister_integrity/100}
            min={0}
            max={100}
            ranges={{
              good: [0.5, Infinity],
              average: [0.2, 0.5],
              bad: [-Infinity, 0.2],
            }} />
          <br />
          Canister Charge:
          <ProgressBar
            value={canister_charge/100}
            min={0}
            max={100}
            ranges={{
              good: [],
              average: [0.5, Infinity],
              bad: [-Infinity, 0.5],
            }} />
        </Section>
        <Section title="Charger Settings">
          Power Allocation (Watts):
          <Slider
            value={canister_charge_rate}
            minValue={0}
            maxValue={canister_max_charge_rate}
            step={1}
            stepPixelSize={0.01}
            onDrag={(e, value) => act('canister_charge_rate', {
              adjust: value,
            })} />
          <br />
          Available Power (Watts):
          <ProgressBar
            value={available_power}
            minValue={0}
            maxValue={1e+6}
            color="yellow">
            {toFixed(available_power)}
          </ProgressBar>
          <br />
          <Button
            content="Charge"
            icon="radiation-alt"
            color={charging && "yellow"}
            onClick={() => act('toggle_charge')} />
          <Button
            content="Discharge"
            icon="radiation-alt"
            color={discharging && "yellow"}
            onClick={() => act('toggle_discharge')} />
        </Section>
      </Window.Content>
    </Window>
  );
};
