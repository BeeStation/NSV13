import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, ProgressBar, Knob, Map, StarButton } from '../components';
import { Window } from '../layouts';

export const Starmap = (props, context) => {
  const { act, data } = useBackend(context);
  const screen = data.screen;
  const travelling = data.travelling;
  const can_cancel = data.can_cancel;
  const scale_factor = 12;
  let arrowStyle = "position: absolute; left: " + data.freepointer_x * 12 + "px;";
  arrowStyle += "bottom: " + data.freepointer_y * 12 + "px;";
  arrowStyle += "filter: progid:DXImageTransform.Microsoft.";
  arrowStyle += "Matrix(sizingMethod='auto expand',";
  arrowStyle += "M11=" + data.freepointer_cos + ",";
  arrowStyle += "M12=" + (-data.freepointer_sin) + ",M21=" + data.freepointer_sin + ",";
  arrowStyle += "M22=" + data.freepointer_cos + ");";
  arrowStyle += "ms-filter: progid:";
  arrowStyle += "DXImageTransform.";
  arrowStyle += "Microsoft.Matrix(sizingMethod='auto expand',";
  arrowStyle += "M11=" + data.freepointer_cos + ",";
  arrowStyle += "M12=" + (-data.freepointer_sin) + ",";
  arrowStyle += "M21=" + data.freepointer_sin + ", M22=" + data.freepointer_cos + ");";
  arrowStyle += "-ms-transform: matrix(" + data.freepointer_cos + ",";
  arrowStyle += "" + -data.freepointer_sin + ",";
  arrowStyle += "" + data.freepointer_sin + "," + data.freepointer_cos + ", 0, 0);";
  arrowStyle += "transform: matrix(" + data.freepointer_cos + ",";
  arrowStyle += "" + -data.freepointer_sin + ",";
  arrowStyle += "" + data.freepointer_sin + "," + data.freepointer_cos + ", 0, 0);";
  arrowStyle += "transition: all 0.5s ease-out;";
  return (
    <Window resizable theme="ntos">
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
              <Section title="Drive status:">
                <ProgressBar
                  value={(data.ftl_progress / data.ftl_goal * 100) * 0.01}
                  ranges={{
                    good: [0.95, Infinity],
                    average: [0.15, 0.9],
                    bad: [-Infinity, 0.15],
                  }} />
              </Section>
              {!!data.in_transit && (
                <Section title="Current system:">
                  In transit from:
                  <Button
                    content={data.from_star_name}
                    tooltip="Click to view information about star"
                    icon="star"
                    onClick={() =>
                      act('select_system', { star_id: data.from_star_id })} />
                  To:
                  <Button
                    content={data.to_star_name}
                    tooltip="Click to view information about star"
                    icon="star"
                    onClick={() =>
                      act('select_system', { star_id: data.to_star_id })} />
                  ETA: {Math.round(data.time_left)}
                </Section>
              ) || (
                <Section title="Current system:">
                  <Button
                    content={data.star_name}
                    tooltip="Click to view information about star"
                    icon="star"
                    onClick={() =>
                      act('star_id', { star_id: data.star_id })} />
                </Section>
              )}
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
              <Button
                content="Change Sector"
                icon="bullseye"
                onClick={() =>
                  act('sector')} />
              <Map initial_focus_x={data.focus_x}
                initial_focus_y={data.focus_y}
                initial_scale_factor={scale_factor}>
                <Fragment>
                  {Object.keys(data.star_systems).map(key => {
                    let value = data.star_systems[key];
                    let borderType = "star_marker_outline_blue";
                    let is_current = value.is_current;
                    let in_range = value.in_range;
                    {
                      !!is_current && (
                        borderType = "1px solid #193a7a"
                      ) || (
                        borderType = in_range ? "1px solid #008000" : "1px solid #a30000"
                      );
                    }
                    let markerStyle = {
                      height: '1px',
                      position: 'absolute',
                      left: value.x * 12 + 'px',
                      bottom: value.y * 12 + 'px',
                      border: borderType,
                    };
                    let markerType = "star_marker" + "_" + value.alignment;
                    let distance = value.distance;
                    let label = value.label;
                    {
                      !!label && (
                        label = "|" + value.label
                      );
                    }
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
                      left: value.x * 12 + 'px',
                      bottom: value.y * 12 + 'px',
                      width: value.len * 12 + 'px',
                      border: '0.5px solid ' + value.colour,
                      opacity: value.opacity,
                      transform: 'rotate(' + value.angle + 'deg)',
                      msTransform: 'rotate(' + value.angle + 'deg)',
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
              <Section title={data.star_name}>
                Distance: {data.star_dist ? data.star_dist + " LY" : "0LY"}
                <br />
                Alignment: {data.alignment ? data.alignment : "Unknown"}
                <br />
                <Button
                  content="Jump"
                  icon="arrow-right"
                  disabled={!data.can_jump}
                  onClick={() =>
                    act('jump')} />
                <Button
                  content="Cancel jump"
                  icon="stop-circle-o"
                  disabled={!can_cancel}
                  onClick={() =>
                    act('cancel_jump')} />
              </Section>
              <Section title="Drive status:">
                <ProgressBar
                  value={(data.ftl_progress / data.ftl_goal * 100) * 0.01}
                  ranges={{
                    good: [0.95, Infinity],
                    average: [0.15, 0.9],
                    bad: [-Infinity, 0.15],
                  }} />
              </Section>
            </Fragment>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
