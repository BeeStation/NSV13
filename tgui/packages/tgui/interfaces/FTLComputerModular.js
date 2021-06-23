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
      height={500}>
      <Window.Content scrollable>
        <Section>
          <Section title="Pylon control:">
            {Object.keys(data.pylons).map(key => {
              let value = data.pylons[key];
              return (
                <Fragment key={key}>
                  <Section title={`${value.name}`}>
                    <Button
                      fluid
                      content="Toggle Power"
                      icon="power-off"
                      color={value.status === "shutdown" ? "average" : value.status === "offline" ? "bad" : "good"}
                      disabled={value.status === "shutdown"}
                      onClick={() => act('pylon_power', { id: value.id })} />
                    <br />
                    Cycle Status: <b>{value.status}</b>
                    <br />
                    Gyro Speed:
                    <ProgressBar
                      value={value.gyro}
                      ranges={{
                        good: [1, 2],
                        average: [0.5, 0.9],
                        bad: [0, 0.4],
                      }} />
                    <br />
                    Capacitor Charge:
                    <ProgressBar
                      value={value.capacitor}
                      ranges={{
                        good: [1, 2],
                        average: [0.5, 0.9],
                        bad: [0, 0.4],
                      }} />
                    <br />
                    Power Draw: <b>{value.draw}</b>
                  </Section>
                </Fragment>);
            })}
            <Button
              content="Find Pylons"
              icon="search"
              onClick={() => act('find_pylons')} />

          </Section>
          <Section
            title="Manifold controls:">
            <Button
              color={!!data.powered && 'green'}
              disabled={data.jumping}
              content="Spool Drive"
              onClick={() => act('toggle_power')} />
          </Section>
          <Section title="FTL Spoolup:">
            <ProgressBar
              value={data.progress/data.goal}
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
