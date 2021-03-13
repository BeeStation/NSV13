import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, LabeledList, ProgressBar, Section } from '../components';
import { Window } from '../layouts';

export const FighterController = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      resizable
      width={560}
      height={600}>
      <Window.Content scrollable>
        <Section title="Settings"
          buttons={(
            <Fragment>
              <Button
                content="Globally toggle weapon safeties"
                icon="bullseye"
                color="average"
                onClick={() => act('global_toggle')} />
              <Button
                content="EJECT ALL PILOTS"
                icon="eject"
                color="bad"
                onClick={() => act('global_eject')} />
            </Fragment>
          )} />
        <Section title="Filters:">
          {Object.keys(data.filter_types).map(key => {
            let value = data.filter_types[key];
            return (
              <Button key={key}
                content={`Showing: ${value.class}s`}
                icon="eject"
                color={value.visible && "green"}
                onClick={() => act('filter', { filter: value.class })} />);
          })}
        </Section>
        <Section title="Telemetry:">
          {Object.keys(data.fighters).map(key => {
            let value = data.fighters[key];
            return (
              <Fragment key={key}>
                <Section title={`${value.name} - ${value.class}`}>
                  <Button
                    content="Eject pilot"
                    icon="eject"
                    color={"average"}
                    onClick={() => act('eject', { target: value.name })} />
                  <Button
                    content="Toggle safeties"
                    icon="bullseye"
                    color={value.safeties && "green"}
                    onClick={() => act('toggle_safeties', { target: value.name })} />
                  <ProgressBar
                    value={(value.integrity/value.max_integrity * 100)* 0.01}
                    ranges={{
                      good: [0.95, Infinity],
                      average: [0.15, 0.9],
                      bad: [-Infinity, 0.15],
                    }} />
                </Section>
              </Fragment>);
          })}
        </Section>
      </Window.Content>
    </Window>
  );
};
