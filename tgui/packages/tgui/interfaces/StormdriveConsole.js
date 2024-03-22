// NSV13

import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, ProgressBar, Slider, Chart, Flex, LabeledList } from '../components';
import { Window } from '../layouts';
import { toFixed } from 'common/math';

export const StormdriveConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const { gas_records } = data;
  const constricted_plasmaData = gas_records.constricted_plasma.map((value, i) => [i, value]);
  const plasmaData = gas_records.plasma.map((value, i) => [i, value]);
  const tritiumData = gas_records.tritium.map((value, i) => [i, value]);
  const o2Data = gas_records.o2.map((value, i) => [i, value]);
  const n2Data = gas_records.n2.map((value, i) => [i, value]);
  const co2Data = gas_records.co2.map((value, i) => [i, value]);
  const water_vapourData = gas_records.water_vapour.map((value, i) => [i, value]);
  const nobData = gas_records.nob.map((value, i) => [i, value]);
  const n2oData = gas_records.n2o.map((value, i) => [i, value]);
  const no2Data = gas_records.no2.map((value, i) => [i, value]);
  const bzData = gas_records.bz.map((value, i) => [i, value]);
  const stimData = gas_records.stim.map((value, i) => [i, value]);
  const pluoxiumData = gas_records.pluoxium.map((value, i) => [i, value]);
  const nucleiumData = gas_records.nucleium.map((value, i) => [i, value]);
  return (
    <Window
      resizable
      theme="ntos"
      width={560}
      height={600}>
      <Window.Content scrollable>
        <Section>
          <Section
            title="Control presets:">
            <Fragment>
              <Button
                fluid
                content="AZ-1 - FULLY RAISE CONTROL RODS"
                icon="exclamation-triangle"
                color="bad"
                onClick={() => act('rods_1')} />
              <Button
                fluid
                content="AZ-2 - HIGH TEMPERATURE OPERATION"
                icon="temperature-high"
                color="average"
                onClick={() => act('rods_2')} />
              <Button
                fluid
                content="AZ-3 - NOMINAL OPERATION"
                icon="temperature-low"
                color="yellow"
                onClick={() => act('rods_3')} />
              <Button
                fluid
                content="AZ-4 - COLD START"
                icon="snowflake"
                color="blue"
                onClick={() => act('rods_4')} />
              <Button
                fluid
                content="AZ-5 - SCRAM"
                icon="radiation-alt"
                color="bad"
                onClick={() => act('rods_5')} />
              <Button
                fluid
                content="AZ-6 - MAINTENANCE MODE"
                icon="cog"
                color={data.reactor_maintenance && "white"}
                onClick={() => act('maintenance')} />
              <Button
                fluid
                content="AZ-7 - FUEL DUMP"
                icon="gas-pump"
                color={data.pipe_open && "white"}
                onClick={() => act('pipe')} />
            </Fragment>
          </Section>
          <Section title="Control Rod Insertion:">
            <Slider
              value={data.control_rod_percent}
              minValue={0}
              maxValue={100}
              step={1}
              stepPixelSize={5}
              onDrag={(e, value) => act('control_rod_percent', {
                adjust: value,
              })} />
          </Section>
          <Section title="Statistics:">
            Temperature:
            <ProgressBar
              value={data.heat/data.reactor_meltdown}
              ranges={{
                good: [],
                average: [(data.reactor_hot/data.reactor_meltdown), (data.reactor_critical/data.reactor_meltdown)],
                bad: [(data.reactor_critical/data.reactor_meltdown), Infinity],
              }} >
              {toFixed(data.heat) + ' °C'}
            </ProgressBar>
            Rod Integrity:
            <ProgressBar
              value={(data.rod_integrity/100 * 100)* 0.01}
              ranges={{
                good: [],
                average: [0.15, 0.5],
                bad: [-Infinity, 0.15],
              }} />
            Power Output:
            <ProgressBar
              value={(data.last_power_produced/data.theoretical_maximum_power)}
              ranges={{
                good: [],
                average: [0.08, 0.20],
                bad: [-Infinity, 0.08],
              }}>
              {data.last_power_produced/1e+6 + ' MW'}
            </ProgressBar>
            Reaction Rate:
            <ProgressBar
              value={data.reaction_rate * 0.05}
              ranges={{
                good: [],
                average: [0.1, 0.2],
                bad: [-Infinity, 0.1],
              }}>
              {data.reaction_rate + ' mol/s'}
            </ProgressBar>
            Fuel Ratio:
            <ProgressBar
              value={data.fuel_mix/data.total_moles}
              ranges={{
                good: [],
                average: [0.125, 0.25],
                bad: [-Infinity, 0.125],
              }}>
              {toFixed((data.fuel_mix/data.total_moles) * 100) + ' %'}
            </ProgressBar>
            Fuel Moles:
            <ProgressBar
              value={data.total_moles/data.mole_threshold_very_high}
              ranges={{
                good: [],
                average: [(data.mole_threshold_high/data.mole_threshold_very_high), Infinity],
                bad: [-Infinity, data.reaction_rate/data.mole_threshold_very_high],
              }}>
              {data.total_moles + ' mol'}
            </ProgressBar>
          </Section>
          <Section title="Fuel Line Composition:">
            <Flex spacing={1}>
              <Flex.Item width="200px">
                <Section>
                  <LabeledList>
                    <LabeledList.Item label="Constricted Plasma">
                      <ProgressBar
                        value={(data.constricted_plasma/data.total_moles) * 100}
                        minValue={0}
                        maxValue={100}
                        color="violet">
                        {toFixed((data.constricted_plasma/data.total_moles) * 100) + ' %'}
                      </ProgressBar>
                    </LabeledList.Item>
                    <LabeledList.Item label="Plasma">
                      <ProgressBar
                        value={(data.plasma/data.total_moles) * 100}
                        minValue={0}
                        maxValue={100}
                        color="purple">
                        {toFixed((data.plasma/data.total_moles) * 100) + ' %'}
                      </ProgressBar>
                    </LabeledList.Item>
                    <LabeledList.Item label="Tritium">
                      <ProgressBar
                        value={(data.tritium/data.total_moles) * 100}
                        minValue={0}
                        maxValue={100}
                        color="pink">
                        {toFixed((data.tritium/data.total_moles) * 100) + ' %'}
                      </ProgressBar>
                    </LabeledList.Item>
                    <LabeledList.Item label="Oxygen">
                      <ProgressBar
                        value={(data.o2/data.total_moles) * 100}
                        minValue={0}
                        maxValue={100}
                        color="blue">
                        {toFixed((data.o2/data.total_moles) * 100) + ' %'}
                      </ProgressBar>
                    </LabeledList.Item>
                    <LabeledList.Item label="Nitrogen">
                      <ProgressBar
                        value={(data.n2/data.total_moles) * 100}
                        minValue={0}
                        maxValue={100}
                        color="red">
                        {toFixed((data.n2/data.total_moles) * 100) + ' %'}
                      </ProgressBar>
                    </LabeledList.Item>
                    <LabeledList.Item label="Carbon Dioxide">
                      <ProgressBar
                        value={(data.co2/data.total_moles) * 100}
                        minValue={0}
                        maxValue={100}
                        color="grey">
                        {toFixed((data.co2/data.total_moles) * 100) + ' %'}
                      </ProgressBar>
                    </LabeledList.Item>
                    <LabeledList.Item label="Water Vapour">
                      <ProgressBar
                        value={(data.water_vapour/data.total_moles) * 100}
                        minValue={0}
                        maxValue={100}
                        color="white">
                        {toFixed((data.water_vapour/data.total_moles) * 100) + ' %'}
                      </ProgressBar>
                    </LabeledList.Item>
                    <LabeledList.Item label="Hypernoblium">
                      <ProgressBar
                        value={(data.nob/data.total_moles) * 100}
                        minValue={0}
                        maxValue={100}
                        color="teal">
                        {toFixed((data.nob/data.total_moles) * 100) + ' %'}
                      </ProgressBar>
                    </LabeledList.Item>
                    <LabeledList.Item label="Nitrous Oxide">
                      <ProgressBar
                        value={(data.n2o/data.total_moles) * 100}
                        minValue={0}
                        maxValue={100}
                        color="label">
                        {toFixed((data.n2o/data.total_moles) * 100) + ' %'}
                      </ProgressBar>
                    </LabeledList.Item>
                    <LabeledList.Item label="Nitryl">
                      <ProgressBar
                        value={(data.no2/data.total_moles) * 100}
                        minValue={0}
                        maxValue={100}
                        color="">
                        {toFixed((data.no2/data.total_moles) * 100) + ' %'}
                      </ProgressBar>
                    </LabeledList.Item>
                    <LabeledList.Item label="BZ">
                      <ProgressBar
                        value={(data.bz/data.total_moles) * 100}
                        minValue={0}
                        maxValue={100}
                        color="orange">
                        {toFixed((data.bz/data.total_moles) * 100) + ' %'}
                      </ProgressBar>
                    </LabeledList.Item>
                    <LabeledList.Item label="Stimulum">
                      <ProgressBar
                        value={(data.stim/data.total_moles) * 100}
                        minValue={0}
                        maxValue={100}
                        color="yellow">
                        {toFixed((data.stim/data.total_moles) * 100)+ ' %'}
                      </ProgressBar>
                    </LabeledList.Item>
                    <LabeledList.Item label="Pluoxium">
                      <ProgressBar
                        value={(data.pluoxium/data.total_moles) * 100}
                        minValue={0}
                        maxValue={100}
                        color="olive">
                        {toFixed((data.pluoxium/data.total_moles) * 100) + ' %'}
                      </ProgressBar>
                    </LabeledList.Item>
                    <LabeledList.Item label="Nucleium">
                      <ProgressBar
                        value={(data.nucleium/data.total_moles) * 100}
                        minValue={0}
                        maxValue={100}
                        color="brown">
                        {toFixed((data.nucleium/data.total_moles) * 100) + ' %'}
                      </ProgressBar>
                    </LabeledList.Item>
                  </LabeledList>
                </Section>
              </Flex.Item>
              <Flex.Item grow={1}>
                <Section fill position="relative" height="100%">
                  <Chart.Line
                    fillPositionedParent
                    data={constricted_plasmaData}
                    rangeX={[0, constricted_plasmaData.length - 1]}
                    rangeY={[0, 100]}
                    strokeColor="rgba(100, 53, 201, 1)"
                    fillColor="rgba(100, 53, 201, 0.1)" />
                  <Chart.Line
                    fillPositionedParent
                    data={plasmaData}
                    rangeX={[0, plasmaData.length - 1]}
                    rangeY={[0, 100]}
                    strokeColor="rgba(163, 51, 200, 1)"
                    fillColor="rgba(163, 51, 200, 0.1)" />
                  <Chart.Line
                    fillPositionedParent
                    data={tritiumData}
                    rangeX={[0, tritiumData.length - 1]}
                    rangeY={[0, 100]}
                    strokeColor="rgba(224, 57, 151, 1)"
                    fillColor="rgba(224, 57, 151, 0.1)" />
                  <Chart.Line
                    fillPositionedParent
                    data={o2Data}
                    rangeX={[0, o2Data.length - 1]}
                    rangeY={[0, 100]}
                    strokeColor="rgba(33, 133, 208, 1)"
                    fillColor="rgba(33, 133, 208, 0)" />
                  <Chart.Line
                    fillPositionedParent
                    data={co2Data}
                    rangeX={[0, co2Data.length - 1]}
                    rangeY={[0, 100]}
                    strokeColor="rgba(118, 118, 118, 1)"
                    fillColor="rgba(118, 118, 118, 0)" />
                  <Chart.Line
                    fillPositionedParent
                    data={water_vapourData}
                    rangeX={[0, water_vapourData.length - 1]}
                    rangeY={[0, 100]}
                    strokeColor="rgba(255, 255, 255, 1)"
                    fillColor="rgba(255, 255, 255, 0)" />
                  <Chart.Line
                    fillPositionedParent
                    data={nobData}
                    rangeX={[0, nobData.length - 1]}
                    rangeY={[0, 100]}
                    strokeColor="rgba(0, 181, 173, 1)"
                    fillColor="rgba(0, 181, 173, 0)" />
                  <Chart.Line
                    fillPositionedParent
                    data={n2oData}
                    rangeX={[0, n2oData.length - 1]}
                    rangeY={[0, 100]}
                    strokeColor="rgba(126, 144, 167, 1)"
                    fillColor="rgba(126, 144, 167, 0)" />
                  <Chart.Line
                    fillPositionedParent
                    data={no2Data}
                    rangeX={[0, no2Data.length - 1]}
                    rangeY={[0, 100]}
                    strokeColor="rgba(66, 87, 112, 1)"
                    fillColor="rgba(66, 87, 112, 0)" />
                  <Chart.Line
                    fillPositionedParent
                    data={bzData}
                    rangeX={[0, bzData.length - 1]}
                    rangeY={[0, 100]}
                    strokeColor="rgba(242, 113, 28, 1)"
                    fillColor="rgba(242, 113, 28, 0.)" />
                  <Chart.Line
                    fillPositionedParent
                    data={stimData}
                    rangeX={[0, stimData.length - 1]}
                    rangeY={[0, 100]}
                    strokeColor="rgba(251, 214, 8, 1)"
                    fillColor="rgba(251, 214, 8, 0.)" />
                  <Chart.Line
                    fillPositionedParent
                    data={pluoxiumData}
                    rangeX={[0, pluoxiumData.length - 1]}
                    rangeY={[0, 100]}
                    strokeColor="rgba(181, 204, 24, 1)"
                    fillColor="rgba(181, 204, 24, 0.)" />
                  <Chart.Line
                    fillPositionedParent
                    data={nucleiumData}
                    rangeX={[0, nucleiumData.length - 1]}
                    rangeY={[0, 100]}
                    strokeColor="rgba(165, 103, 63, 1)"
                    fillColor="rgba(165, 103, 63, 0)" />
                  <Chart.Line
                    fillPositionedParent
                    data={n2Data}
                    rangeX={[0, n2Data.length - 1]}
                    rangeY={[0, 100]}
                    strokeColor="rgba(255, 0, 0, 1)"
                    fillColor="rgba(255, 0, 0, 0)" />
                </Section>
              </Flex.Item>
            </Flex>
          </Section>
        </Section>
      </Window.Content>
    </Window>
  );
};
