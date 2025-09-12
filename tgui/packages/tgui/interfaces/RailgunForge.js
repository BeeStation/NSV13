import { toTitleCase } from 'common/string';
import { useBackend } from '../backend';
import { Box, Button, Dropdown, NumberInput, Section, Table } from '../components';
import { Window } from '../layouts';
import { round, scale } from 'common/math';

export const RailgunForge = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    t1_volume,
    t1_alloy_lock,
    t1_processing,
    t1_material,
    t2_volume,
    t2_alloy_lock,
    t2_processing,
    t2_material,
  } = data;
  return (
    <Window
      width={440}
      height={550}>
      <Window.Content scrollable>
        <Section>
          <Button
            // disabled={!data.XYZ} //You can use this to grey out the button entirely if a requirement is or isn't met, like nothing being selected
            content="Print Slug"
            icon="paperclip"
            onClick={() => act('print_slug')} />
          <Button
            content="Print Canister Round"
            icon="tg-air-tank"
            onClick={() => act('print_canister')} />
          <Dropdown // Example of a dropdown menu for selecting materials, I've omitted the alloys here for now
            over // Make the drop down menu go over other elements
            selected={t1_material} // Shows that t1_material is currently selected, the UI should update after ui_act when that proc returns
            options={["Iron", "Silver", "Gold", "Diamond", "Uranium", "Plasma", "Bluespace", "Bananium", "Titanium", "Copper"]}
            onselected={() => act('t1_set_material', { value })} // This is passed to byond in the ui_act proc as the action and params (list) variables
          />
        </Section>
      </Window.Content>
    </Window>
  );
};
