// NSV13

import { toTitleCase } from 'common/string';
import { useBackend } from '../backend';
import { Box, Button, NumberInput, ProgressBar, Section, Table } from '../components';
import { Window } from '../layouts';
import { round, scale } from 'common/math';
import { toFixed } from 'common/math';

export const RailgunFiller = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    canister_name,
    gas_moles,
    o2,
    pluox,
    plasma,
    c_plasma,
    trit,
    nucleium,
    canister_gas_moles,
    canister_o2,
    canister_pluox,
    canister_plasma,
    canister_c_plasma,
    canister_trit,
    canister_nucleium,
  } = data;
  return (
    <Window
      width={440}
      height={550}>
      <Window.Content scrollable>
        <Section title="Canister Actions">
          <Button
            content={canister_name ? canister_name : "Nil Canister Detected"}
            icon="exclamation-triangle"
            color={canister_name ? "average" : "bad"}
            onClick={() => act('eject')} />
          <br />
          <Button
            content="Empty Canister"
            icon="exclamation-triangle"
            color={canister_name ? "red" : "gray"}
            onClick={() => act('empty')} />
          <br />
          <Button
            content="Fill Canister"
            icon="gas-pump"
            color={canister_name ? "green" : "gray"}
            onClick={() => act('fill')} />
          <br />
          <Button
            content="Seal Canister"
            icon="cog"
            color={canister_name ? "blue" : "gray"}
            onClick={() => act('seal')} />
          <br />
        </Section>
        <Section title="Canister Gases">
          Total Moles:
          <ProgressBar
            value={canister_gas_moles}
            minValue={0}
            maxValue={80}
            color="white">
            {toFixed(canister_gas_moles)}
          </ProgressBar>
          Oxygen:
          <ProgressBar
            value={canister_o2}
            minValue={0}
            maxValue={80}
            color="blue">
            {toFixed(canister_o2)}
          </ProgressBar>
          Pluoxium:
          <ProgressBar
            value={canister_pluox}
            minValue={0}
            maxValue={80}
            color="olive">
            {toFixed(canister_pluox)}
          </ProgressBar>
          Plasma:
          <ProgressBar
            value={canister_plasma}
            minValue={0}
            maxValue={80}
            color="purple">
            {toFixed(canister_plasma)}
          </ProgressBar>
          Constricted Plasma:
          <ProgressBar
            value={canister_c_plasma}
            minValue={0}
            maxValue={80}
            color="violet">
            {toFixed(canister_c_plasma)}
          </ProgressBar>
          Tritium:
          <ProgressBar
            value={canister_trit}
            minValue={0}
            maxValue={80}
            color="pink">
            {toFixed(canister_trit)}
          </ProgressBar>
          Nucleium:
          <ProgressBar
            value={canister_nucleium}
            minValue={0}
            maxValue={80}
            color="brown">
            {toFixed(canister_nucleium)}
          </ProgressBar>
        </Section>
        <Section title="Input Gases">
          Total Moles:
          <ProgressBar
            value={gas_moles}
            minValue={0}
            maxValue={80}
            color="white">
            {toFixed(gas_moles)}
          </ProgressBar>
          Oxygen:
          <ProgressBar
            value={o2}
            minValue={0}
            maxValue={80}
            color="blue">
            {toFixed(o2)}
          </ProgressBar>
          Pluoxium:
          <ProgressBar
            value={pluox}
            minValue={0}
            maxValue={80}
            color="olive">
            {toFixed(pluox)}
          </ProgressBar>
          Plasma:
          <ProgressBar
            value={plasma}
            minValue={0}
            maxValue={80}
            color="purple">
            {toFixed(plasma)}
          </ProgressBar>
          Constricted Plasma:
          <ProgressBar
            value={c_plasma}
            minValue={0}
            maxValue={80}
            color="violet">
            {toFixed(c_plasma)}
          </ProgressBar>
          Tritium:
          <ProgressBar
            value={trit}
            minValue={0}
            maxValue={80}
            color="pink">
            {toFixed(trit)}
          </ProgressBar>
          Nucleium:
          <ProgressBar
            value={nucleium}
            minValue={0}
            maxValue={80}
            color="brown">
            {toFixed(nucleium)}
          </ProgressBar>
        </Section>
      </Window.Content>
    </Window>
  );
};
