import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, ProgressBar, Knob, Flex, Tabs } from '../components';
import { Window } from '../layouts';

export const TacticalConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const tabIndex = 1;
  return (
    <Window
      resizable
      theme="retro"
      width={560}
      height={600}>
      <Window.Content scrollable>
        <Section>
          <Section title="Ship status">
            <Section title="Hull integrity:">
              <ProgressBar
                value={(data.integrity/data.max_integrity * 100)* 0.01}
                ranges={{
                  good: [0.95, Infinity],
                  average: [0.15, 0.9],
                  bad: [-Infinity, 0.15],
                }} />
            </Section>
            <Section title="Forward Port Armour:">
              <ProgressBar
                value={(data.quadrant_fp_armour_current / data.quadrant_fp_armour_max)}
                ranges={{
                  good: [0.66, Infinity],
                  average: [0.33, 0.66],
                  bad: [-Infinity, 0.33],
                }} />
            </Section>
            <Section title="Forward Starboard Armour:">
              <ProgressBar
                value={(data.quadrant_fs_armour_current / data.quadrant_fs_armour_max)}
                ranges={{
                  good: [0.66, Infinity],
                  average: [0.33, 0.66],
                  bad: [-Infinity, 0.33],
                }} />
            </Section>
            <Section title="Aft Port Armour:">
              <ProgressBar
                value={(data.quadrant_ap_armour_current / data.quadrant_ap_armour_max)}
                ranges={{
                  good: [0.66, Infinity],
                  average: [0.33, 0.66],
                  bad: [-Infinity, 0.33],
                }} />
            </Section>
            <Section title="Aft Starboard Armour:">
              <ProgressBar
                value={(data.quadrant_as_armour_current / data.quadrant_as_armour_max)}
                ranges={{
                  good: [0.66, Infinity],
                  average: [0.33, 0.66],
                  bad: [-Infinity, 0.33],
                }} />
            </Section>
          </Section>
          <Section title="Armaments:">
            {Object.keys(data.weapons).map(key => {
              let value = data.weapons[key];
              return (
                <Fragment key={key}>
                  {!!value.maxammo && (
                    <Section title={`${value.name}`}>
                      <ProgressBar
                        value={(value.ammo/value.maxammo * 100)* 0.01}
                        ranges={{
                          good: [0.95, Infinity],
                          average: [0.15, 0.9],
                          bad: [-Infinity, 0.15],
                        }} />
                    </Section>
                  )}
                </Fragment>);
            })}
          </Section>
          <Section title="Tracking:">
            {Object.keys(data.ships).map(key => {
              let value = data.ships[key];
              return (
                <Fragment key={key}>
                  {!!value.name && (
                    <Section title={`${value.name}`}>
                      <ProgressBar
                        value={(
                          value.integrity/value.max_integrity * 100)* 0.01}
                        ranges={{
                          good: [0.95, Infinity],
                          average: [0.15, 0.9],
                          bad: [-Infinity, 0.15],
                        }} />
                      <br />
                      <br />
                      <Button
                        fluid
                        content={`Target ${value.name}`}
                        icon="bullseye"
                        onClick={() =>
                          act('target_ship', { target: value.name })} />
                    </Section>
                  )}
                </Fragment>);
            })}
          </Section>
        </Section>
      </Window.Content>
    </Window>
  );
};
