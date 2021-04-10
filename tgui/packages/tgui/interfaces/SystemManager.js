import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, LabeledList, NumberInput, Section } from '../components';
import { Window } from '../layouts';

export const SystemManager = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      resizable
      theme="ntos"
      width={400}
      height={400}>
      <Window.Content scrollable>
        {Object.keys(data.systems_info).map(key => {
          let value = data.systems_info[key];
          return (
            <Fragment key={key}>
              <Section title={`${value.name}`} buttons={
                <Button
                  content={"Create fleet here"}
                  icon={"hammer"}
                  onClick={() => act('createFleet', { sys_id: value.sys_id })} />
              }>
                Alignment: {value.alignment}<br />
                System Type: {value.system_type}<br />
                <br />
                {Object.keys(value.fleets).map(key => {
                  let fleet = value.fleets[key];
                  return (
                    <Button key={key}
                      content={fleet.name}
                      icon="space-shuttle"
                      color={fleet.colour}
                      onClick={() => act('jumpFleet', { id: fleet.id })} />
                  );
                })}
              </Section>
            </Fragment>);
        })}
      </Window.Content>
    </Window>
  );
};
