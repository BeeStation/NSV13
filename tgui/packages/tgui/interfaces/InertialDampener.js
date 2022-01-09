// NSV13

import { useBackend } from '../backend';
import { Button, Section, Slider, Box } from '../components';
import { Window } from '../layouts';

export const InertialDampener = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      title="Inertial Dampener"
      theme="ntos"
      width={263}
      height={165} >
      <Window.Content scrollable>
        <Section>
          <Button
            icon="fas fa-power-off"
            selected={data.on}
            mr={0.5}
            inline
            onClick={() => act('toggle_on')} />
          <Box
            inline >
            Power requirement: {data.power_usage}
          </Box>
          <Section>
            <Box>
              Dampening effect: {data.min_strength===data.max_strength ? data.min_strength + "%" : ""}
            </Box>
            {data.min_strength!==data.max_strength ? <Slider
              value={data.strength}
              minValue={Math.floor(data.min_strength)}
              maxValue={Math.ceil(data.max_strength)}
              unit={"%"}
              step={1}
              stepPixelSize={260/data.max_strength}
              onDrag={(e, value) => act('strength', {
                value: value,
              })} />
              : "" }
            <Box>
              Range: {data.min_range===data.max_range ? data.min_range + " meters" : ""}
            </Box>
            {data.min_range!==data.max_range ? <Slider
              value={data.range}
              minValue={data.min_range}
              maxValue={data.max_range}
              unit={" meters"}
              step={1}
              stepPixelSize={270/data.max_range}
              onDrag={(e, value) => act('range', {
                value: value,
              })} />
              : "" }
          </Section>
        </Section>
      </Window.Content>
    </Window>
  );
};
