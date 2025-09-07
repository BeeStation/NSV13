import { toTitleCase } from 'common/string';
import { useBackend } from '../backend';
import { Box, Button, NumberInput, Section, Table } from '../components';
import { Window } from '../layouts';
import { round, scale } from 'common/math';

export const RailgunCanisterCharger = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    canister_charge,
    canister_name,
    canister_charge_rate,
  } = data;
  return (
    <Window
      width={440}
      height={550}>
      <Window.Content scrollable>
        <Section />
      </Window.Content>
    </Window>
  );
};
