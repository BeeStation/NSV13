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
        { !!data.debug && (
          <Section title="Equipment Loans:">
            {Object.keys(data.loaned_info).map(key => {
              let value = data.loaned_info[key];
              return (
                <Section key={key} title={value.name+" - "+value.squad}>
                  Loaned item:
                  <Button
                    fluid
                    content={value.itemName}
                    icon="box"
                    color={!!value.dangerous && "bad"}
                    tooltip={value.itemContents}
                  />
                  Options:
                  <Button
                    fluid
                    content="Release loan"
                    icon="times"
                    onClick={() => act('releaseLoan', { member_id: value.id })}
                    tooltip="Cancel this loan and allow this person to retrieve another kit." />
                </Section>
              );
            })}
          </Section>
        )}
        <Section title="Available items:">
          {Object.keys(data.categories).map(key => {
            let value = data.categories[key];
            return (
              <Section key={key} title={value.name}>
                <Button
                  fluid
                  content="Vend"
                  icon="eject"
                  onClick={() => act('eject', { item_id: value.id })} />
              </Section>
            );
          })}
        </Section>
      </Window.Content>
    </Window>
  );
};
