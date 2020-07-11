import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, ProgressBar, Slider } from '../components';
import { Window } from '../layouts';

export const ArmourPlatingNanorepairWell = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window resizable theme="ntos">
      <Window.Content scrollable>
        <Section title="Ship Status:">
          Super Structure Integrity:
          <ProgressBar
            value={(data.structural_integrity_current / data.structural_integrity_max)}
            ranges={{
              good: [0.75, Infinity],
              average: [0.25, 0.75],
              bad: [-Infinity, 0.25],
            }} />
          Forward Port Armour:
          <ProgressBar
            value={(data.quadrant_fp_armour_current / data.quadrant_fp_armour_max)}
            ranges={{
              good: [0.66, Infinity],
              average: [0.33, 0.66],
              bad: [-Infinity, 0.33],
            }} />
          Forward Starboard Armour:
          <ProgressBar
            value={(data.quadrant_fs_armour_current / data.quadrant_fs_armour_max)}
            ranges={{
              good: [0.66, Infinity],
              average: [0.33, 0.66],
              bad: [-Infinity, 0.33],
            }} />
          Aft Port Armour:
          <ProgressBar
            value={(data.quadrant_ap_armour_current / data.quadrant_ap_armour_max)}
            ranges={{
              good: [0.66, Infinity],
              average: [0.33, 0.66],
              bad: [-Infinity, 0.33],
            }} />
          Aft Starboard Armour:
          <ProgressBar
            value={(data.quadrant_as_armour_current / data.quadrant_as_armour_max)}
            ranges={{
              good: [0.66, Infinity],
              average: [0.33, 0.66],
              bad: [-Infinity, 0.33],
            }} />
        </Section>
        <Section title="APNW System Status">
          System Load:
          <ProgressBar
            value={data.system_allocation / 100}
            ranges={{
              good: [],
              average: [0.75, 1.5],
              bad: [1.5, Infinity],
            }} />
          System Stress:
          <ProgressBar
            value={data.system_stress / 100}
            ranges={{
              good: [],
              average: [0.75, 1.5],
              bad: [1.5, Infinity],
            }} />
        </Section>
        <Section title="APNW Resourcing Status:">
          Material Processing:
          <br />
          <Button
            content="Iron"
            icon="cog"
            color={data.iron && "white"}
            onClick={() => act('iron')} />
          <Button
            content="Titanium"
            icon="cog"
            color={data.titanium && "white"}
            onClick={() => act('titanium')} />
          <Button
            content="Silver"
            icon="cog"
            color={data.silver && "white"}
            onClick={() => act('silver')} />
          <Button
            content="Plasma"
            icon="cog"
            color={data.plasma && "white"}
            onClick={() => act('plasma')} />
          <Button
            content="Empty Silo"
            icon="exclamation-triangle"
            color={"bad"}
            onClick={() => act('purge')} />
          <br />
          Repair Resources:
          <ProgressBar
            value={data.repair_resources/data.repair_resources_max}
            ranges={{
              good: [0.66, Infinity],
              average: [0.33, 0.66],
              bad: [-Infinity, 0.33],
            }}>
            {data.repair_resources + ' RUs'}
          </ProgressBar>
          Repair Efficiency:
          <ProgressBar
            value={data.repair_efficiency}
            ranges={{
              good: [0.66, Infinity],
              average: [0.33, 0.66],
              bad: [-Infinity, 0.33],
            }} />
          Power Allocation:
          <Slider
            value={data.power_allocation}
            minValue={0}
            maxValue={1000000}
            step={1}
            stepPixelSize={0.0005}
            onDrag={(e, value) => act('power_allocation', {
              adjust: value,
            })} />
        </Section>
      </Window.Content>
    </Window>
  );
};

