import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, ProgressBar, Knob } from '../components';
import { Window } from '../layouts';

export const FighterControls = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      resizable
      theme="hackerman"
      width={497}
      height={450}>
      <Window.Content scrollable>
        <Section
          title="Alerts:">
          <Button
            width="150px"
            content="Master caution"
            color={data.master_caution ? "average" : null}
            icon="exclamation-triangle"
            onClick={() => act('master_caution')} />
          <Button
            width="150px"
            content="Radar Lock"
            color={data.rwr ? "average" : null}
            icon="exclamation-triangle" />
          <Button
            width="150px"
            content="Fuel Warning"
            color={data.fuel_warning ? "average" : null}
            icon="gas-pump" />
        </Section>
        <Section title="Monitoring">
          FUEL:
          <Knob
            inline
            size={1.5}
            color={data.fuel_warning && 'bad'}
            value={data.fuel}
            unit="L"
            minValue="0"
            maxValue={data.max_fuel} />
          BATT:
          <Knob
            inline
            size={1.5}
            color={data.battery_charge <= 2000 && 'bad'}
            value={data.battery_charge}
            unit="W"
            minValue="0"
            maxValue={data.battery_max_charge} />
          RPM:
          <Knob
            inline
            size={1.5}
            value={data.rpm}
            unit="RPM"
            minValue="0"
            maxValue={8000} />
          PRIM:
          <Knob
            inline
            size={1.5}
            value={data.primary_ammo}
            unit="U"
            minValue="0"
            maxValue={data.max_primary_ammo} />
          SEC:
          <Knob
            inline
            size={1.5}
            value={data.secondary_ammo}
            unit="U"
            minValue="0"
            maxValue={data.max_secondary_ammo} />
          <br />
          <br />
          Armour:
          <ProgressBar
            value={(data.armour_integrity / data.max_armour_integrity * 100) * 0.01}
            ranges={{
              good: [0.9, Infinity],
              average: [0.15, 0.9],
              bad: [-Infinity, 0.15],
            }} />
          <br />
          Hull:
          <ProgressBar
            value={(data.obj_integrity / data.max_integrity * 100) * 0.01}
            ranges={{
              good: [0.9, Infinity],
              average: [0.15, 0.9],
              bad: [-Infinity, 0.15],
            }} />
        </Section>
        <Section title="Controls:">
          <Button
            width="150px"
            content="DRADIS"
            icon="satellite-dish"
            onClick={() => act('show_dradis')} />
          <Button
            width="150px"
            content="Docking mode"
            icon={data.docking_mode ? "anchor" : "times"}
            color={data.docking_mode ? "good" : null}
            onClick={() => act('docking_mode')} />
          <Button
            width="150px"
            content="Canopy lock"
            icon={!data.canopy_lock ? "lock" : "unlock"}
            color={!data.canopy_lock ? "good" : null}
            onClick={() => act('canopy_lock')} />
          <Button
            width="150px"
            content="Brakes"
            icon={!data.brakes ? "unlock" : "lock"}
            color={data.brakes ? "good" : null}
            onClick={() => act('brakes')} />
          <Button
            width="150px"
            content="IAS"
            icon="bezier-curve"
            color={data.inertial_dampeners ? "good" : null}
            onClick={() => act('inertial_dampeners')} />
          <Button
            width="150px"
            content="MAGLOCK"
            icon={data.mag_locked ? "unlock" : "magnet"}
            color={data.mag_locked ? "good" : null}
            onClick={() => act('mag_release')} />
          <Button
            width="150px"
            content="SAFETIES"
            icon={data.weapon_safety ? "power-off" : "times"}
            color={!data.weapon_safety ? "bad" : "good"}
            onClick={() => act('weapon_safety')} />
          <Button
            width="150px"
            content="TARGET LOCK"
            icon={data.target_lock ? "power-off" : "square-o"}
            color={data.target_lock ? "good" : "average"}
            onClick={() => act('target_lock')} />
          <Button
            width="150px"
            content="BATTERY"
            icon={data.battery ? "car-battery" : "power-off"}
            color={data.battery ? "good" : "bad"}
            onClick={() => act('battery')} />
          <Button
            width="150px"
            content="FUEL INJECTOR"
            icon={data.fuel_pump ? "gas-pump" : "power-off"}
            color={data.fuel_pump ? "good" : "bad"}
            onClick={() => act('fuel_pump')} />
          <Button
            width="150px"
            content="APU"
            icon={data.apu ? "power-off" : "square-o"}
            color={data.apu ? "good" : "bad"}
            onClick={() => act('apu')} />
          <Button
            width="150px"
            content="IGNITION"
            icon={data.ignition ? "key" : "square-o"}
            color={data.ignition ? "good" : "bad"}
            onClick={() => act('ignition')} />
        </Section>
        {!!data.maintenance_mode && (
          <Fragment>
            <Section title="Loaded Modules:">
              {Object.keys(data.hardpoints).map(key => {
                let value = data.hardpoints[key];
                return (
                  <Fragment key={key}>
                    <Section title={`${value.name}`}>
                      <Button
                        content={`Eject`}
                        icon="eject"
                        onClick={() => act('eject_hardpoint', { id: value.id })} />
                      <Button
                        content={`Dump contents`}
                        icon="download"
                        onClick={() => act('dump_hardpoint', { id: value.id })} />
                    </Section>
                  </Fragment>);
              })}
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
          </Fragment>
        )}
      </Window.Content>
    </Window>
  );
};
