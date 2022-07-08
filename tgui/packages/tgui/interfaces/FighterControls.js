// NSV13

import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, ProgressBar, Knob, LabeledList } from '../components';
import { Window } from '../layouts';

export const FighterControls = (props, context) => {
  const { act, data } = useBackend(context);
  const [settingsVisible, setSettingsVisible] = useLocalState(context, 'settings', false);
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
            size={1.25}
            color={data.fuel_warning && 'bad'}
            value={data.fuel}
            unit="L"
            minValue="0"
            maxValue={data.max_fuel} />
          BATT:
          <Knob
            inline
            size={1.25}
            color={data.battery_charge <= 2000 && 'bad'}
            value={data.battery_charge}
            unit="W"
            minValue="0"
            maxValue={data.battery_max_charge} />
          RPM:
          <Knob
            inline
            size={1.25}
            value={data.rpm}
            unit="RPM"
            minValue="0"
            maxValue={8000} />
          PRIM:
          <Knob
            inline
            size={1.25}
            value={data.primary_ammo}
            unit="U"
            minValue="0"
            maxValue={data.max_primary_ammo} />
          SEC:
          <Knob
            inline
            size={1.25}
            value={data.secondary_ammo}
            unit="U"
            minValue="0"
            maxValue={data.max_secondary_ammo} />
          CTR:
          <Knob
            inline
            size={1.25}
            value={data.countermeasures}
            unit="U"
            minValue="0"
            maxValue={data.max_countermeasures} />
          <br />
          <br />
          <LabeledList>
            <LabeledList.Item label="Armour">
              <ProgressBar
                value={(data.armour_integrity / data.max_armour_integrity * 100) * 0.01}
                ranges={{
                  good: [0.9, Infinity],
                  average: [0.15, 0.9],
                  bad: [-Infinity, 0.15],
                }} />
            </LabeledList.Item>
            <LabeledList.Item label="Hull">
              <ProgressBar
                value={(data.obj_integrity / data.max_integrity * 100) * 0.01}
                ranges={{
                  good: [0.9, Infinity],
                  average: [0.15, 0.9],
                  bad: [-Infinity, 0.15],
                }} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        {!!data.ftl_capable && (
          <Section title="FTL Drive:">
            Tracking: {data.ftl_target ? data.ftl_target : "None"}
            <br />
            <br />
            <Button
              content={data.ftl_active ? "Stop Spooling" : "Begin Spooling"}
              width="150px"
              icon="server"
              onClick={() => act('toggle_ftl')} />
            <Button
              content={"Deploy Tether"}
              width="150px"
              icon="anchor"
              color={data.ftl_target ? "good" : "orange"}
              onClick={() => act('anchor_ftl')} />
            <Button
              content="Return"
              width="150px"
              icon="forward"
              onClick={() => act('return_jump')} />
            <ProgressBar
              value={(data.ftl_spool_progress / data.ftl_spool_time * 100) * 0.01}
              ranges={{
                good: [0.9, Infinity],
                average: [0.15, 0.9],
                bad: [-Infinity, 0.15],
              }} />
          </Section>
        )}
        <Section title="Controls:" buttons={
          <Button
            icon={settingsVisible ? 'times' : 'cog'}
            selected={settingsVisible}
            onClick={() => setSettingsVisible(!settingsVisible)} />
        }>
          <Button
            width="150px"
            content="DRADIS"
            icon="satellite-dish"
            onClick={() => act('show_dradis')} />
          <Button
            width="150px"
            content="Docking mode"
            icon={data.docking_mode ? "anchor" : "times"}
            color={(data.docking_cooldown && "orange") || (data.docking_mode ? "good" : null)}
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
        {!!settingsVisible && (
          <Section title="Settings:">
            <Button
              content={"Set Name"}
              onClick={() => act('set_name')} />
            <Button
              content={"Maintenance"}
              onClick={() => act('toggle_maintenance')} />
            <br />
            {!!data.maintenance_mode && (
              <Section title="Loaded Modules:">
                <LabeledList>
                  {Object.keys(data.hardpoints).map(key => {
                    let value = data.hardpoints[key];
                    return (
                      <LabeledList.Item key={key} label={`${value.name}`}>
                        <Button
                          content={`Eject`}
                          icon="eject"
                          onClick={() => act('eject_hardpoint', { id: value.id })} />
                        <Button
                          content={`Dump contents`}
                          icon="download"
                          onClick={() => act('dump_hardpoint', { id: value.id })} />
                      </LabeledList.Item>
                    );
                  })}
                </LabeledList>
              </Section>
            )}
            <br />
            {/*             <Section title="Occupants:">
              <LabeledList>
                {Object.keys(data.occupants_info).map(key => {
                  let value = data.occupants_info[key];
                  return (
                    <LabeledList.Item label={`${value.name}`}>
                      <Button
                        fluid
                        content={`Eject (${value.afk})`}
                        icon="eject"
                        onClick={() => act('kick', { id: value.id })} />
                    </LabeledList.Item>);
                })}
              </LabeledList>
            </Section> */}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
