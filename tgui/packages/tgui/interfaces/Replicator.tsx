import { BooleanLike } from '../../common/react';
import { classes } from '../../common/react';
import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';
import { Box, Section, Dropdown, Table, Tabs, LabeledList, NoticeBox, Button, ProgressBar, Stack } from '../components';

type ReplicatorData = {
  replicating: BooleanLike;
  biomass: number;
  max_visual_biomass: number;
  selected_temperature: string;
  temperatures: string[];
  categories: Category[];
};

type Category = {
  name: string;
  items: Design[];
};

type Design = {
  id: number;
  name: string;
  disable: BooleanLike;
  cost: number;
};

export const Replicator = (props, context) => {
  const { act, data } = useBackend<ReplicatorData>(context);
  const {
    replicating,
    biomass,
    max_visual_biomass,
    categories,
    selected_temperature,
    temperatures,
  } = data;

  const [selectedCategory, setSelectedCategory] = useLocalState<string>(
    context,
    'category',
    data.categories[0]?.name
  );
  const items
    = categories.find((category) => category.name === selectedCategory)?.items
    || [];
  return (
    <Window width={500} height={500}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section fill>
              <NoticeBox info>
                This Machine is both Voice and Touch Activated.
                <br />
                Please announce your choice to the Food Replicator in one of the following formats:
                <br />
                Computer/Alexa/Google/AI/Voice.
                <br />
                Choice of Food.
                <br />
                Cold/Warm/Hot/Extra Hot/Well Done.
              </NoticeBox>
              <LabeledList>
                <LabeledList.Item label="Biomass">
                  <ProgressBar
                    value={biomass}
                    minValue={0}
                    maxValue={max_visual_biomass}
                    color="good">
                    <Box
                      lineHeight={1.9}
                      style={{
                        'text-shadow': '1px 1px 0 black',
                      }}>
                      {`${parseFloat(biomass.toFixed(2))} units`}
                    </Box>
                  </ProgressBar>
                </LabeledList.Item>
                <LabeledList.Item label="Temperature">
                  <Dropdown
                    width="100%"
                    selected={selected_temperature}
                    options={temperatures}
                    onSelected={(value) =>
                      act('change_temperature', {
                        updated_temperature: value,
                      })} />
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Tabs fluid>
              {categories.map((category) => (
                <Tabs.Tab
                  align="center"
                  key={category.name}
                  selected={category.name === selectedCategory}
                  onClick={() => setSelectedCategory(category.name)}>
                  {category.name}
                </Tabs.Tab>
              ))}
            </Tabs>
          </Stack.Item>
          <Stack.Item grow mt={'2px'}>
            <Section fill scrollable>
              <Table>
                <ItemList
                  replicating={replicating}
                  biomass={biomass}
                  items={items}
                />
              </Table>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ItemList = (props, context) => {
  const { act } = useBackend(context);
  const items = props.items.map((item) => {
    const disabled = (props.replicating || props.biomass < Math.ceil(item.cost));
    return {
      ...item,
      disabled,
    };
  });
  return items.map((item) => (
    <Table.Row key={item.id}>
      <Table.Cell>
        <span
          className={classes(['design32x32', item.id])}
          style={{
            'vertical-align': 'middle',
          }}
        />{' '}
        <b>{item.name}</b>
      </Table.Cell>
      <Table.Cell collapsing>
        <Button
          fluid
          align="right"
          content={
            parseFloat(
              (item.cost).toFixed(2)
            ) + ' BIO'
          }
          disabled={!item.disabled}
          onClick={() =>
            act('replicate', {
              id: item.id,
            })}
        />
      </Table.Cell>
    </Table.Row>
  ));
};
