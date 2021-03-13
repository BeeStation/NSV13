import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, Chart, Slider, Flex, LabeledList, ProgressBar } from '../components';
import { Window } from '../layouts';
import { toFixed } from 'common/math';

export const ArmourPlatingNanorepairPump = (props, context) => {
  const { act, data } = useBackend(context);
  const { repair_records } = data;
  const armourData = repair_records.armour.map((value, i) => [i, value]);
  const structureData = repair_records.structure.map((value, i) => [i, value]);
  return (
    <Window
      resizable
      theme="ntos"
      width={500}
      height={380}>
      <Window.Content scrollable>
        <Section title={data.quadrant}>
          <Section title="Repair Rates:">
            <Flex spacing={1}>
              <Flex.Item width="200px">
                <Section>
                  <LabeledList>
                    <LabeledList.Item label="Armour Repair Rate">
                      <ProgressBar
                        value={data.armour_repair_amount}
                        minValue={0}
                        maxValue={8}
                        color="blue">
                        {(data.armour_repair_amount)}
                      </ProgressBar>
                    </LabeledList.Item>
                    <LabeledList.Item label="Structure Repair Rate">
                      <ProgressBar
                        value={data.structure_repair_amount}
                        minValue={0}
                        maxValue={2}
                        color="red">
                        {(data.structure_repair_amount)}
                      </ProgressBar>
                    </LabeledList.Item>
                  </LabeledList>
                </Section>
              </Flex.Item>
              <Flex.Item grow={1}>
                <Section position="relative" height="100%">
                  <Chart.Line
                    fillPositionedParent
                    data={armourData}
                    rangeX={[0, armourData.length - 1]}
                    rangeY={[0, 8]}
                    strokeColor="rgba(28, 113, 177, 1)"
                    fillColor="rgba(28, 113, 177, 0.1)" />
                  <Chart.Line
                    fillPositionedParent
                    data={structureData}
                    rangeX={[0, structureData.length - 1]}
                    rangeY={[0, 8]}
                    strokeColor="rgba(255, 0, 0, 1)"
                    fillColor="rgba(255, 0, 0, 0.1)" />
                </Section>
              </Flex.Item>
            </Flex>
          </Section>
        </Section>
        <Section title="System Resources Allocated to Armour:">
          <Slider
            value={data.armour_allocation}
            minValue={0}
            maxValue={100}
            step={1}
            stepPixelSize={5}
            onDrag={(e, value) => act('armour_allocation', {
              adjust: value,
            })}
          />
        </Section>
        <Section title="System Resources Allocated to Internal Structure:">
          <Slider
            value={data.structure_allocation}
            minValue={0}
            maxValue={100}
            step={1}
            stepPixelSize={5}
            onDrag={(e, value) => act('structure_allocation', {
              adjust: value,
            })}
          />
        </Section>
      </Window.Content>
    </Window>
  );
};
