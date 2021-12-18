// NSV13

import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, LabeledList, NumberInput, Section } from '../components';
import { Window } from '../layouts';

export const SquadManager = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      resizable
      theme="hackerman"
      width={850}
      height={800}>
      <Window.Content scrollable>
        {Object.keys(data.squads_info).map(key => {
          let value = data.squads_info[key];
          return (
            <Section title={`${value.name}`} key={key} buttons={
              <Fragment>
                <Button
                  content="Message"
                  icon="reply"
                  onClick={() => act('message', { squad_id: value.id })} />
                <Button
                  content={value.primary_objective}
                  color={value.primary_objective ? "good" : "average"}
                  icon="bullseye"
                  tooltip="Set a primary objective for this squad."
                  onClick={() => act('primary_objective', { squad_id: value.id })} />
                <Button
                  content={value.secondary_objective}
                  icon="dot-circle"
                  color={value.secondary_objective ? "good" : "average"}
                  tooltip="Set a secondary objective for this squad."
                  onClick={() => act('secondary_objective', { squad_id: value.id })} />
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
              </Fragment>
            }>
              <p>{value.desc}</p>
              <Section key={key} title={value.squad_leader_name + " (SL)"} buttons={
                <Fragment>
                  <Button
                    content="Reassign"
                    icon={"user-cog"}
                    onClick={() => act('reassign', { id: value.squad_leader_id })} />
                  <Button
                    content="Transfer"
                    icon={"arrows-alt"}
                    onClick={() => act('transfer', { id: value.squad_leader_id })} />
                </Fragment>
              } />
              <Section title="Sergeants:">
                {Object.keys(value.sergeants).map(key => {
                  let member = value.sergeants[key];
                  return (
                    <Section key={key} title={member.name} buttons={
                      <Fragment>
                        <Button
                          content="Reassign"
                          icon={"user-cog"}
                          onClick={() => act('reassign', { id: member.id })} />
                        <Button
                          content="Transfer"
                          icon={"arrows-alt"}
                          onClick={() => act('transfer', { id: member.id })} />
                      </Fragment>
                    } />);
                })}
              </Section>
              <Section title="Engineers:">
                {Object.keys(value.engineers).map(key => {
                  let member = value.engineers[key];
                  return (
                    <Section key={key} title={member.name} buttons={
                      <Fragment>
                        <Button
                          content="Reassign"
                          icon={"user-cog"}
                          onClick={() => act('reassign', { id: member.id })} />
                        <Button
                          content="Transfer"
                          icon={"arrows-alt"}
                          onClick={() => act('transfer', { id: member.id })} />
                      </Fragment>
                    } />);
                })}
              </Section>
              <Section title="Medics:">
                {Object.keys(value.medics).map(key => {
                  let member = value.medics[key];
                  return (
                    <Section key={key} title={member.name} buttons={
                      <Fragment>
                        <Button
                          content="Reassign"
                          icon={"user-cog"}
                          onClick={() => act('reassign', { id: member.id })} />
                        <Button
                          content="Transfer"
                          icon={"arrows-alt"}
                          onClick={() => act('transfer', { id: member.id })} />
                      </Fragment>
                    } />);
                })}
              </Section>
              <Section title="Grunts:">
                {Object.keys(value.grunts).map(key => {
                  let member = value.grunts[key];
                  return (
                    <Section key={key} title={member.name} buttons={
                      <Fragment>
                        <Button
                          content="Reassign"
                          icon={"user-cog"}
                          onClick={() => act('reassign', { id: member.id })} />
                        <Button
                          content="Transfer"
                          icon={"arrows-alt"}
                          onClick={() => act('transfer', { id: member.id })} />
                      </Fragment>
                    } />);
                })}
              </Section>
            </Section>);
        })}
      </Window.Content>
    </Window>
  );
};
