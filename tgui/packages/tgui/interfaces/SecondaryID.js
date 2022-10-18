import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Button, Section } from '../components';
import { Window } from '../layouts';

export const SecondaryID = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      resizable
      theme={data.theme}
      width={580}
      height={400}>
      <Window.Content scrollable>
        <Section title="Accesses:" buttons={
          <Fragment>
            <Button
              content="Eject Current ID"
              disabled={!data.modifying}
              icon="eject"
              onClick={() => act("eject")} />
            <Button
              content="Modify Assignment"
              disabled={!data.modifying}
              icon="cog"
              onClick={() => act("modifyAssignment")} />
            <Button
              content="Modify Name"
              disabled={!data.modifying}
              icon="pen"
              onClick={() => act("modifyName")} />
          </Fragment>
        }>
          {Object.keys(data.accessList).map(key => {
            let value = data.accessList[key];
            return (
              <Button
                key={key}
                content={value.title}
                icon={value.hasAccess ? "check-circle" : "times"}
                selected={!value.hasAccess}
                disabled={!data.modifying}
                onClick={() => act('accessMod', { access: value.access })} />
            );
          })}
        </Section>
      </Window.Content>
    </Window>
  );
};
