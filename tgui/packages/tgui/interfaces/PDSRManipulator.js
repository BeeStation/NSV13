// NSV13

import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, ProgressBar, Slider, Chart, Flex, LabeledList } from '../components';
import { Window } from '../layouts';
import { toFixed } from 'common/math';

export const PDSRManipulator = (props, context) => {
  const { act, data } = useBackend(context);
  const { records } = data;
  const r_power_inputData = records.r_power_input.map((value, i) => [i, value]);
  const r_min_power_inputData = records.r_min_power_input.map((value, i) => [i, value]);
  const r_max_power_inputData = records.r_max_power_input.map((value, i) => [i, value]);
  if (data.silicon) {
    return (
      <Window
        resizable
        theme="ntos"
        width={400}
        height={400}>
        <Window.Content>
          <Section title="Nanotrasen P.A.W.Sible Deniability Filter - ENABLED">
            <img src={data.chosenKitty} style={{ maxWidth: '400px', width: '100%', maxHeight: '400px', height: '100%' }} />
          </Section>
        </Window.Content>
      </Window>
    );
  }
  return (
    <Window
      resizable
      theme="ntos"
      width={700}
      height={450}>
      <Window.Content scrollable>
        <Section>
          <Section title="Power Statistics">
            <Flex spacing={1}>
              <Flex.Item grow={1}>
                <Section fill position="relative" height="100%">
                  <Chart.Line
                    fillPositionedParent
                    data={r_power_inputData}
                    rangeX={[0, r_power_inputData.length - 1]}
                    rangeY={[0, 30000000]}
                    strokeColor="rgba(255, 255, 255, 0.8)"
                    fillColor="rgba(255, 255, 255, 0)" />
                  <Chart.Line
                    fillPositionedParent
                    data={r_max_power_inputData}
                    rangeX={[0, r_max_power_inputData.length - 1]}
                    rangeY={[0, 30000000]}
                    strokeColor="rgba(0, 181, 173, 0.8)"
                    fillColor="rgba(0, 181, 173, 0)" />
                  <Chart.Line
                    fillPositionedParent
                    data={r_min_power_inputData}
                    rangeX={[0, r_min_power_inputData.length - 1]}
                    rangeY={[0, 30000000]}
                    strokeColor="rgba(242, 113, 28, 0.8)"
                    fillColor="rgba(242, 113, 28, 0)" />
                </Section>
              </Flex.Item>
              <Flex.Item width="10px" />
              <Flex.Item width="280px">
                <Section>
                  <LabeledList>
                    <LabeledList.Item label="Available Power">
                      <ProgressBar
                        value={data.available_power}
                        minValue={0}
                        maxValue={data.r_max_power_input * 1.25}
                        color={(data.r_temp !== 0 && !data.r_has_enough_power) ? "bad" : "yellow"}>
                        {data.available_power / 1e+6 + ' MW'}
                      </ProgressBar>
                    </LabeledList.Item>
                    <LabeledList.Item label="Input Power">
                      <Slider
                        value={data.r_power_input}
                        minValue={0}
                        maxValue={data.r_max_power_input * 1.25}
                        step={1}
                        stepPixelSize={0.000004}
                        ranges={{
                          white: [data.r_min_power_input, data.r_max_power_input],
                          yellow: [data.r_max_power_input, data.r_max_power_input * 1.25],
                          red: [-Infinity, Infinity],
                        }}
                        onDrag={(e, value) => act('power_allocation', {
                          adjust: value,
                        })}>
                        {data.r_power_input / 1e+6 + ' MW'}
                      </Slider>
                    </LabeledList.Item>
                    <LabeledList.Item label="Maximum Safe Power">
                      <ProgressBar
                        value={data.r_max_power_input}
                        minValue={0}
                        maxValue={data.r_max_power_input}
                        color={data.r_relay_count === 0 ? "bad" : "teal"}>
                        {data.r_max_power_input / 1e+6 + ' MW'}
                      </ProgressBar>
                    </LabeledList.Item>
                    <LabeledList.Item label="Minimum Safe Power">
                      <ProgressBar
                        value={data.r_min_power_input}
                        minValue={0}
                        maxValue={data.r_max_power_input}
                        color="orange">
                        {data.r_min_power_input / 1e+6 + ' MW'}
                      </ProgressBar>
                    </LabeledList.Item>
                    <LabeledList.Item label="Screen Status">
                      <Button
                        fluid
                        icon="shield-alt"
                        color={data.s_active ? "green" : "red"}
                        content={data.s_active ? "Online" : "Offline"} />
                    </LabeledList.Item>
                  </LabeledList>
                </Section>
              </Flex.Item>
            </Flex>
          </Section>
          <Section title="Screen Manipulation">
            Screen Strength: {data.s_integrity + ' | ' + data.s_max_integrity}
            <br />
            Screen Integrity:
            <ProgressBar
              value={data.s_integrity / data.s_max_integrity}
              ranges={{
                teal: [0.50, Infinity],
                average: [0.15, 0.50],
                bad: [-Infinity, 0.15],
              }} />
            Screen Stability:
            <ProgressBar
              value={data.s_stability}
              minValue={0}
              maxValue={100}
              color={(data.s_regen === 100 ? "blue" : null) || (data.r_temp === 0 ? "default" : null)}
              ranges={{
                teal: [66, Infinity],
                average: [33, 66],
                bad: [-Infinity, 33],
              }} />
            Screen Hardening:
            <Slider
              value={data.s_hardening}
              fillValue={data.s_hardening}
              minValue={0}
              maxValue={100}
              step={1}
              stepPixelSize={6.4}
              onDrag={(e, value) => act('hardening', {
                adjust: value,
              })}>
              {data.s_hardening + ' %'}
            </Slider>
            Screen Regeneration:
            <Slider
              value={data.s_regen}
              minValue={0}
              maxValue={100}
              step={1}
              stepPixelSize={6.4}
              onDrag={(e, value) => act('regen', {
                adjust: value,
              })} >
              {data.s_regen + ' %'}
            </Slider>
            Screen Particle Density:
            <Button
              fluid
              icon="shield-alt"
              color={(data.s_active ? null : "default") || (data.s_density ? "green" : "orange")}
              content={data.s_density ? "High - Unspecialized Deflection" : "Low - High-Energy Kinetics Deflection"}
              onClick={() => act('density')}
            />
          </Section>
        </Section>
      </Window.Content>
    </Window>
  );
};
