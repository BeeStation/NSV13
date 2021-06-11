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
                  <Section title={`${value.name}`}>
                    <Button
                      fluid
                      content="Toggle Power"
                      icon={value.status !== "offline" ? "sqaure-o" : "power-off"}
                      color={value.status === "shutdown" ? "average" : value.status === "offline" ? "bad" : "good"}
                      disabled={value.status === "shutdown"}
                      onClick={() => act('pylon_power', { id: value.id })} />
                    cycle status: {value.status}
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
        </Section>
      </Window.Content>
    </Window>
  );
};
