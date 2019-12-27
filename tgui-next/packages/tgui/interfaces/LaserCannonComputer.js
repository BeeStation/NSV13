import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, LabeledList, ProgressBar, Section } from '../components';

export const LaserCannonComputer = props => {
  const { act, data } = useBackend(props);

  let inputState;
  if (data.capacityPercent >= 100) {
    inputState = 'good';
  }
  else if (data.charging) {
    inputState = 'average';
  }
  else {
    inputState = 'bad';
  }

  return (
    <Fragment>
      <Section title="Current Charge">
        <ProgressBar
          value={data.capacityPercent * 0.01}
          ranges={{
            good: [0.5, Infinity],
            average: [0.15, 0.5],
            bad: [-Infinity, 0.15],
          }} />
      </Section>
      <Section title="Input">
        <LabeledList>
          <LabeledList.Item
            label="Charge Mode"
            buttons={
              <Button
                icon={data.charging ? 'sync-alt' : 'times'}
                selected={data.charging}
                onClick={() => act('trycharge')}>
                {data.charging ? 'Auto' : 'Off'}
              </Button>
            }>
            <Box color={inputState}>
              {data.capacityPercent >= 100
                ? 'Fully Charged'
                : data.charging
                  ? 'Charging'
                  : 'Not Charging'}
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label="Target Input">
            <ProgressBar
              value={data.chargeRate/data.maxChargeRate}
              content={data.chargeRateText} />
          </LabeledList.Item>
          <LabeledList.Item label="Adjust Input">
            <Button
              icon="fast-backward"
              disabled={data.chargeRate === 0}
              onClick={() => act('input', {
                target: 'min',
              })} />
            <Button
              icon="backward"
              disabled={data.chargeRate === 0}
              onClick={() => act('input', {
                adjust: -10000,
              })} />
            <Button
              icon="forward"
              disabled={data.chargeRate === data.maxChargeRate}
              onClick={() => act('input', {
                adjust: 10000,
              })} />
            <Button
              icon="fast-forward"
              disabled={data.chargeRate === data.maxChargeRate}
              onClick={() => act('input', {
                target: 'max',
              })} />
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title="Safety">
        <Button
          icon={data.safety ? 'sync-alt' : 'times'}
          selected={data.safety}
          onClick={() => act('trysafety')}>
          {data.safety ? 'Disengage Safety' : 'Engage Safety'}
        </Button>
      </Section>
    </Fragment>
  );
};
