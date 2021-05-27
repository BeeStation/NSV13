import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, ProgressBar } from '../components';
import { Window } from '../layouts';

export const FTLComputerModular = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      resizable
      theme="retro"
      width={560}
      height={400}>
      <Window.Content scrollable>
        <Section>
          <Section title="Pylons:">
            {Object.keys(data.pylons).map(key => {
              let value = data.pylons[key];
              return (
                <Fragment key={key}>
                  <Section title={`Pylon ${value.number}`}>
                    <Button
                      fluid
                      content="Toggle Power"
                      icon={value.enabled ? "sqaure-o" : "power-off"}
                      color={value.shutdown ? "average" : value.enabled ? "good" : "bad"}
                      disabled={value.shutdown}
                      onClick={() => act('pylon_power', { id: value.id })} />
                  </Section>
                </Fragment>);
            })}
            <Button
              content="Find Pylons"
              icon="search"
              onClick={() => act('find_pylons')} />

          </Section>
          <Section
            title="Actions:">
            <Button
              color={!!data.powered && 'green'}
              disabled={!data.jumping}
              content="Toggle Power"
              onClick={() => act('toggle_power')} />
          </Section>
          <Section title="FTL Spoolup:">
            <ProgressBar
              value={(data.progress/data.goal * 100)* 0.01}
              ranges={{
                good: [0.95, Infinity],
                average: [0.15, 0.9],
                bad: [-Infinity, 0.15],
              }} />
          </Section>
          <Section title="Tracking:">
            {Object.keys(data.tracking).map(key => {
              let value = data.tracking[key];
              return (
                <Fragment key={key}>
                  <Section title={`${value.name}`}>
                    <Button
                      fluid
                      content={`Current location: ${value.current_system}`}
                      icon="target" />
                  </Section>
                </Fragment>);
            })}
          </Section>
        </Section>
      </Window.Content>
    </Window>
  );
};
