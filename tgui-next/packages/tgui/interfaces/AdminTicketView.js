import { Fragment } from 'inferno';
import { act } from '../byond';
import { Button, LabeledList, NoticeBox, Section } from '../components';

export const AdminTicketView = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;

  return (
    <Fragment>
      <Section title="Actions:">
        <Button
          fluid
          color={
            "blue"
          }
          content={`Ticket #${data.id}: ${data.initiator} (${data.title})`}
          onClick={() => {
            act(ref, "reply");
          }}
        />
        <Button
          content="(PP)"
          disabled={!data.isAdmin}
          onClick={() => {
            act(ref, "pp");
          }} />
        <Button
          content="(VV)"
          disabled={!data.isAdmin}
          onClick={() => {
            act(ref, "vv");
          }} />
        <Button
          content="(SM)"
          disabled={!data.isAdmin}
          onClick={() => {
            act(ref, "sm");
          }} />
        <Button
          content="(FLW)"
          disabled={!data.isAdmin}
          onClick={() => {
            act(ref, "flw");
          }} />
        <Button
          icon={data.ours ? 'times-circle' : 'check-circle'}
          color={
            "good"
          }
          content={data.ours ? 'Un-Claim' : 'Claim'}
          onClick={() => {
            act(ref, "claim");
          }} />
        <Button
          content={data.open ? 'Resolve' : 'Re-open'}
          color="good"
          icon={data.open ? 'check-circle' : 'eject'}
          onClick={() => {
            act(ref, "resolve");
          }} />
        <Button
          content="Re-classify"
          color="average"
          icon="layer-group"
          onClick={() => {
            act(ref, "re-class");
          }} />
        <Button
          content="Reject"
          color="bad"
          icon="exclamation-triangle"
          onClick={() => {
            act(ref, "reject");
          }} />
      </Section>
      <Section title="Ticket log:">
        {Object.keys(data.logs).map(key => {
          let value = data.logs[key];
          return (
            <Button
              key={key}
              fluid
              color={
                value.colour
              }
              content={value.line}
              onClick={() => {
                act(ref, "reply");
              }}
            />);
        })}
      </Section>
    </Fragment>
  );
};