// NSV13

import { useBackend, useLocalState, useSharedState } from "../backend";
import { Blink, Box, Button, Flex, LabeledList, ProgressBar, Section, Stack, Tabs } from "../components";
import { Window } from "../layouts";
import { DradisContent } from "./Dradis";

export const FighterControls = (props, context) => {
  const { act, data } = useBackend(context);
  const [tab, setTab] = useSharedState(context, 'tab', 'dradis');
  const tacticalCalibration = data.tactical_calibration;

  return (
    <Window
      width={800}
      height={550}
      theme="hackerman">
      <Window.Content>
        <Stack fill>
          <Stack.Item width="25%">
            <Section title="Alerts">
              <Button
                fluid
                icon={data.master_caution ? "exclamation-triangle" : null}
                content="Master Caution"
                color={data.master_caution ? "average" : "grey"}
                onClick={() => act('master_caution')} />
              <Button
                fluid
                icon={data.rwr ? "exclamation-triangle" : null}
                content="Hostile Lock"
                color={data.rwr ? "bad" : "grey"} />
              <Button
                fluid
                icon={data.fuel_warning ? "gas-pump" : null}
                content="Fuel Warning"
                color={data.fuel_warning ? "average" : "grey"} />
              <Button
                fluid
                icon={!data.weapon_safety ? "exclamation-triangle" : "times"}
                content={!data.weapon_safety ? "Weapons ARMED" : "Weapons SAFE"}
                color={!data.weapon_safety ? "bad" : "good"}
                onClick={() => act('weapon_safety')} />
            </Section>
            <Section title="Current Order">
              Words.
            </Section>
            <Section title="Tactical">
              {tacticalCalibration === 100 && (
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
                  <LabeledList.Item label="Primary Ammo">
                    <ProgressBar
                      value={data.primary_ammo}
                      minValue={0}
                      maxValue={data.max_primary_ammo}
                      range={{
                        good: [],
                        average: [0.25, Infinity],
                        bad: [-Infinity, 0.25],
                      }}>
                      {data.primary_ammo + ' / ' + data.max_primary_ammo}
                    </ProgressBar>
                  </LabeledList.Item>
                  <LabeledList.Item label="Secondary Ammo">
                    <ProgressBar
                      value={data.secondary_ammo}
                      minValue={0}
                      maxValue={data.max_secondary_ammo}
                      range={{
                        good: [],
                        average: [0.25, Infinity],
                        bad: [-Infinity, 0.25],
                      }}>
                      {data.secondary_ammo + ' / ' + data.max_secondary_ammo}
                    </ProgressBar>
                  </LabeledList.Item>
                  <LabeledList.Item label="Countermeasures">
                    <ProgressBar
                      value={data.countermeasures}
                      minValue={0}
                      maxValue={data.max_countermeasures}
                      range={{
                        good: [],
                        average: [0.25, Infinity],
                        bad: [-Infinity, 0.25],
                      }}>
                      {data.countermeasures + ' U'}
                    </ProgressBar>
                  </LabeledList.Item>
                </LabeledList>
              )}
              {tacticalCalibration < 100 && (
                <Blink>
                  Tactical Offline
                </Blink>
              )}
            </Section>
          </Stack.Item>
          <Stack.Item width="75%">
            <Stack vertical fill>
              <Stack.Item>
                <Section title="MFD MENU" fitted>
                  <Tabs>
                    <Tabs.Tab fluid
                      icon="satellite-dish"
                      selected={tab === 'dradis'}
                      onClick={() => setTab('dradis')}>
                      DRADIS
                    </Tabs.Tab>
                    <Tabs.Tab fluid
                      icon="cog"
                      selected={tab === 'systems'}
                      onClick={() => setTab('systems')}>
                      SYSTEMS
                    </Tabs.Tab>
                    <Tabs.Tab fluid
                      icon="wrench"
                      selected={tab === 'aux'}
                      onClick={() => setTab('aux')}>
                      AUX
                    </Tabs.Tab>
                  </Tabs>
                </Section>
                {tab === 'dradis' && (
                  <TabDradis />
                )}
                {tab === 'systems' && (
                  <TabSystems />
                )}
                {tab === 'aux' && (
                  <TabAux />
                )}
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const TabDradis = (props, context) => {
  let content = DradisContent(props, context);
  const { data } = useBackend(context);
  const dradisOnline = data.dradis_online;

  if (dradisOnline)
  {
    return (
      <Section>
        {content}
      </Section>
    );
  } else {
    return (
      <Section>
        <Blink>
          Avionics Offline
        </Blink>
      </Section>
    );
  }
};

const TabSystems = (props, context) => {
  const { act, data } = useBackend(context);
  const avionicsCalibration = data.avionics_calibration;

  return (
    <Stack fill>
      <Stack.Item width="50%">
        <Section title="Engine">
          <LabeledList>
            <LabeledList.Item label="Fuel">
              <ProgressBar
                value={(data.fuel / data.max_fuel * 100) * 0.01}
                ranges={{
                  good: [0.9, Infinity],
                  average: [0.15, 0.9],
                  bad: [-Infinity, 0.15],
                }}>
                {data.fuel + ' L'}
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Engine RPM">
              <ProgressBar
                value={data.rpm}
                minValue={0}
                maxValue={8000}
                ranges={{
                  good: [],
                  average: [0.25, Infinity],
                  bad: [-Infinity, 0.25],
                }}>
                {data.rpm + ' RPM'}
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Battery">
              <ProgressBar
                value={data.battery_charge}
                minValue={0}
                maxValue={data.battery_max_charge}
                ranges={{
                  good: [0.9, Infinity],
                  average: [0.15, 0.9],
                  bad: [-Infinity, 0.15],
                }}>
                {data.battery_charge + ' W'}
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Status">
              <Button
                width="200px"
                content={data.engine_status ? "Flight Ready" : "DO NOT LAUNCH"}
                icon={data.engine_status ? "plane" : "xmark"}
                color={data.engine_status ? "good" : "bad"} />
            </LabeledList.Item>
          </LabeledList>
          <br />
          <Button
            width="135px"
            content="BATTERY"
            icon={data.battery ? "car-battery" : "power-off"}
            color={data.battery ? "good" : "bad"}
            onClick={() => act('battery')} />
          <Button
            width="135px"
            content="FUEL INJECTOR"
            icon={data.fuel_pump ? "gas-pump" : "power-off"}
            color={data.fuel_pump ? "good" : "bad"}
            onClick={() => act('fuel_pump')} />
          <Button
            width="135px"
            content="APU"
            icon={data.apu ? "power-off" : "square-o"}
            color={data.apu ? "good" : "bad"}
            onClick={() => act('apu')} />
          <Button
            width="135px"
            content="IGNITER"
            icon={data.ignition ? "fire" : "square-o"}
            color={data.ignition ? "good" : "bad"}
            onClick={() => act('ignition')} />
        </Section>
      </Stack.Item>
      <Stack.Item width="50%">
        <Section title="Tactical">
          <LabeledList>
            <LabeledList.Item label="Calibration">
              <ProgressBar
                value={(data.tactical_calibration) / 100}
                range={{
                  good: [],
                  average: [-Infinity, Infinity],
                  bad: [],
                }} />
              <Button
                width="200px"
                content="Boot"
                icon={data.tactical_booting ? "power-off" : "square-o"}
                color={data.tactical_booting ? "good" : "bad"}
                onClick={() => act('boot_tactical')} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Avionics">
          <LabeledList>
            <LabeledList.Item label="Calibration">
              <ProgressBar
                value={(data.avionics_calibration) / 100}
                range={{
                  good: [],
                  average: [-Infinity, Infinity],
                  bad: [],
                }} />
              <Button
                width="200px"
                content="Boot"
                icon={data.avionics_booting ? "power-off" : "square-o"}
                color={data.avionics_booting ? "good" : "bad"}
                onClick={() => act('boot_avionics')} />
            </LabeledList.Item>
            <LabeledList.Item label="IFF">
              {avionicsCalibration < 25 && (
                <Blink>
                  Offline
                </Blink>
              )}
              {avionicsCalibration > 25 && (
                data.faction
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Comms">
              <Button
                width="200px"
                content={data.comm_state ? "Comms Online" : "Comms Offline"}
                icon={data.comm_state ? "power-off" : "square-o"}
                color={data.comm_state ? "good" : "bad"} />
              {avionicsCalibration < 25 && (
                <Blink>
                  Offline
                </Blink>
              )}
              {avionicsCalibration > 25 && (
                <Section title="Frequency">
                  {(data.comm_freq / 10)}
                </Section>
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const TabAux = (props, context) => {
  const { act, data } = useBackend(context);

  return (
    <Box>
      <Section title="Aux Controls">
        <Button
          width="185px"
          content="Docking Mode"
          icon={data.docking_mode ? "anchor" : "times"}
          color={(data.docking_cooldown && "orange") || (data.docking_mode ? "good" : null)}
          onClick={() => act('docking_mode')} />
        <Button
          width="185px"
          content="Canopy lock"
          icon={!data.canopy_lock ? "lock" : "unlock"}
          color={!data.canopy_lock ? "good" : null}
          onClick={() => act('canopy_lock')} />
        <Button
          width="185px"
          content="Brakes"
          icon={!data.brakes ? "unlock" : "lock"}
          color={data.brakes ? "good" : null}
          onClick={() => act('brakes')} />
        <Button
          width="185px"
          content="IAS"
          icon="bezier-curve"
          color={data.inertial_dampeners ? "good" : null}
          onClick={() => act('inertial_dampeners')} />
        <Button
          width="185px"
          content="MAGLOCK"
          icon={data.mag_locked ? "unlock" : "magnet"}
          color={data.mag_locked ? "good" : null}
          onClick={() => act('mag_release')} />
      </Section>
      <Section title="Settings">
        <Button
          content={"Set Name"}
          onClick={() => act('set_name')} />
        <Button
          content={"Maintenance"}
          onClick={() => act('toggle_maintenance')} />
        <br />
        {!!data.maintenance_mode && (
          <Section title="Loaded Modules">
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
      </Section>
    </Box>
  );
};
