import { BooleanLike } from '../../common/react';
import { useBackend } from '../backend';
import { Box, Button, Table, Section, ProgressBar } from '../components';
import { Window } from '../layouts';

type BroadSideShellPackerData = {
  casing_amount: number,
  load_amount: number,
  amount_to_pack: number,
  plasma: BooleanLike,
  gunpowder: BooleanLike,
  full: BooleanLike,
};

export const BroadSideShellPacker = (props, context) => {
  const { act, data } = useBackend<BroadSideShellPackerData>(context);
  const {
    casing_amount,
    load_amount,
    amount_to_pack,
    plasma,
    gunpowder,
    full,
  } = data;

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
                  value={(casing_amount/amount_to_pack * 100)* 0.01}
                  ranges={{
                    good: [0.5, Infinity],
                    average: [0.15, 0.5],
                    bad: [-Infinity, 0.15],
                  }} />
                <br />
                <Box bold textAlign={"center"}>
                  {casing_amount}/{amount_to_pack}
                </Box>
              </Section>
            </Table.Cell>
            <Table.Cell collapsing>
              <Section title="Projectile Loads:">
                <ProgressBar
                  value={(load_amount/amount_to_pack * 100)* 0.01}
                  ranges={{
                    good: [0.5, Infinity],
                    average: [0.15, 0.5],
                    bad: [-Infinity, 0.15],
                  }} />
                <br />
                <Box bold textAlign={"center"}>
                  {load_amount}/{amount_to_pack}
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
                  color={plasma ? "good" : "bad"} />
                <Button
                  fluid
                  ellipsis
                  textAlign="center"
                  content="Eject Plasma Charge"
                  icon="eject"
                  disabled={!(plasma)}
                  onClick={() => act('eject_plasma')} />
              </Table.Cell>
              <Table.Cell collapsing>
                <Button
                  fluid
                  ellipsis
                  textAlign="center"
                  content="Gunpowder Charge"
                  color={gunpowder ? "good" : "bad"} />
                <Button
                  fluid
                  ellipsis
                  textAlign="center"
                  content="Eject Gunpowder Charge"
                  icon="eject"
                  disabled={!(gunpowder)}
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
                  color={full ? "good" : "bad"} />
                <Button
                  fluid
                  ellipsis
                  textAlign="center"
                  content="Pack Casings"
                  icon="exclamation-triangle"
                  disabled={!(full)}
                  onClick={() => act('pack')} />
              </Table.Cell>
            </Table.Row>
          </Section>
        </Section>
      </Window.Content>
    </Window>
  );
};
