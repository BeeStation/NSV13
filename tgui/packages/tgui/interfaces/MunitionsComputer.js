import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Button, Section, ProgressBar } from '../components';
import { Window } from '../layouts';

export const MunitionsComputer = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    loaded,
    chambered,
    charge,
    safety,
    ammo,
    max_ammo,
    isgaussgun,
    maint_req,
    max_maint_req,
    sudo_mode,
    tool_buffer,
    tool_buffer_name,
    has_linked_gun,
  } = data;
  return (
    <Window
      resizable
      theme="hackerman"
      width={560}
      height={600}>
      <Window.Content>
        {!sudo_mode && (
          <Section title="Weapon system controls:">
            <Button
              fluid
              icon={loaded ? "check-circle" : "square-o"}
              width="100"
              selected={loaded}
              content="I1 - Payload loaded"
              onClick={() => act('toggle_load')}
            />
            <Button
              fluid
              icon={chambered ? "check-circle" : "square-o"}
              width="100"
              selected={chambered}
              content="I2 - Payload chambered"
              onClick={() => act('chamber')}
            />
            <Button
              fluid
              icon={safety ? "power-off" : "times"}
              color={safety ? "green" : "red"}
              content="I3 - Weapon safeties"
              onClick={() => act('toggle_safety')}
            />
            {!!isgaussgun && (
              <Button
                fluid
                icon={data.canReload ? "power-off" : "square-o"}
                color={data.canReload ? "green" : "red"}
                content="I4 - Reload Rack"
                onClick={() => act('load')}
              />
            )}
            <Section title="Statistics:">
              <Section title="Ammunition:">
                <ProgressBar
                  value={(ammo/max_ammo * 100)* 0.01}
                  ranges={{
                    good: [0.5, Infinity],
                    average: [0.15, 0.5],
                    bad: [-Infinity, 0.15],
                  }} />
              </Section>
              <Section title="Gun condition:">
                <ProgressBar
                  value={(maint_req/25 * 100)* 0.01}
                  ranges={{
                    good: [0.5, Infinity],
                    average: [0.15, 0.5],
                    bad: [-Infinity, 0.15],
                  }} />
              </Section>
            </Section>
          </Section>
        ) || (
          <Section title="Weapon linking:">
            <Button
              fluid
              icon="search"
              content="Auto-link to nearby weapons"
              onClick={() => act('search')}
            />
            <Button
              fluid
              icon={tool_buffer ? "link" : "square-o"}
              selected={tool_buffer}
              content={`Link to: ${tool_buffer_name}`}
              onClick={() => act('link')}
            />
            <Button
              fluid
              icon={tool_buffer ? "exclamation-triangle" : "square-o"}
              color={tool_buffer ? "bad" : null}
              content={`Clear multitool buffer: ${tool_buffer_name}`}
              onClick={() => act('fflush')}
            />
            <Button
              fluid
              icon={has_linked_gun ? "check-circle" : "square-o"}
              selected={has_linked_gun}
              content="Weapon linked."
              onClick={() => act('unlink')}
            />
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
