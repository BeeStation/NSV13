import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, ProgressBar, Knob, Map, StarButton } from '../components';
import { Window } from '../layouts';

export const Dradis = (props, context) => {
  const { act, data } = useBackend(context);
  // Floats representing the different alpha values for different filtered objects.
  let showFriendlies = data.showFriendlies;
  let showEnemies = data.showEnemies;
  let showAsteroids = data.showAsteroids;
  let showAnomalies = data.showAnomalies;
  let focus_x = data.focus_x;
  let focus_y = data.focus_y;
  let width_mod = data.width_mod;
  let zoom_factor = data.zoom_factor;
  let scale_factor = 5*zoom_factor;
  let multiplier = 562.5*zoom_factor;
  let rangeStyle = "left:"+focus_x*scale_factor+"px;bottom:"+focus_y*scale_factor+"px; width:"+width_mod*multiplier+"px; height:"+width_mod*multiplier+"px;margin-bottom:"+(-1)*((width_mod*multiplier)/2)+"px;margin-left:"+(-1)*((width_mod*multiplier)/2)+"px;";
  return (
    <Window
      resizable
      theme="hackerman"
      width={700}
      height={750}>
      <Window.Content scrollable>
        <Section
          title="Settings:"
          buttons={(
            <Fragment>
              <Button
                content="Zoom in"
                icon="search-plus"
                onClick={() => act('zoomin')} />
              <Button
                content="Zoom out"
                icon="search-minus"
                onClick={() => act('zoomout')} />
              <Button
                content="Radar Pulse"
                icon="bullseye"
                disabled={!data.can_radar_pulse}
                onClick={() => act('radar_pulse')} />
              <Button
                content={data.sensor_mode}
                icon="project-diagram"
                onClick={() => act('sensor_mode')} />
              <Button
                content={data.pulse_delay}
                icon="stopwatch"
                onClick={() => act('radar_delay')} />
              <Button
                content="Re-focus"
                icon="camera"
                onClick={() => location.reload()} />
            </Fragment>
          )}>
          Allies:
          <Knob
            inline
            size={1.25}
            color={!!showFriendlies && 'green'}
            value={showFriendlies}
            unit="scan strength"
            minValue="0"
            maxValue="100"
            step={1}
            stepPixelSize={1}
            onDrag={(e, value) => act('showFriendlies', { alpha: value })} />
          Enemies:
          <Knob
            inline
            size={1.25}
            color={!!showEnemies && 'green'}
            value={showEnemies}
            unit="scan strength"
            minValue="0"
            maxValue="100"
            step={1}
            stepPixelSize={1}
            onDrag={(e, value) => act('showEnemies', { alpha: value })} />
          Asteroids:
          <Knob
            inline
            size={1.25}
            color={!!showAsteroids && 'green'}
            value={showAsteroids}
            unit="scan strength"
            minValue="0"
            maxValue="100"
            step={1}
            stepPixelSize={1}
            onDrag={(e, value) => act('showAsteroids', { alpha: value })} />
          Anomalies
          <Knob
            inline
            size={1.25}
            color={!!showAnomalies && 'green'}
            value={showAnomalies}
            unit="scan strength"
            minValue="0"
            maxValue="100"
            step={1}
            stepPixelSize={1}
            onDrag={(e, value) => act('showAnomalies', { alpha: value })} />
          <Map initial_focus_x={focus_x}
            initial_focus_y={focus_y}
            initial_scale_factor={scale_factor}
            grid="1">
            <Fragment>
              {Object.keys(data.ships).map(key => {
                let value = data.ships[key];
                let borderType = "1px solid "+value.colour;
                let markerStyle = {
                  height: '1px',
                  position: 'absolute',
                  left: value.x*scale_factor+'px',
                  bottom: value.y*scale_factor+'px',
                  border: borderType,
                  opacity: value.opacity,
                  transition: "all 0.5s ease-out",
                };
                let markerType = "star_marker"+"_"+value.alignment;
                return (
                  <Fragment key={key}>
                    {!!value.name && (
                      <StarButton unselectable="on" style={markerStyle} className={markerType}
                        content="" onClick={() => act('hail', { target: value.id })}>
                        <span class="star_label">
                          <p>{value.name}</p>
                        </span>
                      </StarButton>
                    )}
                  </Fragment>);
              })}
              <div id="rangeCircle" style={rangeStyle} />
            </Fragment>
          </Map>
        </Section>
      </Window.Content>
    </Window>
  );
};
