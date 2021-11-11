// NSV13

import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Button, Section, ProgressBar } from '../components';
import { Window } from '../layouts';
import { drawStarmap } from './Starmap';

// This entire fucking file is terrible. Turn back now. Don't look at this.
// There are so many issues with the conditional rendering here which I do not have the time to fix.

export const Astrometrics = (props, context) => {
  const { act, data } = useBackend(context);
  const screen = data.screen;
  let scan_target = data.scan_target;

  return (
    <Window
      resizable
      theme="ntos"
      width={800}
      height={660}>
      <Window.Content scrollable>
        <Section>
          {screen === 0 && (
            <Fragment>
              <Button
                content="Ship Information"
                icon="info-circle"
                onClick={() =>
                  act('shipinf')} />
              <Button
                content="Show Map"
                icon="map"
                onClick={() =>
                  act('map')} />
              <Section title={`Current scan: ${scan_target}`}
                buttons={(
                  <Button
                    content="Cancel Scan"
                    icon="stop-circle-o"
                    disabled={scan_target}
                    onClick={() =>
                      act('cancel_scan')} />
                )}>
                <ProgressBar
                  value={(data.scan_progress/data.scan_goal * 100)* 0.01}
                  ranges={{
                    good: [0.95, Infinity],
                    average: [0.15, 0.95],
                    bad: [-Infinity, 0.15],
                  }} />
              </Section>
            </Fragment>
          )}
          {screen === 1 && drawStarmap(props, context)}
          {screen === 2 && (
            <Fragment>
              <Button
                content="Ship Information"
                icon="info-circle"
                onClick={() =>
                  act('shipinf')} />
              <Button
                content="Show Map"
                icon="map"
                onClick={() =>
                  act('map')} />
              <br />
              <Section title={`Current scan: ${scan_target}`}
                buttons={(
                  <Button
                    content="Cancel Scan"
                    icon="stop-circle-o"
                    disabled={!data.can_cancel}
                    onClick={() =>
                      act('cancel_scan')} />
                )}>
                <ProgressBar
                  value={(data.scan_progress/data.scan_goal * 100)* 0.01}
                  ranges={{
                    good: [0.95, Infinity],
                    average: [0.15, 0.95],
                    bad: [-Infinity, 0.15],
                  }} />
              </Section>
              <Section title="System info:"
                buttons={(
                  <Button
                    content="Scan"
                    icon="arrow-right"
                    disabled={!!data.scanned}
                    onClick={() =>
                      act('scan')} />
                )}>
                Distance: {data.star_dist ? data.star_dist + " LY" : "0LY"}
                <br />
                Alignment: {data.alignment ? data.alignment : "Unknown"}
                <br />
                System type: {data.system_type ? data.system_type : "Unknown"}
                <br />
              </Section>
              <Section title="Telemetry info:">
                {Object.keys(data.anomalies).map(key => {
                  let value = data.anomalies[key];
                  if (!data.scanned) {
                    return;
                  }
                  if (value.scannable) {
                    if (scan_target !== value.name) {
                      return (
                        <Section title={value.name}>
                          Available research: {value.points}
                          <Button key={key}
                            content="Scan"
                            icon="bullseye"
                            color={value.visible && "green"}
                            onClick={() => act('scan_anomaly', { anomaly_id: value.anomaly_id })} />
                        </Section>
                      );
                    }
                    else {
                      return (
                        <Section title={value.name}>
                          Available research: {value.points}
                          <Button key={key}
                            content="Stop scan"
                            icon="bullseye"
                            color={value.visible && "green"}
                            onClick={() => act('cancel_scan', { anomaly_id: value.anomaly_id })} />
                        </Section>
                      );
                    }
                  }
                  else {
                    return (
                      <Section title={value.name}>
                        <Button key={key}
                          content="Info"
                          icon="search"
                          color={value.visible && "green"}
                          onClick={() => act('info', { anomaly_id: value.anomaly_id })} />
                      </Section>
                    );
                  }
                })}
              </Section>
            </Fragment>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
