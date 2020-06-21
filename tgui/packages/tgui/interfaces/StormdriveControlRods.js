import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section} from '../components';
import { Window } from '../layouts';

export const StormdriveControlRods = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window resizable theme="hackerman">
      <Window.Content scrollable>
        <Section>
          <Section title="Mounted Control Rods:">
            {!!data.control_rod_data && (
              <Section>
                {Object.keys(data.control_rod_data).map(key => {
                  let value = data.control_rod_data[key];
                  return (
                    <Fragment key={key}>
                      <Section title={`${value.name}`}>
                        <Fragment>
                          <Button
                            fluid
                            content={`Examine ${value.name}`}
                            icon="search"
                            ranges={{
                            good: [0.66, Infinity],
                            average: [0.33, 0.66],
                            bad: [-Infinity, 0.33],
                            onClick={() => act('examine', { id: value.id })} />
                          <Button
                            fluid
                            content={`Eject ${value.name}`}
                            icon="eject"
                            onClick={() => act('eject_p', { id: value.id })} />
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
