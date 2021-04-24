import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, ProgressBar, Knob, Map, StarButton } from '../components';
import { Window } from '../layouts';

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
                  {Object.keys(data.star_systems).map(key => {
                    let value = data.star_systems[key];
                    let borderType = "star_marker_outline_blue";
                    let is_current = value.is_current;
                    let in_range = value.in_range;
                    { !!is_current && (
                      borderType = "1px solid #193a7a"
                    ) || (
                      borderType = in_range ? "1px solid #008000" : "1px solid #a30000"
                    ); }
                    let markerStyle = {
                      height: '1px',
                      position: 'absolute',
                      left: value.x*12+'px',
                      bottom: value.y*12+'px',
                      border: borderType,
                    };
                    let markerType = "star_marker"+"_"+value.alignment;
                    let distance = value.distance;
                    let label = value.label;
                    { !!label && (
                      label = "|"+value.label
                    ); }
                    return (
                      <Fragment key={key}>
                        {!!value.name && (
                          <StarButton unselectable="on" style={markerStyle} className={markerType}
                            content="" tooltip={distance}
                            onClick={() =>
                              act('select_system', { star_id: value.star_id })}>
                            <span class="star_label">
                              <p>{value.name} {label}</p>
                            </span>
                          </StarButton>

                        )}
                      </Fragment>);
                  })}
                  {Object.keys(data.lines).map(key => {
                    let value = data.lines[key];
                    // Css properties with hypens are auto-converted to camel case. Important!
                    let lineStyle = {
                      height: '1px',
                      position: 'absolute',
                      left: value.x*12+'px',
                      bottom: value.y*12+'px',
                      width: value.len*12+'px',
                      border: '0.5px solid '+value.colour,
                      opacity: value.opacity,
                      transform: 'rotate('+value.angle+'deg)',
                      msTransform: 'rotate('+value.angle+'deg)',
                      transformOrigin: 'center left',
                      zIndex: value.priority,
                    };
                    return (
                      <Fragment key={key}>
                        <div style={lineStyle} class="line" />
                      </Fragment>);
                  })}
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
              <Section title={data.star_name}
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
