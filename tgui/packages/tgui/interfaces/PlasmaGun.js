import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Button, Section, ProgressBar, Table } from '../components';
import { Window } from '../layouts';
import { toFixed } from 'common/math';


// Forgot to change the Plasma Load to Ammo but I did that now //
// I also removed the old bar //

export const PlasmaGun = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window resizable
      theme="dominion"
      width={560}
      height={600}>
      <Window.Content scrollable>
        <Section>
          <Table.Row>
            <Table.Cell collapsing>
              <Section title="Splines:">
                <ProgressBar
                  value={(100 - data.cooldown) * .01}
                  ranges={{
                    good: [0.5, Infinity],
                    average: [0.15, 0.5],
                    bad: [-Infinity, 0.15],
                  }}
                />
              </Section>
            </Table.Cell>
          </Table.Row>
        </Section>
        <Section>
          <Table.Row>
            <Table.Cell collapsing>
              <Section title="Plasma Capacitor Charge:">
                <ProgressBar
                  value={(data.plasma_moles/data.plasma_moles_max * 100)* 0.01}
                  ranges={{
                    good: [0.5, Infinity],
                    average: [0.15, 0.5],
                    bad: [-Infinity, 0.15],
                  }}
                />
              </Section>
            </Table.Cell>
            <Table.Cell collapsing>
              <Section title="Plasma Load:">
                <ProgressBar
                  value={(data.ammo / data.max_ammo * 100) * 0.01}
                  ranges={{
                    good: [0.5, Infinity],
                    average: [0.15, 0.5],
                    bad: [-Infinity, 0.15],
                  }}
                />
              </Section>
            </Table.Cell>
          </Table.Row>
          <Section title="Field Alignment">
            <ProgressBar
              value={data.alignment * 0.01}
              ranges={{
                good: [0.5, Infinity],
                average: [0.15, 0.5],
                bad: [-Infinity, 0.15],
              }}
            />
          </Section>
          <Section title="Field Integrity:">
            <ProgressBar
              value={data.field_integrity * 0.01}
              ranges={{
                good: [0.5, Infinity],
                average: [0.15, 0.5],
                bad: [-Infinity, 0.15],
              }}
            />
          </Section>
        </Section>
        <Section title="Deterrant System Controls:">
          <Button
            fluid
            icon={data.loaded ? "check-circle" : "square-o"}
            color={data.loaded ? "red" : ""}
            width="100"
            selected={data.loaded}
            content="Condense Phoron Mass"
            onClick={() => act('toggle_load')}
          />
          <Button
            fluid
            icon={data.chambered ? "check-circle" : "square-o"}
            color={data.chambered ? "red" : ""}
            width="100"
            selected={data.chambered}
            content="Commence Magnetic Charge"
            onClick={() => act('chamber')}
          />
          <Button
            fluid
            icon={data.safety ? "power-off" : "times"}
            color={data.safety ? "red" : ""}
            width="100"
            selected={data.safety}
            content="Release Constrictor Field"
            onClick={() => act('toggle_safety')}
          />
        </Section>
      </Window.Content>
    </Window>
  );
};
