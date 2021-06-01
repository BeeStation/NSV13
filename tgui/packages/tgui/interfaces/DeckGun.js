import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Button, Section, ProgressBar } from '../components';
import { Window } from '../layouts';

export const DeckGun = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      resizable
      theme="hackerman"
      width={500}
      height={400}>
      <Window.Content scrollable>
        <Section title={`Loaded: ${data.loaded}`} buttons={
          <Button content="Feed Shell"
            icon="exclamation-triangle"
            disabled={!data.can_load}
            onClick={() => act('load')}
          />
        }>
          Shell powder content (dT):
          <ProgressBar
            value={(data.speed / data.max_speed * 100) * 0.01}
            ranges={{
              good: [0.4, Infinity],
              average: [0.15, 0.4],
              bad: [-Infinity, 0.4],
            }} />
          <br />
          Turret Ammunition:
          <ProgressBar
            value={(data.ammo / data.max_ammo * 100) * 0.01}
            ranges={{
              good: [0.4, Infinity],
              average: [0.15, 0.4],
              bad: [-Infinity, 0.4],
            }} />
        </Section>
        {!!data.parts && (
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
        )}
      </Window.Content>
    </Window>
  );
};
