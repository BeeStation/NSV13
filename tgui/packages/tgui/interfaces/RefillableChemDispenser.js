import { toFixed } from 'common/math';
import { toTitleCase } from 'common/string';
import { useBackend } from '../backend';
import { AnimatedNumber, Box, Button, Icon, LabeledList, ProgressBar, Section, Table } from '../components';
import { Window } from '../layouts';

export const RefillableChemDispenser = (props, context) => {
  const { act, data } = useBackend(context);
  const isBeakerLoaded = data.isBeakerLoaded || 0;
  const recording = !!data.recordingRecipe;
  // TODO: Change how this piece of shit is built on server side
  // It has to be a list, not a fucking OBJECT!
  const recipes = Object.keys(data.recipes)
    .map(name => ({
      name,
      contents: data.recipes[name],
    }));
  const beakerTransferAmounts = data.beakerTransferAmounts || [];
  const beakerContents = recording
    && Object.keys(data.recordingRecipe)
      .map(id => ({
        id,
        name: toTitleCase(id.replace(/_/, ' ')),
        volume: data.recordingRecipe[id],
      }))
    || data.beakerContents
    || [];
  return (
    <Window
      width={635}
      height={620}>
      <Window.Content scrollable>
        <Section
          title="Status"
          buttons={recording && (
            <Box inline mx={1} color="red">
              <Icon name="circle" mr={1} />
              Recording
            </Box>
          )}>
          <LabeledList>
            <LabeledList.Item label="Capacity">
              <ProgressBar
                value={data.volume / data.maxVolume}>
                {toFixed(data.volume) + ' units'}
              </ProgressBar>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title="Recipes"
          buttons={(
            <>
              {!recording && (
                <Box inline mx={1}>
                  <Button
                    color="transparent"
                    content="Clear recipes"
                    onClick={() => act('clear_recipes')} />
                </Box>
              )}
              {!recording && (
                <Button
                  icon="circle"
                  // disabled={!data.isBeakerLoaded}
                  content="Record"
                  onClick={() => act('record_recipe')} />
              )}
              {recording && (
                <Button
                  icon="ban"
                  color="transparent"
                  content="Discard"
                  onClick={() => act('cancel_recording')} />
              )}
              {recording && (
                <Button
                  icon="save"
                  color="green"
                  content="Save"
                  onClick={() => act('save_recording')} />
              )}
            </>
          )}>
          <Box mr={-1}>
            {recipes.map(recipe => (
              <Button
                key={recipe.name}
                icon="tint"
                width="147px"
                lineHeight="21px"
                content={recipe.name}
                onClick={() => act('dispense_recipe', {
                  recipe: recipe.name,
                })} />
            ))}
            {recipes.length === 0 && (
              <Box color="light-gray">
                No recipes.
              </Box>
            )}
          </Box>
        </Section>
        <Section
          title="Dispense"
          buttons={(
            beakerTransferAmounts.map(amount => (
              <Button
                key={amount}
                icon="plus"
                selected={amount === data.amount}
                content={amount}
                onClick={() => act('amount', {
                  target: amount,
                })} />
            ))
          )}>
          <Box mr={-1}>
            {data.chemicals.map(chemical => (
              <Button
                key={chemical.id}
                icon="tint"
                width="147px"
                lineHeight="21px"
                content={chemical.title + " (" + chemical.volume + ")"}
                disabled={chemical.volume === 0 && !recording}
                onClick={() => act('dispense', {
                  reagent: chemical.id,
                })} />
            ))}
          </Box>
        </Section>
        <Section
          title="Beaker"
          buttons={!!isBeakerLoaded && (
            <>
              <Box inline color="label" mr={2}>
                <AnimatedNumber
                  value={data.beakerCurrentVolume}
                  initial={0} />
                {` / ${data.beakerMaxVolume} units`}
              </Box>
              <Box inline color="label" mr={1}>
                Mode:
              </Box>
              <Button
                color={data.mode ? 'good' : 'bad'}
                icon={data.mode ? 'exchange-alt' : 'times'}
                content={data.mode ? 'Transfer' : 'Destroy'}
                onClick={() => act('toggleMode')} />
              <Button
                icon="eject"
                content="Eject"
                onClick={() => act('eject')} />
            </>
          )}>
          {!isBeakerLoaded && !recording && (
            <Box color="label" mt="3px" mb="5px">
              No beaker loaded.
            </Box>
          )}
          {!!isBeakerLoaded && beakerContents.length === 0 && (
            <Box color="label" mt="3px" mb="5px">
              Beaker is empty.
            </Box>
          )}
          <ChemicalBuffer>
            {beakerContents.map(chemical => (
              <ChemicalBufferEntry
                key={chemical.id}
                chemical={chemical} />
            ))}
          </ChemicalBuffer>
        </Section>
      </Window.Content>
    </Window>
  );
};

const ChemicalBuffer = Table;

const ChemicalBufferEntry = (props, context) => {
  const { act, recording } = useBackend(context);
  const { chemical } = props;
  return (
    <Table.Row key={chemical.name}>
      <Table.Cell color="label">
        <AnimatedNumber
          value={chemical.volume}
          initial={0} />
        {` units of ${chemical.name}`}
      </Table.Cell>
      <Table.Cell collapsing>
        <Button
          content="1"
          disabled={recording}
          onClick={() => act('transfer', {
            id: chemical.id,
            amount: 1,
          })} />
        <Button
          content="5"
          disabled={recording}
          onClick={() => act('transfer', {
            id: chemical.id,
            amount: 5,
          })} />
        <Button
          content="10"
          disabled={recording}
          onClick={() => act('transfer', {
            id: chemical.id,
            amount: 10,
          })} />
        <Button
          content="All"
          disabled={recording}
          onClick={() => act('transfer', {
            id: chemical.id,
            amount: 1000,
          })} />
        <Button
          icon="ellipsis-h"
          title="Custom amount"
          disabled={recording}
          onClick={() => act('transfer', {
            id: chemical.id,
            amount: -1,
          })} />
      </Table.Cell>
    </Table.Row>
  );
};
