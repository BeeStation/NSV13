// NSV13

import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, ProgressBar, Slider, Flex, Table } from '../components';
import { Window } from '../layouts';
import { toFixed } from 'common/math';

export const HybridWeapons = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window resizable
      theme="ntos"
      width={600}
      height={460}>
      <Window.Content scrollable>
        <Section title="Weapon system controls:">
          <Flex spacing={1}>
            <Flex.Item width="250px">
              <Section fill position="relative" height="100%">
                <Button
                  icon={data.loaded ? "check-circle" : "square-o"}
                  width="100"
                  selected={data.loaded}
                  content="I1 - Payload loaded"
                  onClick={() => act('toggle_load')}
                />
                <Button
                  icon={data.chambered ? "check-circle" : "square-o"}
                  width="100"
                  selected={data.chambered}
                  content="I2 - Payload chambered"
                  onClick={() => act('chamber')}
                />
                <Button
                  icon={data.safety ? "power-off" : "times"}
                  color={data.safety ? "green" : "red"}
                  content="I3 - Weapon safeties"
                  onClick={() => act('toggle_safety')}
                />
                <Button
                  icon="cog"
                  color={data.slug_shell ? "orange" : "yellow"}
                  content={data.slug_shell ? "I4 - Configuration: Canister Type" : "I4 - Configuration: Slug Type"}
                  onClick={() => act('switch_type')}
                />
                Structural Integrity: <b>{(data.obj_integ/data.max_obj_integ * 100)}%</b>
                <br />
                Barrel Condition: <b>{(data.maint_req/25 * 100)}%</b>
                <br />
                Magnetic Alignement: <b>{data.alignment}%</b>
              </Section>
            </Flex.Item>
            <Flex.Item width="300px">
              <Section>
                Capacitor Charge:
                <ProgressBar
                  value={data.capacitor_charge / data.capacitor_max_charge}
                  range={{
                    good: [0.99, Infinity],
                    average: [0.5, 0.99],
                    bad: [-Infinity, 0.5],
                  }} />
                Power Allocation (Watts):
                <Slider
                  value={data.capacitor_current_charge_rate}
                  minValue={0}
                  maxValue={data.capacitor_max_charge_rate}
                  step={1}
                  stepPixelSize={0.0031}
                  onDrag={(e, value) => act('capacitor_current_charge_rate', {
                    adjust: value,
                  })} />
                Available Power (Watts):
                <ProgressBar
                  value={data.available_power}
                  minValue={0}
                  maxValue={2e+5}
                  color="yellow">
                  {toFixed(data.available_power)}
                </ProgressBar>
              </Section>
            </Flex.Item>
          </Flex>
        </Section>
        <Section title="Ammunition:">
          <Table.Row fluid>
            {Object.keys(data.magazine).map(key => {
              let value = data.magazine[key];
              return (
                <Table.Cell key={key}>
                  <Section title={`${value.name}`}>
                    Conductivity: <b>{value.conductivity}</b>
                    <br />
                    Density: <b>{value.density}</b>
                    <br />
                    Hardness: <b>{value.hardness}</b>
                    <br />
                    Charge: <b>{value.charge}</b>
                    <br />
                    Integrity: <b>{value.integrity}</b>
                  </Section>
                </Table.Cell>
              );
            })}
          </Table.Row>
        </Section>
      </Window.Content>
    </Window>
  );
};
