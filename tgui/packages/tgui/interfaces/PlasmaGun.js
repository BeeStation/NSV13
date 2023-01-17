import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Button, Section, ProgressBar, Table } from '../components';
import { Window } from '../layouts';
import { toFixed } from 'common/math';

// OWO WHATS THIS? //
// OWO NOTICES YOUR PLASMA GUN //
// OWO POUNCES ON YOUR PLASMA GUN //
// OWO LICKS YOUR PLASMA GUN //

// UwU WHATS THIS? A PLASMA GUN? //
// UwU NOTICES YOUR PLASMA GUN //
// UwU POUNCES ON YOU //
// UwU YIFFS YOU //
// UwU LICKS YOU //
// UwU LICKS YOUR PLASMA GUN //


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
        </Section>
        <Section title="Weapon system controls:">
          <Button
            fluid
            icon={data.loaded ? "check-circle" : "square-o"}
            color={data.loaded ? "red" : ""}
            width="100"
            selected={data.loaded}
            content="Condense Plasma Mass"
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
