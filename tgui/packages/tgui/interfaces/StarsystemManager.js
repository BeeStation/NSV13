// NSV13

import { useBackend, useLocalState } from '../backend';
import { Button, Section, Table, Input, Flex } from '../components';
import { Window } from '../layouts';
import { createSearch } from 'common/string';
import { drawStarmap } from './Starmap';

export const StarsystemManager = (props, context) => {
  const { act, data } = useBackend(context);

  const handleSystemAction = (system) => setSearchText(system.name);

  const [
    searchText,
    setSearchText,
  ] = useLocalState(context, 'searchText', '');

  const Search = createSearch(searchText, item => {
    return item;
  });

  const makeFleetButton = fleet => {
    return (
      <Button key={fleet}
        content={fleet.name}
        icon="space-shuttle"
        color={fleet.color}
        onClick={() => act('fleetAct', { id: fleet.id })} />
    );
  };

  const makeObjectButton = thing => {
    return (
      <Button key={thing}
        content={thing.name}
        icon="space-shuttle"
        color={thing.color}
        onClick={() => act('objectAct', { id: thing.id })} />
    );
  };

  const makeSystem = system => {
    let Fleets = (system.fleets).map(makeFleetButton);
    let OtherObjects = (system.objects).map(makeObjectButton);
    return (
      <Section title={`${system.name}`}>
        <Button
          content={"Send fleet"}
          icon={"hammer"}
          onClick={() => act('createFleet', { sys_id: system.sys_id })} />
        <Button
          content={"Create object"}
          icon={"sun"}
          onClick={() => act('createObject', { sys_id: system.sys_id })} />
        <Button
          content={"Hide/Unhide system"}
          icon={"eye-slash"}
          onClick={() => act('hideSystem', { sys_id: system.sys_id })} />
        <Button
          content={"Variables"}
          icon={"eye"}
          onClick={() => act('systemVV', { sys_id: system.sys_id })} /><br />
        {/* The string manipulations are to capitalize the first letter */}
        Alignment: {system.alignment.charAt(0).toUpperCase() + system.alignment.slice(1)}<br />
        System Type: {system.system_type}<br />
        <br />
        {Fleets}
        {OtherObjects}
      </Section>
    );
  };

  const Header = (
    <Section
      title={
        <Table>
          <Table.Row>
            <Table.Cell>
              {"Starsystem Management"}
            </Table.Cell>
            <Table.Cell
              textAlign="right">
              <Input
                placeholder="Search"
                value={searchText}
                onInput={(e, value) => setSearchText(value)}
                mx={1}
              />
            </Table.Cell>
          </Table.Row>
        </Table>
      } />
  );

  let searchSystems = (data.star_systems).filter(system => Search(system.name)).map(makeSystem);
  let searchObjects = (data.star_systems).filter(system => system.objects.some(obj => Search(obj.name))).map(makeSystem);
  let searchFleets = (data.star_systems).filter(system => system.fleets.some(obj => Search(obj.name))).map(makeSystem);
  let Systems = searchSystems.concat(searchObjects.concat(searchFleets));
  return (
    <Window
      resizable
      theme="ntos"
      width={800}
      height={600}>
      <Window.Content scrollable>
        {Header}
        <Flex>
          <Flex.Item
            width={200}>
            <Section>
              {Systems}
            </Section>
          </Flex.Item>
          <Flex.Item
            width={400}>
            {drawStarmap(props, context, handleSystemAction)}
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
