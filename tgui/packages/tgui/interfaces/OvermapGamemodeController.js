import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Slider, LabeledList, Flex, Labeledlist, Section } from '../components';
import { Window } from '../layouts';

export const OvermapGamemodeController = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      resizable
      theme="ntos"
      width={600}
      height={800}>
      <Window.Content scrollable>
        <Section>
          <Section title="Current Gamemode:">
            {data.current_gamemode}
            <br />
            <br />
            <Button
              fluid
              icon="shield-alt"
              content={data.mode_initalised ? "Unable To Change Gamemode" : "Change Gamemode"}
              color={data.mode_initalised ? "grey" : "green"}
              onClick={() => act('change_gamemode')} />
          </Section>
        </Section>
        <Section>
          <Section title="Difficulty">
            Current Global Difficulty: {data.current_difficulty}
            <br />
            <br />
            Adjust Global Difficulty
            <Slider
              value={data.current_escalation}
              minValue={-5}
              maxValue={5}
              step={1}
              stepPixelSize={50}
              onDrag={(e, value) => act('current_escalation', {
                adjust: value,
              })} />
          </Section>
        </Section>
        <Section>
          <Section title="Reminder:">
            <Flex spacing={1}>
              <Flex.Item width="280px">
                <Section>
                  Next Reminder: {data.reminder_time_remaining} Seconds
                  <br />
                  <br />
                  Reminder Interval: {data.reminder_interval} Minutes
                  <br />
                  <br />
                  Reminder Stacks: {data.reminder_stacks}
                </Section>
              </Flex.Item>
              <Flex.Item width="280px">
                <Section>
                  <Button
                    fluid
                    icon="shield-alt"
                    content={data.toggle_reminder ? "Enable Reminder" : "Disable Reminder"}
                    color={data.toggle_reminder ? "green" : "red"}
                    onClick={() => act('toggle_reminder')} />
                  <Button
                    fluid
                    icon="shield-alt"
                    content="Extend Reminder"
                    color="green"
                    onClick={() => act('extend_reminder')} />
                  <Button
                    fluid
                    icon="shield-alt"
                    content="Reset Stage"
                    color="green"
                    onClick={() => act('reset_stage')} />
                </Section>
              </Flex.Item>
            </Flex>
          </Section>
        </Section>
        <Section>
          <Section title="Objectives:">
            <Button
              fluid
              icon="shield-alt"
              content={data.toggle_override ? "Enable Gamemode Completion" : "Disable Gamemode Completion"}
              color={data.toggle_override ? "green" : "red"}
              onClick={() => act('override_completion')} />
            <br />
            <Section>
              {Object.keys(data.objectives_list).map(key => {
                let value = data.objectives_list[key];
                return (
                  <Fragment key={key}>
                    <Section title={`${value.name}`}>
                      {value.desc}
                      {value.status}
                      <Button
                        fluid
                        icon="shield-alt"
                        content="Change State"
                        color="green"
                        onClick={() => act('change_objective_state')} />
                      <Button
                        fluid
                        icon="shield-alt"
                        content="Remove Objective"
                        color="red"
                        onClick={() => act('remove_objective')} />
                    </Section>
                  </Fragment>
                );
              })}
            </Section>
            <Button
              fluid
              icon="shield-alt"
              content="Add Objective"
              color="green"
              onClick={() => act('add_objective')} />
          </Section>
        </Section>
      </Window.Content>
    </Window >
  );
};
