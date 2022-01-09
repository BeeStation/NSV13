// NSV13

import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, LabeledList, NumberInput, Section } from '../components';
import { Window } from '../layouts';

export const SquadVendor = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      resizable
      theme="ntos"
      width={600}
      height={800}>
      <Window.Content scrollable>
        <br />
        {!!data.already_loaned && (
          <Section title="You have already withdrawn kit" buttons={
            <Button
              color="average"
              content="Return Loaned Equipment"
              tooltip="Place all loaned equipment in your backpack and click this button to return your gear."
              onClick={() => act('return_gear')}
            />
          } />

        )}
        <Section title="Available kits:">
          {"Welcome " + data.user_name}
          <br />
          {Object.keys(data.kits).map(key => {
            let value = data.kits[key];
            return (
              <Section key={key} title={value.name} buttons={
                <Button
                  disabled={!!data.already_loaned}
                  content="Vend"
                  icon="eject"
                  onClick={() => act('vend', { item_id: value.id })} />
              }>
                {value.desc}

              </Section>
            );
          })}
        </Section>

      </Window.Content>
    </Window>
  );
};
