import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section } from '../components';
import { Window } from '../layouts';

export const AmmoSorter = (props, context) => {
  const { act, data } = useBackend(context);
  const [settingsVisible, setSettingsVisible] = useLocalState(context, 'settings', false);
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
                    {(key === "0") && (
                      <Button
                        icon={settingsVisible ? 'times' : 'cog'}
                        selected={settingsVisible}
                        onClick={() => setSettingsVisible(!settingsVisible)} />
                    )}
                    {!!settingsVisible && (
                      <Fragment>
                        <Button
                          content="Rename"
                          icon="pen"
                          onClick={() => act('rename', { id: value.id })} />
                        <Button
                          content="Unlink"
                          icon="trash-alt"
                          color="bad"
                          onClick={() => act('unlink', { id: value.id })} />
                        <Button
                          icon="arrow-up"
                          disabled={(key === "0")}
                          onClick={() => act('moveup', { id: value.id })} />
                        <Button
                          icon="arrow-down"
                          disabled={(key === `${data.racks_info.length - 1}`)}
                          onClick={() => act('movedown', { id: value.id })} />
                      </Fragment>
                    )}
                  </Fragment>
                }>
                  <Button
                    content={`Unload ${value.top}`}
                    icon="sign-out-alt"
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
