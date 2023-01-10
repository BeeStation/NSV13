import { right } from '@popperjs/core';
import { useBackend } from '../backend';
import { Button, NoticeBox, Section } from '../components';
import { Window } from '../layouts';

export const InteractionMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const { categories, interactions, descriptions, colors } = data;
  const { self, ref_self, ref_user } = data;
  const { block_interact } = data;

  return (
    <Window width={400} height={600} title={"Interact - " + self}>
      <Window.Content scrollable>
        {block_interact && (
          <NoticeBox>Unable to Interact</NoticeBox>
        ) || (
          <NoticeBox>Able to Interact</NoticeBox>
        )}
        <Section key="interactions">
          {categories.map((category) => (
            <Section key={category} title={category}>
              {interactions[category].map((interaction) => (
                <Section key={interaction}>
                  <left>
                    <Button margin={0} padding={0}
                      disabled={block_interact}
                      color={block_interact ? "grey" : colors[interaction]}
                      content={interaction}
                      icon="exclamation-circle"
                      onClick={() => act('interact', { interaction: interaction, selfref: ref_self, userref: ref_user })}
                    /><br />
                    {descriptions[interaction]}
                  </left>
                </Section>
              ))}
            </Section>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
