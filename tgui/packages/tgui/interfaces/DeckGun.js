import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Button, Section } from '../components';
import { Window } from '../layouts';

export const DeckGun = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      resizable
      theme="hackerman"
      width={300}
      height={300}>
      <Window.Content scrollable>
        <Section title="Payload:">
          <Button content={data.loaded ? "Eject Shell" : "Feed Shell"}
            icon="exclamation-triangle"
            onClick={() => act('feed')}
          />
          <Button content="Load Shell"
            icon="truck-loading"
            disabled={!(data.loaded)}
            onClick={() => act('load')}
          />
        </Section>
        <Section title="Powder Loaders:">
          {Object.keys(data.parts).map(key => {
            let value = data.parts[key];
            return (
              <Button key={key} content="Pack from loader"
                icon="box"
                disabled={!(value.loaded)}
                onClick={() => act('load_powder', { target: value.id })}
              />
            );
          })}
        </Section>
      </Window.Content>
    </Window>
  );
};
