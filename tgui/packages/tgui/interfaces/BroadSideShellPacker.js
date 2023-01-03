// NSV13

import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Table, Section, ProgressBar } from '../components';
import { Window } from '../layouts';

export const BroadSideShellPacker = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      resizable
      width={560}
      height={600}>
      <Window.Content scrollable>
        <Section>
          <Table.Row>
            <Table.Cell collapsing>
              <Section title="Casings:">
                <ProgressBar
                  value={(data.casing_amount/data.amount_to_pack * 100)* 0.01}
                  ranges={{
                    good: [0.5, Infinity],
                    average: [0.15, 0.5],
                    bad: [-Infinity, 0.15],
                  }} />
                <br />
                <Box bold textAlign={"center"}>
                  {data.casing_amount}/{data.amount_to_pack}
                </Box>
              </Section>
            </Table.Cell>
            <Table.Cell collapsing>
              <Section title="Projectile Loads:">
                <ProgressBar
                  value={(data.load_amount/data.amount_to_pack * 100)* 0.01}
                  ranges={{
                    good: [0.5, Infinity],
                    average: [0.15, 0.5],
                    bad: [-Infinity, 0.15],
                  }} />
                <br />
                <Box bold textAlign={"center"}>
                  {data.load_amount}/{data.amount_to_pack}
                </Box>
              </Section>
            </Table.Cell>
          </Table.Row>
          <Section title="Powder Type:">
            <Table.Row>
              <Table.Cell collapsing>
                <Button
                  fluid
                  ellipsis
                  textAlign="center"
                  content="Plasma Charge"
                  color={data.plasma ? "good" : "bad"} />
                <Button
                  fluid
                  ellipsis
                  textAlign="center"
                  content="Eject Plasma Charge"
                  icon="eject"
                  disabled={!(data.plasma)}
                  onClick={() => act('eject_plasma')} />
              </Table.Cell>
              <Table.Cell collapsing>
                <Button
                  fluid
                  ellipsis
                  textAlign="center"
                  content="Gunpowder Charge"
                  color={data.gunpowder ? "good" : "bad"} />
                <Button
                  fluid
                  ellipsis
                  textAlign="center"
                  content="Eject Gunpowder Charge"
                  icon="eject"
                  disabled={!(data.gunpowder)}
                  onClick={() => act('eject_gunpowder')} />
              </Table.Cell>
            </Table.Row>
          </Section>
          <Section title="Controls:">
            <Table.Row>
              <Table.Cell collapsing>
                <Button
                  fluid
                  ellipsis
                  textAlign="center"
                  content="Ready to Pack"
                  color={data.full ? "good" : "bad"} />
                <Button
                  fluid
                  ellipsis
                  textAlign="center"
                  content="Pack Casings"
                  icon="exclamation-triangle"
                  disabled={!(data.full)}
                  onClick={() => act('pack')} />
              </Table.Cell>
            </Table.Row>
          </Section>
        </Section>
      </Window.Content>
    </Window>
  );
};
