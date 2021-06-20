import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, LabeledList, NumberInput, Section } from '../components';
import { Window } from '../layouts';

export const SquadManager = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      resizable
      theme="retro"
      width={600}
      height={800}>
      <Window.Content scrollable>
        <Section title="Item Squad Re-assignment">
          {Object.keys(data.items_info).map(key => {
            let value = data.items_info[key];
            return (
              <Section key={key} title={value.name}>
                <Button
                  fluid
                  content="Eject"
                  icon="eject"
                  onClick={() => act('eject', { item_id: value.id })} />
                <Button
                  fluid
                  content="Repaint"
                  icon="paint-brush"
                  onClick={() => act('repaint', { item_id: value.id })} />
              </Section>
            );
          })}
        </Section>
        <Section title="Active Squads:">
          {Object.keys(data.squads_info).map(key => {
            let value = data.squads_info[key];
            return (
              <Fragment key={key}>
                <Section title={`${value.name}`}>
                  <Fragment>
                    <Button
                      fluid
                      content="Message Squad"
                      icon="reply"
                      onClick={() => act('message', { id: value.id })} />
                    <Button
                      fluid
                      content={value.squad_type}
                      icon="tasks"
                      onClick={() => act('retask', { id: value.id })} />
                    <Button
                      fluid
                      content={value.orders}
                      icon="bullseye"
                      onClick={() => act('standingorders', { id: value.id })} />
                    {Object.keys(value.members_info).map(key => {
                      let member = value.members_info[key];
                      return (
                        <Fragment key={key}>
                          <Button
                            content={member.isLead ? member.name+" (SL)" : member.name}
                            icon={member.isLead ? "star" : "user-cog"}
                            onClick={() => act('reassign', { member_id: member.id })} />
                        </Fragment>);
                    })}
                  </Fragment>
                </Section>
              </Fragment>);
          })}
        </Section>
      </Window.Content>
    </Window>
  );
};
