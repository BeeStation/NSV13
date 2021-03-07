import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section } from '../components';
import { Window } from '../layouts';

export const AmmoSorter = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window resizable theme="retro">
      <Window.Content scrollable>
        <Section>
          {Object.keys(data.racks_info).map(key => {
            let value = data.racks_info[key];
            return (
              <Fragment key={key}>
                <Section title={`${value.name}`}>
                  <Button
                    content="Unload All"
                    icon="eject"
                    color={"good"}
                    disabled={!value.has_loaded}
                    onClick={() => act('unload_all')} />
                  <Button
                    content="Unload Top"
                    icon="arrow-right"
                    color={"good"}
                    disabled={!value.has_loaded}
                    onClick={() => act('release', { id: value.id })} />
                </Section>
              </Fragment>);
          })}
        </Section>
      </Window.Content>
    </Window>
  );
};
