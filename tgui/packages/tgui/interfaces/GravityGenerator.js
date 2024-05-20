import { useBackend } from '../backend';
import { Box, Button, LabeledList, NoticeBox, ProgressBar, Section } from '../components';
import { Window } from '../layouts';

export const GravityGenerator = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    charging_state,
    operational,
    emagged,
    theme,
  } = data; { /* NSV13 - added theme and emagged as vars*/ }
  return (
    <Window
      width={400}
      height={600}
      theme={theme}> {/* NSV13 - theme change on emag*/ }
      <Window.Content>
        {!operational && (
          <NoticeBox>
            No data available
          </NoticeBox>
        )}
        {/* NSV13 - gravgen emag info*/ }
        {!!operational && !!emagged && (
          <NoticeBox danger>
            {'ERR - GR&!%$$ %$&/(!%$) ?)!&$§ ERROR, #!&%# 2G'}
          </NoticeBox>
        )}
        {/* NSV13 end*/ }
        {!!operational && charging_state !== 0 && (
          <NoticeBox danger>
            WARNING - Radiation detected
          </NoticeBox>
        )}
        {!!operational && charging_state === 0 && (
          <NoticeBox success>
            No radiation detected
          </NoticeBox>
        )}
        {!!operational && (
          <GravityGeneratorContent />
        )}
      </Window.Content>
    </Window>
  );
};

const GravityGeneratorContent = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    breaker,
    charge_count,
    charging_state,
    on,
    operational,
  } = data;
  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Power">
          <Button
            icon={breaker ? 'power-off' : 'times'}
            content={breaker ? 'On' : 'Off'}
            selected={breaker}
            disabled={!operational}
            onClick={() => act('gentoggle')} />
        </LabeledList.Item>
        <LabeledList.Item label="Gravity Charge">
          <ProgressBar
            value={charge_count / 100}
            ranges={{
              good: [0.7, Infinity],
              average: [0.3, 0.7],
              bad: [-Infinity, 0.3],
            }} />
        </LabeledList.Item>
        <LabeledList.Item label="Charge Mode">
          {charging_state === 0 && (
            on && (
              <Box color="good">
                Fully Charged
              </Box>
            ) || (
              <Box color="bad">
                Not Charging
              </Box>
            ))}
          {charging_state === 1 && (
            <Box color="average">
              Charging
            </Box>
          )}
          {charging_state === 2 && (
            <Box color="average">
              Discharging
            </Box>
          )}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
