// NSV13

import { toTitleCase } from 'common/string';
import { useBackend } from '../backend';
import { Box, Button, Dropdown, NumberInput, ProgressBar, Flex, Section, Table } from '../components';
import { Window } from '../layouts';
import { round, scale } from 'common/math';

export const RailgunForge = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    t1_volume,
    t1_alloy_lock,
    t1_processing,
    t1_material,
    t2_volume,
    t2_alloy_lock,
    t2_processing,
    t2_material,
  } = data;
  return (
    <Window
      width={460}
      height={350}>
      <Window.Content scrollable>
        <Section>
          <Button
            content="Print Slug"
            icon="paperclip"
            onClick={() => act('print_slug')} />
          <Button
            content="Print Canister Round"
            icon="tg-air-tank"
            onClick={() => act('print_canister')} />
        </Section>
        <br />
        <Section title="Coating Tank">
          <Flex>
            <Flex.Item>
              <Dropdown
                overflow-y="scroll"
                selected={t1_material}
                options={["Iron", "Silver", "Gold", "Diamond", "Uranium", "Plasma", "Bluespace", "Bananium", "Titanium", "Copper"]}
                onSelected={value => act('t1_list', { value })}
              />
            </Flex.Item>
            Tank Volume:
            <Flex.Item width="200px">
              <ProgressBar
                value={(data.t1_volume / 100)}
                ranges={{
                  good: [0.75, Infinity],
                  average: [0.25, 0.75],
                  bad: [-Infinity, 0.25],
                }} />
            </Flex.Item>
          </Flex>
          <Button
            content="Set Coating Tank Material"
            icon="exclamation-triangle"
            color={data.t1_alloy_lock && "good"}
            onClick={() => act('t1_set_material')} />
          <Button
            content="Process Tank 1"
            icon="exclamation-triangle"
            color={data.t1_processing && "good"}
            onClick={() => act('t1_set_processing')} />
          <Button
            content="Purge Tank 1"
            icon="exclamation-triangle"
            color={"bad"}
            onClick={() => act('purge_t1')} />
        </Section>
        <Section title="Core Tank">
          <Flex>
            <Flex.Item>
              <Dropdown
                overflow-y="scroll"
                selected={t2_material}
                options={["Iron", "Silver", "Gold", "Diamond", "Uranium", "Plasma", "Bluespace", "Bananium", "Titanium", "Copper"]}
                onSelected={value => act('t2_list', { value })}
              />
            </Flex.Item>
            Tank Volume:
            <Flex.Item width="200px">
              <ProgressBar
                value={(data.t2_volume / 100)}
                ranges={{
                  good: [0.75, Infinity],
                  average: [0.25, 0.75],
                  bad: [-Infinity, 0.25],
                }} />
            </Flex.Item>
          </Flex>
          <Button
            content="Set Core Tank Material"
            icon="exclamation-triangle"
            color={data.t2_alloy_lock && "good"}
            onClick={() => act('t2_set_material')} />
          <Button
            content="Process Tank 2"
            icon="exclamation-triangle"
            color={data.t2_processing && "good"}
            onClick={() => act('t2_set_processing')} />
          <Button
            content="Purge Tank 2"
            icon="exclamation-triangle"
            color={"bad"}
            onClick={() => act('purge_t2')} />
        </Section>
      </Window.Content>
    </Window>
  );
};
