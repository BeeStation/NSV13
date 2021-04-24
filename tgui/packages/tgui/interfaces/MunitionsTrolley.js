import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Button, Section } from '../components';
import { Window } from '../layouts';

export const MunitionsTrolley = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window resizable theme="hackerman">
      <Window.Content scrollable>
        <Section title="Loaded" buttons={
          <Button
            content="Unload All"
            icon="eject"
            onClick={() => act('unload_all')} />
        }>
          {Object.keys(data.loaded).map(key => {
            let value = data.loaded[key];
            return (
              <Fragment key={key}>
                <Button
                  content={`Unload ${value.name}`}
                  icon="arrow-right"
                  onClick={() => act('unload', { id: value.id })} />
              </Fragment>);
          })}
        </Section>
      </Window.Content>
    </Window>
  );
};
