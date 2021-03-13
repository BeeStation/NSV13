import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, ProgressBar } from '../components';
import { Window } from '../layouts';

export const GaussDispenser = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      resizable
      width={560}
      height={600}>
      <Window.Content scrollable>
        <Section>
          <Section title="Controls:">
            <Button
              fluid
              content="Toggle power"
              color={data.powered ? "good" : "bad"}
              icon="power-off"
              onClick={() => act('toggle_power')} />
            <Button
              fluid
              content="Retrieve ammunition"
              icon="download"
              selected={data.ready}
              disabled={!data.ready}
              onClick={() => act('dispense')} />
          </Section>
          <Section title="Ammunition retrieval status:">
            <ProgressBar
              value={(data.progress/data.goal * 100)* 0.01}
              ranges={{
                good: [0.9, Infinity],
                average: [0.15, 0.9],
                bad: [-Infinity, 0.15],
              }} />
            <br />
          </Section>
        </Section>
      </Window.Content>
    </Window>
  );
};
