import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section } from '../components';
import { Window } from '../layouts';

export const AmmoSorter = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window resizable theme="hackerman">
      <Window.Content scrollable>
        <Section>
          {Object.keys(data.racks_info).map(key => {
            let value = data.racks_info[key];
            return (
              <Fragment key={key}>
                <Section title={`${value.name}`} buttons={
                  <Fragment>
                    <Button
                      content="Rename"
                      icon="pen"
                      onClick={() => act('rename', { id: value.id })} />
                    <Button
                      content="Unlink"
                      icon="times"
                      color="bad"
                      onClick={() => act('unlink', { id: value.id })} />
                  </Fragment>
                }>
                  <Button
                    content={`Unload ${value.top}`}
                    icon="arrow-right"
                    disabled={!value.has_loaded}
                    onClick={() => act('unload', { id: value.id })} />
                </Section>
              </Fragment>);
          })}
        </Section>
      </Window.Content>
    </Window>
  );
};
