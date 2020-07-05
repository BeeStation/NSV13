import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, ProgressBar, Knob } from '../components';
import { Window } from '../layouts';

export const FighterControls = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window resizable theme="retro">
      <Window.Content scrollable>
        <Section>
          <Section 
            title="Center console:">
            <Fragment>
              <Button
                content="Master caution"
                color={data.master_caution ? "average" : null}
                icon="exclamation-triangle"
                onClick={() => act('master_caution')} />
              <Button
                content="Radar Lock"
                color={data.rwr ? "average" : null}
                icon="exclamation-triangle"
                onClick={() => act('master_caution')} />
              <Button
                content="DRADIS"
                icon="satellite-dish"
                onClick={() => act('show_dradis')} />
              <Button
                content="Countermeasures"
                icon={data.current_countermeasures?"fighter-jet":"times"}
                color={data.current_countermeasures ? null : "bad"}
                onClick={() => act('deploy_countermeasure')} />
            </Fragment>
          </Section>
          <Section title="Ignition controls:">
            Ignition: | Fuel:  | Battery: |  APU: | Throttle Lock:<br />
            <Knob
              inline
              size={1.7}
              color={!!data.ignition && 'green'}
              value={data.ignition*10}
              unit=""
              minValue="0"
              maxValue="10"
              step={1}
              stepPixelSize={1}
              onDrag={(e, value) => act('ignition')} />
            <Knob
              inline
              size={1.7}
              color={!!data.fuel_pump && 'green'}
              value={data.fuel_pump*10}
              unit=""
              minValue="0"
              maxValue="10"
              step={1}
              stepPixelSize={1}
              onDrag={(e, value) => act('fuel_pump')} />
            
            <Knob
              inline
              size={1.7}
              color={!!data.battery && 'green'}
              value={data.battery*10}
              unit=""
              minValue="0"
              maxValue="10"
              step={1}
              stepPixelSize={1}
              onDrag={(e, value) => act('battery')} />
            
            <Knob
              inline
              size={1.7}
              color={!!data.apu && 'green'}
              value={data.apu*10}
              unit=""
              minValue="0"
              maxValue="10"
              step={1}
              stepPixelSize={1}
              onDrag={(e, value) => act('apu')} />
            
            <Knob
              inline
              size={1.7}
              color={!!data.throttle_lock && 'green'}
              value={data.throttle_lock*10}
              unit=""
              minValue="0"
              maxValue="10"
              step={1}
              stepPixelSize={1}
              onChange={(e, value) => act('throttle_lock')} />
          </Section>
          <Section title="Flight controls:">
            <Button
              fluid
              content="Docking mode"
              icon={data.docking_mode ? "anchor" : "times"}
              color={data.docking_mode ? "good" : null}
              onClick={() => act('docking_mode')} />
            <Button
              fluid
              content="Canopy lock"
              icon={data.canopy_lock ? "lock" :"unlock"}
              color={data.canopy_lock ? "good" : null}
              onClick={() => act('canopy_lock')} />
            <Button
              fluid
              content="Brakes"
              icon={!data.brakes ? "unlock" :"lock"}
              color={data.brakes ? "good" : null}
              onClick={() => act('brakes')} />
            <Button
              fluid
              content="Inertial assistance system"
              icon="bezier-curve"
              color={data.inertial_dampeners ? "good" : null}
              onClick={() => act('inertial_dampeners')} />
            <Button
              fluid
              content="Magnetic arrestor locked"
              icon={data.mag_locked ? "unlock" :"magnet"}
              color={data.mag_locked ? "good" : null}
              onClick={() => act('mag_release')} />
            <Button
              fluid
              content="Weapon safeties"
              icon={data.weapon_safety ? "power-off" : "times"}
              color={!data.mag_locked ? "good" : null}
              onClick={() => act('weapon_safety')} />
            <Button
              fluid
              content="Active target lock"
              icon={data.target_lock ? "power-off" : "square-o"}
              color={data.target_lock ? "good" : "average"}
              onClick={() => act('target_lock')} />
            <Button
              fluid
              content="EJECT"
              icon="eject"
              color="average"
              onClick={() => act('eject')} />
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
                {Object.keys(data.cargo_info).map(key => {
                  let value = data.cargo_info[key];
                  return (
                    <Fragment key={key}> 
                      <Section title={`${value.name}`}>
                        <Button
                          fluid
                          content="Eject"
                          icon="eject"
                          tooltip={value.contents}
                          onClick={() => act('carg', { id: value.crate_id })} />
                      </Section>
                    </Fragment>);
                })}
              </Fragment>
            )}
          </Section>
          <Section title="Occupants:">
            {Object.keys(data.occupants_info).map(key => {
              let value = data.occupants_info[key];
              return (
                <Fragment key={key}>
                  <Section title={`${value.name}`}>
                    <Button
                      fluid
                      content={`Eject (${value.afk})`}
                      icon="eject"
                      onClick={() => act('kick', { id: value.id })} />
                  </Section>
                </Fragment>);
            })}
          </Section>
        </Section>
      </Window.Content>
    </Window>
  );
};
