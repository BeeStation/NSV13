import { toTitleCase } from 'common/string';
import { Box, Section, Stack, Flex } from '../components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

export const Replicator = (props, context) => {
  const { act, data } = useBackend(context);
  const { menutier1, menutier2, menutier3, menutier4 } = data;
  return (
    <Window
      width={650}
      height={560}>
      <Window.Content scrollable>
        <Section>
          <Box>
            This Machine is voice activated, please announce your choice to the Replicator
            in one of the following formats:
            <br />
            <br />
            Computer/Alexa/Google/AI/Voice, Choice of Food, Cold/Warm/Hot/Extra Hot/Well Done.
          </Box>
        </Section>
        <Section
          title="Replicatable Food">
          <Flex>
            <Flex.Item grow={1}>
              <Section title="Nutritional supplements">
                {menutier1.map(food => (
                  <Section key={food}>
                    {toTitleCase(food)}
                  </Section>
                ))}
              </Section>
            </Flex.Item>
            <Flex.Item grow={1}>
              <Section title="Basic dishes">
                {menutier2.map(food => (
                  <Section key={food}>
                    {toTitleCase(food)}
                  </Section>
                ))}
              </Section>
            </Flex.Item>
            <Flex.Item grow={1}>
              <Section title="Complex dishes">
                {menutier3.map(food => (
                  <Section key={food}>
                    {toTitleCase(food)}
                  </Section>
                ))}
              </Section>
            </Flex.Item>
            <Flex.Item grow={1}>
              <Section title="Ingredients">
                {menutier4.map(food => (
                  <Section key={food}>
                    {toTitleCase(food)}
                  </Section>
                ))}
              </Section>
            </Flex.Item>
          </Flex>
        </Section>
      </Window.Content>
    </Window>
  );
};
