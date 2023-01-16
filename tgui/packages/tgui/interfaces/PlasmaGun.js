import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Button, Section, ProgressBar } from '../components';
import { Window } from '../layouts';
import { toFixed } from 'common/math';

export const PlasmaGun = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window resizable
      theme="ntos"
      width={560}
      height={600}>
      <Window.Content scrollable>
        <Section>
          <Section title="Statistics:">
            <ProgressBar
              value={data.plasma_moles}
              minValue={0}
              maxValue={data.plasma_max_moles}
              ranges={{
                good: [0.99, Infinity],
                average: [0.5, 0.99],
                bad: [-Infinity, 0.5],
              }} />
          </Section>
          <Section title="Weapon system controls:">
            <Button
              fluid
              icon={data.loaded ? "check-circle" : "square-o"}
              width="100"
              selected={data.loaded}
              content="I1 - Payload loaded"
              onClick={() => act('toggle_load')} />
            <Button
              fluid
              icon={data.safety ? "check-circle" : "square-o"}
              width="100"
              selected={data.safety}
              content="I2 - Safety"
              onClick={() => act('toggle_safety')} />
          </Section>
        </Section>
      </Window.Content>
    </Window>
  );
};
