import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, ProgressBar, Slider, LabeledList } from '../components';
import { Window } from '../layouts';
import { toFixed } from 'common/math';

export const ArmourPlatingNanorepairWell = (props, context) => {
  const { act, data } = useBackend(context);
  const availablePower = data.available_power;
  return (
    <Window resizable theme="ntos">
      <Window.Content scrollable>
        <Section title="Ship Status:">
          Hull Structural Integrity:
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
            content="Empty Silo"
            icon="exclamation-triangle"
            color={"bad"}
            onClick={() => act('unload')} />
          <Button
            content="Purge RR"
            icon="exclamation-triangle"
            color={"bad"}
            onClick={() => act('purge')} />
          <Button
            content="RR Processing"
            icon="power-off"
            color={data.resourcing && "good"}
            onClick={() => act('toggle')} />
          <br />
          <br />
          Material Silo:
          <br />
          <LabeledList>
            <LabeledList.Item label="Iron">
              <ProgressBar
                value={data.iron}
                minValue={0}
                maxValue={100000}
                color="brown">
                {toFixed(data.iron)}
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Titanium">
              <ProgressBar
                value={data.titanium}
                minValue={0}
                maxValue={100000}
                color="grey">
                {toFixed(data.titanium)}
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Silver">
              <ProgressBar
                value={data.silver}
                minValue={0}
                maxValue={100000}
                color="white">
                {toFixed(data.silver)}
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Plasma">
              <ProgressBar
                value={data.plasma}
                minValue={0}
                maxValue={100000}
                color="purple">
                {toFixed(data.plasma)}
              </ProgressBar>
            </LabeledList.Item>
          </LabeledList>
          <br />
          Alloy Selection:
          <br />
          <Button
            content="Iron"
            icon="cog"
            tooltip="Iron: 100%"
            color={!!data.alloy_t1 && "white"}
            onClick={() => act('iron')} />
          <Button
            content="Ferrotitanium"
            icon="cog"
            tooltip="Iron: 25%, Titanium: 75%"
            color={!!data.alloy_t2 && "white"}
            onClick={() => act('ferrotitanium')} />
          <Button
            content="Durasteel"
            icon="cog"
            tooltip="Iron: 20%, Titanium: 65%, Silver: 15%"
            color={!!data.alloy_t3 && "white"}
            onClick={() => act('durasteel')} />
          <Button
            content="Duranium"
            icon="cog"
            tooltip="Iron: 17.5%, Titanium: 62.5%, Silver: 15%, Plasma: 5%"
            color={!!data.alloy_t4 && "white"}
            onClick={() => act('duranium')} />
          <br />
          <br />
          Repair Resources:
          <br />
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
          Power Allocation (Watts):
          <Slider
            value={data.power_allocation}
            minValue={0}
            maxValue={data.maximum_power_allocation}
            step={1}
            stepPixelSize={0.0005}
            onDrag={(e, value) => act('power_allocation', {
              adjust: value,
            })} />

          Available Power (Watts):
          <ProgressBar
            value={availablePower}
            minValue={0}
            maxValue={1e+6}
            color="yellow">
            {toFixed(availablePower)}
          </ProgressBar>
        </Section>
      </Window.Content>
    </Window>
  );
};

