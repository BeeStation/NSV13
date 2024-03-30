// NSV13

import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, ProgressBar, Slider, Chart, Flex, LabeledList } from '../components';
import { Window } from '../layouts';
import { toFixed } from 'common/math';

export const PDSRMainframe = (props, context) => {
  const { act, data } = useBackend(context);
  const { records } = data;
  const r_reaction_polarityData = records.r_reaction_polarity.map((value, i) => [i, value]);
  const r_reaction_containmentData = records.r_reaction_containment.map((value, i) => [i, value]);
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
      height={500}>
      <Window.Content scrollable>
        <Section>
          <Section title="Reactor Containment Statistics">
            <Flex spacing={1}>
              <Flex.Item grow={1}>
                <Section fill position="relative" height="100%">
                  <Chart.Line
                    fillPositionedParent
                    data={r_reaction_polarityData}
                    rangeX={[0, r_reaction_polarityData.length - 1]}
                    rangeY={[-1, 1]}
                    strokeColor="rgba(33, 133, 208, 1)"
                    fillColor="rgba(33, 133, 208, 0)" />
                  <Chart.Line
                    fillPositionedParent
                    data={r_reaction_containmentData}
                    rangeX={[0, r_reaction_containmentData.length - 1]}
                    rangeY={[0, 100]}
                    strokeColor="rgba(255, 0, 0, 1)"
                    fillColor="rgba(33, 133, 208, 0)" />
                </Section>
              </Flex.Item>
              <Flex.Item width="10px" />
              <Flex.Item width="280px">
                <Section>
                  <LabeledList>
                    <LabeledList.Item label="Reaction Polarity">
                      <ProgressBar
                        value={data.r_polarity}
                        minValue={-1}
                        maxValue={1}
                        ranges={{
                          blue: [-0.25, 0.25],
                          average: [-0.50, 0.50],
                          bad: [-Infinity, Infinity],
                        }}>
                        {data.r_polarity}
                      </ProgressBar>
                    </LabeledList.Item>
                    <LabeledList.Item label="Injection Polarity">
                      <Button
                        fluid
                        icon={data.r_polarity_injection ? "plus-circle" : "minus-circle"}
                        color={data.r_polarity_injection ? "white" : "black"}
                        content={data.r_polarity_injection ? "Positive" : "Negative"}
                        onClick={() => act('polarity')}
                      />
                    </LabeledList.Item>
                    <LabeledList.Item label="Reaction Containment">
                      <ProgressBar
                        value={data.r_containment}
                        minValue={0}
                        maxValue={100}
                        ranges={{
                          red: [-Infinity, Infinity],
                        }} />
                    </LabeledList.Item>
                    <LabeledList.Item label="Reactor Controls">
                      <Section>
                        <Button
                          fluid
                          icon="fire"
                          color="orange"
                          content="Initialize"
                          enabled={data.r_state <= 1}
                          onClick={() => act('ignition')}
                        />
                        <Button
                          fluid
                          icon="ban"
                          color="red"
                          content="Terminate"
                          enabled={data.r_state <= 1}
                          onClick={() => act('shutdown')}
                        />
                        <Button
                          fluid
                          icon="snowflake"
                          color={data.r_cooling && "blue"}
                          content={"Cycle Coolant"}
                          onClick={() => act('cooling')}
                        />
                      </Section>
                    </LabeledList.Item>
                  </LabeledList>
                </Section>
              </Flex.Item>
            </Flex>
          </Section>
          <Section title="Nucleium Injection">
            <Slider
              value={data.r_injection_rate}
              fillValue={data.r_injection_rate}
              minValue={0}
              maxValue={25}
              ranges={{
                default: [5, 20],
                yellow: [2.5, Infinity],
                bad: [-Infinity, 2.5],
              }}
              step={1}
              stepPixelSize={27}
              onDrag={(e, value) => act('injection_allocation', {
                adjust: value,
              })}>
              {data.r_injection_rate + ' mol/s'}
            </Slider>
          </Section>
          <Section title="Reaction Statistics">
            Temperature:
            <ProgressBar
              minvalue={0}
              maxvalue={1000}
              value={data.r_temp}
              color={data.r_temp === 0 ? "default" : null}
              ranges={{
                blue: [25, 70],
                good: [70, 175],
                yellow: [175, 200],
                average: [200, 600],
                bad: [-Infinity, Infinity],
              }}>
              {toFixed(data.r_temp) + ' °C'}
            </ProgressBar>
            Reaction Rate:
            <ProgressBar
              value={data.r_reaction_rate}
              minValue={0}
              maxValue={25}
              color={data.r_temp === 0 ? "default" : null}
              ranges={{
                bad: [-Infinity, 5],
                teal: [5, Infinity],
              }}>
              {data.r_reaction_rate + ' mol/s'}
            </ProgressBar>
            Screen Capacity:
            <ProgressBar
              value={data.r_energy_output}
              minValue={0}
              maxValue={50}
              color={(data.r_energy_output === 0 && data.r_temp > 0) ? "red" : "yellow"} >
              {data.r_energy_output + ' GJ'}
            </ProgressBar>
          </Section>
        </Section>
      </Window.Content>
    </Window >
  );
};
