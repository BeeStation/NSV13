import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, LabeledList, NumberInput, Section } from '../components';
import { Window } from '../layouts';

export const FighterLauncher = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      resizable
      theme="retro"
      width={500}
      height={600}>
      <Window.Content scrollable>
        <Section>
          {Object.keys(data.launchers_info).map(key => {
            let value = data.launchers_info[key];
            return (
              <Fragment key={key}>
                <Section title={`${value.name}`}>
                  {!!value.mag_locked && (
                    <Fragment>
                      <Button
                        content={`Launch ${value.mag_locked}`}
                        icon="arrow-right"
                        color={"good"}
                        disabled={!value.can_launch}
                        onClick={() => act('launch', { id: value.id })} />
                      <Button
                        content={`Release ${value.mag_locked}`}
                        icon="eject"
                        color={"average"}
                        onClick={() => act('release', { id: value.id })} />
                    </Fragment>
                  )}
                  {!!value.pilot_id && (
                    <Button
                      content={`Message ${value.pilot}`}
                      icon="comments"
                      disabled={!value.msg_cooldown}
                      onClick={() =>
                        act('message', { pilot_id: value.pilot_id })} />
                  )}
                </Section>
              </Fragment>);
          })}
        </Section>
      </Window.Content>
    </Window>
  );
};
