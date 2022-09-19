// NSV13

import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, LabeledList, Section, Table } from '../components';
import { Window } from '../layouts';

export const SquadManager = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      resizable
      theme="hackerman"
      width={750}
      height={800}>
      <Window.Content scrollable>
        {Object.keys(data.squads_info).map(key => {
          let value = data.squads_info[key];
          return (
            <Section title={`${value.name} - ${value.role}`} key={key} buttons={
              <Fragment>
                <Button
                  content="Message"
                  icon="reply"
                  onClick={() => act('message', { squad_id: value.id })} />
                <Button
                  content={value.access_enabled ? "Full Access" : "No Access"}
                  color={value.access_enabled ? "good" : "average"}
                  icon="id-card"
                  tooltip="Set whether a squad is allowed to use their extended access globally. This usually includes munitions access."
                  onClick={() => act('toggle_access', { squad_id: value.id })} />
                <Button
                  content={value.weapons_clearance ? "Gun Clearance" : "No Gun Clearance"}
                  icon={value.weapons_clearance ? "fist-raised" : "peace"}
                  color={value.weapons_clearance ? "bad" : "good"}
                  tooltip="Toggle whether a squad has access to light arms in the squad vendors. Assault weapons available from the warden."
                  onClick={() => act('toggle_beararms', { squad_id: value.id })} />
              </Fragment>
            }>
              <p>{value.desc}</p>
              <Table tableLayout="auto">
                <Table.Row>
                  <Table.Cell width="50%">
                    <Section title="Primary Orders" buttons={
                      <Button
                        content="Change"
                        color={value.role ? "good" : "average"}
                        icon="bullseye"
                        tooltip="Set a primary objective for this squad."
                        onClick={() => act('primary_objective', { squad_id: value.id })} />
                    }>
                      {!!value.role && value.role}
                    </Section>
                  </Table.Cell>
                  <Table.Cell width="50%">
                    <Section title="Secondary Orders" buttons={
                      <Button
                        content="Change"
                        icon="dot-circle"
                        color={value.secondary_objective ? "good" : "average"}
                        tooltip="Set a secondary objective for this squad."
                        onClick={() => act('secondary_objective', { squad_id: value.id })} />
                    }>
                      {!!value.secondary_objective && value.secondary_objective}
                    </Section>
                  </Table.Cell>
                </Table.Row>
              </Table>
              <Section title="Members" buttons={
                <>
                  <Button
                    content={value.hidden ? "No Autofill" : "Autofill"}
                    icon={value.hidden ? "eye-slash" : "eye"}
                    color={value.hidden ? "bad" : "good"}
                    tooltip="Enable autofill for this squad for new crewmates joining the shift."
                    onClick={() => act('toggle_hidden', { squad_id: value.id })} />
                  <Button
                    content="Print Lanyard"
                    tooltip="Print a lanyard to let someone join a squad. Have them click it in hand, and they'll join the squad!"
                    icon="print"
                    color="good"
                    onClick={() => act('print_pass', { squad_id: value.id })} />
                </>
              }>
                <Table>
                  <Table.Row header>
                    <Table.Cell width="50%">
                      Leader
                    </Table.Cell>
                    <Table.Cell width="50%">
                      Roster
                    </Table.Cell>
                  </Table.Row>
                  <Table.Row>
                    <Table.Cell width="50%">
                      {!!value.squad_leader_id && (
                        <LabeledList>
                          <LabeledList.Item label={value.squad_leader_name}>
                            <Button
                              content="Demote"
                              icon={"user-cog"}
                              onClick={() => act('demote_leader', { id: value.squad_leader_id })} />
                            <Button
                              content="Transfer"
                              icon={"arrows-alt"}
                              onClick={() => act('transfer', { id: value.squad_leader_id })} />
                          </LabeledList.Item>
                        </LabeledList>
                      )}
                    </Table.Cell>
                    <Table.Cell width="50%">
                      <Section>
                        {Object.keys(value.members).map(key => {
                          let member = value.members[key];
                          return (
                            <LabeledList key={key}>
                              {!!member.name && (
                                <LabeledList.Item label={member.name}>
                                  <Button
                                    content="Promote"
                                    icon={"user-cog"}
                                    onClick={() => act('set_leader', { id: member.id })} />
                                  <Button
                                    content="Transfer"
                                    icon={"arrows-alt"}
                                    onClick={() => act('transfer', { id: member.id })} />
                                </LabeledList.Item>
                              )}
                            </LabeledList>);
                        })}
                      </Section>
                    </Table.Cell>
                  </Table.Row>
                </Table>
              </Section>
            </Section>
          );
        })}
      </Window.Content>
    </Window>
  );
};
