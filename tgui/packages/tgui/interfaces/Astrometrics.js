import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, ProgressBar, Knob, Map, StarButton } from '../components';
import { Window } from '../layouts';
import { drawSystemNodes, drawLines } from './Starmap';

// This entire fucking file is terrible. Turn back now. Don't look at this.
// There are so many issues with the conditional rendering here which I do not have the time to fix.

export const Astrometrics = (props, context) => {
  const { act, data } = useBackend(context);
  const screen = data.screen;
  const travelling = data.travelling;
  const can_cancel = data.can_cancel;
  let arrowStyle = "position: absolute; left: "+data.freepointer_x*12+"px;";
  let scan_target = data.scan_target;
  arrowStyle += "bottom: "+data.freepointer_y*12+"px;";
  arrowStyle += "filter: progid:DXImageTransform.Microsoft.";
  arrowStyle += "Matrix(sizingMethod='auto expand',";
  arrowStyle += "M11="+data.freepointer_cos+",";
  arrowStyle += "M12="+(-data.freepointer_sin)+",M21="+data.freepointer_sin+",";
  arrowStyle += "M22="+data.freepointer_cos+");";
  arrowStyle += "ms-filter: progid:";
  arrowStyle += "DXImageTransform.";
  arrowStyle += "Microsoft.Matrix(sizingMethod='auto expand',";
  arrowStyle += "M11="+data.freepointer_cos+",";
  arrowStyle += "M12="+(-data.freepointer_sin)+",";
  arrowStyle += "M21="+data.freepointer_sin+", M22="+data.freepointer_cos+");";
  arrowStyle += "-ms-transform: matrix("+data.freepointer_cos+",";
  arrowStyle += ""+-data.freepointer_sin+",";
  arrowStyle += ""+data.freepointer_sin+","+data.freepointer_cos+", 0, 0);";
  arrowStyle += "transform: matrix("+data.freepointer_cos+",";
  arrowStyle += ""+-data.freepointer_sin+",";
  arrowStyle += ""+data.freepointer_sin+","+data.freepointer_cos+", 0, 0);";
  arrowStyle += "transition: all 0.5s ease-out;";

  let Systems = (data.star_systems).map(drawSystemNodes);
  let Lines = (data.lines).map(drawLines);

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
              <Section title={`Current scan: ${data.scan_target}`}
                buttons={(
                  <Button
                    content="Cancel Scan"
                    icon="stop-circle-o"
                    disabled={data.scan_target}
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
          {screen === 1 && (
            <Fragment>
              <Button
                content="Ship Information"
                icon="info-circle"
                onClick={() =>
                  act('shipinf')} />
              <Button
                content="Show Map"
                icon="map"
                ilstyle="position:absolute;left:10px"
                onClick={() =>
                  act('map')} />
              <Map initial_focus_x={data.focus_x}
                initial_focus_y={data.focus_y}
                initial_scale_factor={12}>
                <Fragment>
                  {Systems}
                  {Lines}
                  {!!travelling && (
                    <span unselectable="on" style={arrowStyle}>
                      <i class="fa fa-arrow-right" />
                    </span>
                  )}
                </Fragment>
              </Map>
            </Fragment>
          )}
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
              <Section title={`Current scan: ${data.scan_target}`}
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
                    if (data.scan_target !== value.name) {
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
