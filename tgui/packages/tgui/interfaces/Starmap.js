import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, ProgressBar, Knob, Map, StarButton } from '../components';
import { Window } from '../layouts';

export const Starmap = (props, context) => {
  const { act, data } = useBackend(context);
  const screen = data.screen;
  const travelling = data.travelling;
  let arrowStyle = "position: absolute; left: "+data.freepointer_x*12+"px;";
  arrowStyle += "bottom: "+data.freepointer_y*12+"px;";
  arrowStyle += "filter: progid:DXImageTransform.Microsoft.Matrix(sizingMethod='auto expand', M11="+data.freepointer_cos+",";
  arrowStyle += "M12="+(-data.freepointer_sin)+",M21="+data.freepointer_sin+", M22="+data.freepointer_cos+");"
  arrowStyle += "ms-filter: progid:DXImageTransform.Microsoft.Matrix(sizingMethod='auto expand', M11="+data.freepointer_cos+",";
  arrowStyle += "M12="+(-data.freepointer_sin)+",M21="+data.freepointer_sin+", M22="+data.freepointer_cos+");"
  arrowStyle += "-ms-transform: matrix("+data.freepointer_cos+","+-data.freepointer_sin+","+data.freepointer_sin+","+data.freepointer_cos+", 0, 0);";
  arrowStyle += "transform: matrix("+data.freepointer_cos+","+-data.freepointer_sin+","+data.freepointer_sin+","+data.freepointer_cos+", 0, 0);";
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
                  value={(data.ftl_progress/data.ftl_goal * 100)* 0.01}
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
		      <Map initial_focus_x={data.focus_x} initial_focus_y={data.focus_y}>
			    <Fragment>
                {Object.keys(data.star_systems).map(key => {
                  let value = data.star_systems[key];
                  let style = "position: absolute; left:";
				  style += value.x*12;
				  style += "px; bottom:"
				  style += value.y*12;
				  style += "px;"
				  let markerType = "star_marker"+"_"+value.alignment
				  let borderType = "star_marker_outline_blue"
				  let is_current = value.is_current;
				  let in_range = value.in_range;
				  let distance = value.distance;
				//  style='star_marker {{is_current ? "star_marker_outline_blue" : (in_range ? "star_marker_outline_green" : "star_marker_outline_red")}} star_marker_{{visited ? "visited" : "unvisited"}}_{{alignment}}'>
				  {!!is_current && (
					  borderType = "border: 1px solid #193a7a;"
				  ) || (
					  borderType = in_range ? "border: 1px solid #008000;" : "border: 1px solid #a30000;"
				  )}
				  style += borderType;
				  let label = value.label
				  {!!label && (
				    label = "|"+value.label
				  )}
                  return (
                    <Fragment key={key}>
                      {!!value.name && (
                        <StarButton style={style} className={markerType} content="" tooltip={distance}
                        onClick={() => 
                        act('select_system', { star_id: value.star_id })}
						>
						<span class='star_label'><p>{value.name} {label}</p></span>
						</StarButton>
					
                      )}
                    </Fragment>);
                })}
                {Object.keys(data.lines).map(key => {
                  let value = data.lines[key];
                  let style = "height: 1px; position: absolute; left:";
				  style += value.x*12;
				  style += "px; bottom:"
				  style += value.y*12;
				  style += "px;width:"
				  style += value.len*12;
				  style += "px; border: 0.5px solid "
				  style += value.colour + ";"
				  style += "opacity: "+value.opacity+";"
                  style += "transform: rotate("+value.angle+"deg) translate(0px,0px);-ms-transform: rotate("+value.angle+"deg) translate(0px, 0px);";
				  style += "transform-origin: center left;z-index:"+value.priority+";"
			//	  style += "transform: rotate("+value.angle+"deg) translate(0px,0px);-ms-transform: rotate("+value.angle+"deg translate(0px,0px);background-color:"+value.colour+";border-color:"+value.colour+";position:absolute;height:1px;transform-origin:center left;z-index:1";
                  return (
                    <Fragment key={key}>
					  <div style={style}></div>
                    </Fragment>);
                })}
				

                
				{!!travelling && (
				  <span unselectable='on' style={arrowStyle}><i class="fa fa-arrow-right"></i></span>
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
                  disabled={!data.can_cancel}
                  onClick={() => 
                    act('cancel_jump')} />
              </Section>
            </Fragment>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
