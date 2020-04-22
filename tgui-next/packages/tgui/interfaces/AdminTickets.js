import { Fragment } from 'inferno';
import { act } from '../byond';
import { Button, LabeledList, NoticeBox, Section } from '../components';

export const AdminTickets = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;

  return (
    <Fragment>
      <Section title="Unclaimed admin tickets:">
        {Object.keys(data.unclaimed).map(key => {
          let value = data.unclaimed[key];
          return (
            <Button
              key={key}
              fluid
              color={
                "blue"
              }
              content={`Ticket #${value.id}: ${value.initiator} (${value.antag_status})`}
              onClick={() => {
                act(ref, "view", {id: value.id});
              }}
            />);
        })}
      </Section>
      <Section title="Resolved admin tickets:">
        {Object.keys(data.resolved).map(key => {
          let value = data.resolved[key];
          return (
            <Button
              key={key}
              fluid
              color={
                "green"
              }
              content={`Ticket #${value.id}: ${value.initiator} (${value.antag_status})`}
              onClick={() => {
                act(ref, "view", {id: value.id});
              }}
            />);
        })}
      </Section>
    </Fragment>
  );
};
