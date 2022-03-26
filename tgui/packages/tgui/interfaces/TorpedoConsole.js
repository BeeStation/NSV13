//NSV13

import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { classes } from 'common/react';
import { createSearch } from 'common/string';
import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Button, ByondUi, Input, Section, ProgressBar, LabeledList } from '../components';
import { Window } from '../layouts';

/**
 * Returns previous and next camera names relative to the currently
 * active camera.
 */
const prevNextCamera = (cameras, activeCamera) => {
  if (!activeCamera) {
    return [];
  }
  const index = cameras.findIndex(camera => (
    camera.name === activeCamera.name
  ));
  return [
    cameras[index - 1]?.name,
    cameras[index + 1]?.name,
  ];
};

/**
 * Camera selector.
 *
 * Filters cameras, applies search terms and sorts the alphabetically.
 */
const selectCameras = (cameras, searchText = '') => {
  const testSearch = createSearch(searchText, camera => camera.name);
  return flow([
    // Null camera filter
    filter(camera => camera?.name),
    // Optional search term
    searchText && filter(testSearch),
    // Slightly expensive, but way better than sorting in BYOND
    sortBy(camera => camera.name),
  ])(cameras);
};

export const TorpedoConsole = (props, context) => {
  const { act, data, config } = useBackend(context);
  const { mapRef, activeCamera } = data;
  const cameras = selectCameras(data.cameras);
  const [
    prevCameraName,
    nextCameraName,
  ] = prevNextCamera(cameras, activeCamera);
  return (
    <Window
      width={870}
      height={708}>
      <div className="CameraConsole__left">
        <Window.Content scrollable>
          <TorpedoCameraContent />
          <TorpedoSelectionContent />
        </Window.Content>
        <Section>
          <Button
            icon="circle"
            content="Launch"
            disabled={!data.valid_to_fire}
            color="bad"
            onClick={() => act('launch')} />
        </Section>
      </div>
      <div className="CameraConsole__right">
        <div className="CameraConsole__toolbar">
          <b>Camera: </b>
          {activeCamera
            && activeCamera.name
            || '—'}
        </div>
        <div className="CameraConsole__toolbarRight">
          <Button
            icon="chevron-left"
            disabled={!prevCameraName}
            onClick={() => act('switch_camera', {
              name: prevCameraName,
            })} />
          <Button
            icon="chevron-right"
            disabled={!nextCameraName}
            onClick={() => act('switch_camera', {
              name: nextCameraName,
            })} />
        </div>
        <ByondUi
          className="CameraConsole__map"
          params={{
            id: mapRef,
            type: 'map',
          }} />
      </div>
    </Window>
  );
};

export const TorpedoCameraContent = (props, context) => {
  const { act, data } = useBackend(context);
  const [
    searchText,
    setSearchText,
  ] = useLocalState(context, 'searchText', '');
  const { activeCamera } = data;
  const cameras = selectCameras(data.cameras, searchText);
  return (
    <Fragment>
      <Section>
        {cameras.map(camera => (
          // We're not using the component here because performance
          // would be absolutely abysmal (50+ ms for each re-render).
          <div
            key={camera.name}
            title={camera.name}
            className={classes([
              'Button',
              'Button--fluid',
              'Button--color--transparent',
              'Button--ellipsis',
              activeCamera
              && camera.name === activeCamera.name
              && 'Button--selected',
            ])}
            onClick={() => act('switch_camera', {
              name: camera.name,
            })}>
            {camera.name}
          </div>
        ))}
      </Section>
    </Fragment>
  );
};

export const TorpedoSelectionContent = (props, context) => {
  const { act, data } = useBackend(context);
  const { torpedo_class } = []
  return (
    <Fragment>
      <Section>
        <Section title="Munitions in Silos">
          <Section>
            <ProgressBar
              content="NTP-2 530mm torpedo"
              value={data.torpedo_amount_normal}
              minValue={0}
              maxValue={data.max_torps}
              ranges={{
                good: [0.9, Infinity],
                average: [0.25, 0.9],
                bad: [-Infinity, 0.25],
              }} />
            <Button
              icon="square"
              color="bad"
              onClick={() => act('select_normal')}
            />
          </Section>
          <Section>
            <ProgressBar
              content="NTP-4 'BNKR' 430mm Armour Pentetrating Torpedo"
              value={data.torpedo_amount_shredder}
              minValue={0}
              maxValue={data.max_torps}
              ranges={{
                good: [0.9, Infinity],
                average: [0.25, 0.9],
                bad: [-Infinity, 0.25],
              }} />
            <Button
              icon="square"
              color="bad"
              onClick={() => act('select_shredder')}
            />
            <Section>
              <ProgressBar
                content="NTP-0x 'DCY' 530mm electronic countermeasure"
                value={data.torpedo_amount_decoy}
                minValue={0}
                maxValue={data.max_torps}
                ranges={{
                  good: [0.9, Infinity],
                  average: [0.25, 0.9],
                  bad: [-Infinity, 0.25],
                }} />
              <Button
                icon="square"
                color="bad"
                onClick={() => act('select_decoy')}
              />
            </Section>
            <Section>
              <ProgressBar
                content="NTP-6 'HLLF' 600mm Plasma Incendiary Torpedo"
                value={data.torpedo_amount_hellfire}
                minValue={0}
                maxValue={data.max_torps}
                ranges={{
                  good: [0.9, Infinity],
                  average: [0.25, 0.9],
                  bad: [-Infinity, 0.25],
                }} />
              <Button
                icon="square"
                color="bad"
                onClick={() => act('select_hellfire')}
              />
            </Section>
          </Section>
        </Section>
      </Section>
    </Fragment>
  );
};
