// NSV13

import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, Slider, LabeledList, Flex, Labeledlist, Section } from '../components';
import { Window } from '../layouts';

export const OvermapGamemodeController = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      resizable
      theme="ntos"
      width={640}
      height={800}>
      <Window.Content scrollable>
        <Section title="Overmap Gamemode Control Panel">
          <Flex spacing={1}>
            <Flex.Item width="600px">
              <Section>
                <LabeledList>
                  <LabeledList.Item label="Current Gamemode">
                    {data.current_gamemode}
                    <br /><br />
                    {data.current_description}
                    <br /><br />
                    <Button
                      icon="shield-alt"
                      content={data.mode_initalised ? "Unable To Change Gamemode" : "Change Gamemode"}
                      color={data.mode_initalised ? "grey" : "green"}
                      onClick={() => act('change_gamemode')} />
                  </LabeledList.Item>
                  <br />
                  <LabeledList.Item label="Difficulty">
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
                  </LabeledList.Item>
                  <br />
                  <LabeledList.Item label="Reminder">
                    <Flex spacing={1}>
                      <Flex.Item width="220px">
                        Next Reminder: {data.reminder_time_remaining} Seconds
                        <br />
                        <br />
                        Reminder Interval: {data.reminder_interval} Minutes
                        <br />
                        <br />
                        Reminder Stacks: {data.reminder_stacks}
                      </Flex.Item>
                      <Flex.Item width="220px">
                        <Button
                          icon={data.toggle_reminder ? "check" : "times"}
                          content={data.toggle_reminder ? "Enable Reminder" : "Disable Reminder"}
                          color={data.toggle_reminder ? "green" : "red"}
                          onClick={() => act('toggle_reminder')} />
                        <Button
                          icon="stopwatch"
                          content="Extend Reminder"
                          color="green"
                          onClick={() => act('extend_reminder')} />
                        <Button
                          icon="hourglass-start"
                          content="Reset Stacks"
                          color="green"
                          onClick={() => act('reset_stage')} />
                      </Flex.Item>
                    </Flex>
                  </LabeledList.Item>
                  <LabeledList.Item label="Other">
                    <Button
                      icon="ghost"
                      content="Spawn Ghost Ship"
                      color="orange"
                      onClick={() => act('spawn_ghost_ship')} />
                    <Button
                      icon={data.toggle_ghost_ships ? "check" : "times"}
                      content={data.toggle_ghost_ships ? "Enable Ghost Ships" : "Disable Ghost Ships"}
                      color={data.toggle_ghost_ships ? "green" : "red"}
                      onClick={() => act('toggle_ghost_ships')} />
                    <Button
                      icon={data.toggle_ghost_boarders ? "check" : "times"}
                      content={data.toggle_ghost_boarders ? "Enable Ghost Boarders" : "Disable Ghost Boarders"}
                      color={data.toggle_ghost_boarders ? "green" : "red"}
                      onClick={() => act('toggle_ghost_boarders')} />
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            </Flex.Item>
          </Flex>
        </Section>
        <Section>
          <Flex spacing={1}>
            <Flex.Item width="600px">
              <Section title="Objectives:">
                <Button
                  icon={data.toggle_override ? "check" : "times"}
                  content={data.toggle_override ? "Enable Objective Completion" : "Disable Objective Completion"}
                  color={data.toggle_override ? "green" : "red"}
                  onClick={() => act('override_completion')} />
                <br />
                <Section>
                  {Object.keys(data.objectives_list).map(key => {
                    let value = data.objectives_list[key];
                    return (
                      <Fragment key={key}>
                        <Section title={`${value.name}`}>
                          {value.desc}: {value.status}
                          <br /><br />
                          <Box mb={1}>
                            <Button
                              icon="search"
                              content="View Vars"
                              color="blue"
                              onClick={() => act('view_vars', { target: value.datum })} />
                            <Button
                              icon="exchange-alt"
                              content="Change State"
                              color="green"
                              onClick={() => act('change_objective_state', { target: value.datum })} />
                            <Button
                              icon="minus"
                              content="Remove Objective"
                              color="red"
                              onClick={() => act('remove_objective', { target: value.datum })} />
                          </Box>
                        </Section>
                      </Fragment>
                    );
                  })}
                </Section>
                <Button
                  icon="plus"
                  content="Add Objective"
                  color="green"
                  onClick={() => act('add_objective')} />
                <Button
                  icon="plus"
                  content="Add Custom Objective"
                  color="green"
                  onClick={() => act('add_custom_objective')} />
              </Section>
            </Flex.Item>
          </Flex>
        </Section>
      </Window.Content>
    </Window >
  );
};
