import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, ProgressBar, Knob } from '../components';
import { Window } from '../layouts';

export const FighterMaintenance = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      resizable
      theme="hackerman"
      width={440}
      height={650}>
      <Window.Content scrollable>
        <Section>
          <Section title="Installed modules:">
            {!!data.hardpoints_info && (
              <Section>
                {Object.keys(data.hardpoints_info).map(key => {
                  let value = data.hardpoints_info[key];
                  return (
                    <Fragment key={key}>
                      <Section title={`${value.name}`}>
                        <Fragment>
                          <Button
                            fluid
                            content={`Examine ${value.name}`}
                            icon="search"
                            color={value.burntout ? "bad" : null}
                            onClick={() => act('examine', { id: value.id })} />
                          <Button
                            fluid
                            content={`Eject ${value.name}`}
                            icon="eject"
                            onClick={() => act('eject_p', { id: value.id })} />
                        </Fragment>
                      </Section>
                    </Fragment>);
                })}
              </Section>
            )}
          </Section>
          <Section title="Statistics:">
            Hull:
            <ProgressBar
              value={(data.integrity/data.max_integrity * 100)* 0.01}
              ranges={{
                good: [0.9, Infinity],
                average: [0.15, 0.9],
                bad: [-Infinity, 0.15],
              }} />
            Fuel:
            <ProgressBar
              value={(data.fuel/data.max_fuel * 100)* 0.01}
              ranges={{
                good: [0.9, Infinity],
                average: [0.15, 0.9],
                bad: [-Infinity, 0.15],
              }} />
            {!!data.max_torpedoes && (
              <Fragment>
                Torpedoes:
                <ProgressBar
                  value={(data.current_torpedoes/data.max_torpedoes * 100)*0.01}
                  ranges={{
                    good: [0.9, Infinity],
                    average: [0.15, 0.9],
                    bad: [-Infinity, 0.15],
                  }} />
              </Fragment>
            )}
            {!!data.max_missiles && (
              <Fragment>
                Missiles:
                <ProgressBar
                  value={(data.current_missiles/data.max_missiles * 100)* 0.01}
                  ranges={{
                    good: [0.9, Infinity],
                    average: [0.15, 0.9],
                    bad: [-Infinity, 0.15],
                  }} />
              </Fragment>
            )}
            {!!data.ftl_capable && (
              <Fragment>
                Ftl drive spoolup:
                <ProgressBar
                  value={(data.ftl_progress/data.ftl_goal * 100)* 0.01}
                  ranges={{
                    good: [0.10, Infinity],
                    average: [0.15, 0.10],
                    bad: [-Infinity, 0.15],
                  }} />
              </Fragment>
            )}
            {!!data.has_cargo && (
              <Fragment>
                Cargo hold:
                <ProgressBar
                  value={(data.cargo/data.max_cargo * 100)* 0.01}
                  ranges={{
                    good: [-Infinity, 0.40],
                    average: [0.40, 0.7],
                    bad: [0.7, Infinity],
                  }} />
              </Fragment>
            )}
          </Section>
        </Section>
      </Window.Content>
    </Window>
  );
};
