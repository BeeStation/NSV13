import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, ProgressBar } from '../components';
import { Window } from '../layouts';

export const StormdriveControlRods = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      resizable
      theme="hackerman"
      width={560}
      height={600}>
      <Window.Content scrollable>
        <Section>
          <Section title="Installed Control Rods:">
            {!!data.mounted_control_rods && (
              <Section>
                {Object.keys(data.mounted_control_rods).map(key => {
                  let value = data.mounted_control_rods[key];
                  return (
                    <Fragment key={key}>
                      <Section title={`${value.name}`}>
                        <Fragment>
                          <Button
                            fluid
                            content={`Eject ${value.name}`}
                            icon="eject"
                            onClick={() => act('remove_rod', { target: value.id })} />
                          <ProgressBar
                            value={(value.health/value.max_health * 100)*0.01}
                            ranges={{
                              good: [0.66, Infinity],
                              average: [0.33, 0.66],
                              bad: [-Infinity, 0.33],
                            }} />
                        </Fragment>
                      </Section>
                    </Fragment>);
                })}
              </Section>
            )}
          </Section>
        </Section>
      </Window.Content>
    </Window>
  );
};
