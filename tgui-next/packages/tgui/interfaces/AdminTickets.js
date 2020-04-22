import { Fragment } from 'inferno';
import { act } from '../byond';
import { Button, LabeledList, NoticeBox, Section } from '../components';

export const AdminTickets = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;

  return (
    <Fragment>
      <Section title="Your active tickets:">
        {Object.keys(data.ours).map(key => {
          let value = data.ours[key];
          return (
            <Fragment key={key}>
              <Button
                key={key}
                fluid
                color={
                  "blue"
                }
                content={`Ticket #${value.id}: ${value.initiator} (${value.title})`}
                onClick={() => {
                  act(ref, "view", { id: value.id });
                }}
              />
              <Button
                content="(PP)"
                onClick={() => {
                  act(ref, "pp", {id: value.id});
                }} />
              <Button
                content="(VV)"
                onClick={() => {
                  act(ref, "vv", {id: value.id});
                }} />
              <Button
                content="(SM)"
                onClick={() => {
                  act(ref, "sm", {id: value.id});
                }} />
              <Button
                content="(FLW)"
                onClick={() => {
                  act(ref, "flw", {id: value.id});
                }} />
              <Button
                key={key}
                icon={value.ours ? 'times-circle' : 'check-circle'}
                color={
                  "good"
                }
                content={value.ours ? 'Un-Claim' : 'Claim'}
                onClick={() => {
                  act(ref, "claim", { id: value.id });
                }} />
              <Button
                content={value.open ? 'Resolve' : 'Re-open'}
                color="good"
                icon={value.open ? 'check-circle' : 'eject'}
                onClick={() => {
                  act(ref, "resolve", {id: value.id});
                }} />
              <Button
                content="Re-class"
                color="average"
                icon="layer-group"
                onClick={() => {
                  act(ref, "re-class", {id: value.id});
                }} />
              <Button
                content="Close"
                color="bad"
                icon="exclamation-triangle"
                onClick={() => {
                  act(ref, "close", {id: value.id});
                }} />

            </Fragment>);
        })}
      </Section>
      <Section title="Unclaimed admin tickets:">
        {Object.keys(data.unclaimed).map(key => {
          let value = data.unclaimed[key];
          return (
            <Fragment key={key}>
              <Button
                key={key}
                fluid
                color={
                  "blue"
                }
                content={`Ticket #${value.id}: ${value.initiator} (${value.title})`}
                onClick={() => {
                  act(ref, "view", { id: value.id });
                }}
              />
              <Button
                content="(PP)"
                onClick={() => {
                  act(ref, "pp", {id: value.id});
                }} />
              <Button
                content="(VV)"
                onClick={() => {
                  act(ref, "vv", {id: value.id});
                }} />
              <Button
                content="(SM)"
                onClick={() => {
                  act(ref, "sm", {id: value.id});
                }} />
              <Button
                content="(FLW)"
                onClick={() => {
                  act(ref, "flw", {id: value.id});
                }} />
              <Button
                key={key}
                icon={value.ours ? 'times-circle' : 'check-circle'}
                color={
                  "good"
                }
                content={value.ours ? 'Un-Claim' : 'Claim'}
                onClick={() => {
                  act(ref, "claim", { id: value.id });
                }} />
              <Button
                content={value.open ? 'Resolve' : 'Re-open'}
                color="good"
                icon={value.open ? 'check-circle' : 'eject'}
                onClick={() => {
                  act(ref, "resolve", {id: value.id});
                }} />
              <Button
                content="Re-class"
                color="average"
                icon="layer-group"
                onClick={() => {
                  act(ref, "re-class", {id: value.id});
                }} />
              <Button
                content="Close"
                color="bad"
                icon="exclamation-triangle"
                onClick={() => {
                  act(ref, "close", {id: value.id});
                }} />

            </Fragment>);
        })}
      </Section>
      <Section title="Unclaimed mentor tickets:">
        {Object.keys(data.mentor).map(key => {
          let value = data.mentor[key];
          return (
            <Fragment key={key}>
              <Button
                key={key}
                fluid
                color={
                  "blue"
                }
                content={`Ticket #${value.id}: ${value.initiator} (${value.title})`}
                onClick={() => {
                  act(ref, "view", { id: value.id });
                }}
              />
              <Button
                content="(PP)"
                onClick={() => {
                  act(ref, "pp", {id: value.id});
                }} />
              <Button
                content="(VV)"
                onClick={() => {
                  act(ref, "vv", {id: value.id});
                }} />
              <Button
                content="(SM)"
                onClick={() => {
                  act(ref, "sm", {id: value.id});
                }} />
              <Button
                content="(FLW)"
                onClick={() => {
                  act(ref, "flw", {id: value.id});
                }} />
              <Button
                key={key}
                icon={value.ours ? 'times-circle' : 'check-circle'}
                color={
                  "good"
                }
                content={value.ours ? 'Un-Claim' : 'Claim'}
                onClick={() => {
                  act(ref, "claim", { id: value.id });
                }} />
              <Button
                content={value.open ? 'Resolve' : 'Re-open'}
                color="good"
                icon={value.open ? 'check-circle' : 'eject'}
                onClick={() => {
                  act(ref, "resolve", {id: value.id});
                }} />
              <Button
                content="Re-class"
                color="average"
                icon="layer-group"
                onClick={() => {
                  act(ref, "re-class", {id: value.id});
                }} />
              <Button
                content="Close"
                color="bad"
                icon="exclamation-triangle"
                onClick={() => {
                  act(ref, "close", {id: value.id});
                }} />

            </Fragment>);
        })}
      </Section>
      <Section title="Resolved tickets:">
        <Button
          fluid
          content={data.show_resolved ? "Hide Resolved Tickets":" Show Resolved Tickets"}
          icon={data.show_resolved ? 'chevron-up' : 'chevron-down'}
          onClick={() => {
            act(ref, "toggle_resolved");
          }} 
        />
        {Object.keys(data.resolved).map(key => {
          let value = data.resolved[key];
          return (
            <Fragment key={key}>
              <Button
                key={key}
                fluid
                color={
                  "brown"
                }
                content={`Ticket #${value.id}: ${value.initiator} (${value.title})`}
                onClick={() => {
                  act(ref, "view", { id: value.id });
                }}
              />
              <Button
                content="(PP)"
                onClick={() => {
                  act(ref, "pp", {id: value.id});
                }} />
              <Button
                content="(VV)"
                onClick={() => {
                  act(ref, "vv", {id: value.id});
                }} />
              <Button
                content="(SM)"
                onClick={() => {
                  act(ref, "sm", {id: value.id});
                }} />
              <Button
                content="(FLW)"
                onClick={() => {
                  act(ref, "flw", {id: value.id});
                }} />
              <Button
                key={key}
                icon={value.ours ? 'times-circle' : 'check-circle'}
                color={
                  "good"
                }
                content={value.ours ? 'Un-Claim' : 'Claim'}
                onClick={() => {
                  act(ref, "claim", { id: value.id });
                }} />
              <Button
                content={value.open ? 'Resolve' : 'Re-open'}
                color="good"
                icon={value.open ? 'check-circle' : 'eject'}
                onClick={() => {
                  act(ref, "resolve", {id: value.id});
                }} />
              <Button
                content="Re-class"
                color="average"
                icon="layer-group"
                onClick={() => {
                  act(ref, "re-class", {id: value.id});
                }} />
              <Button
                content="Close"
                color="bad"
                icon="exclamation-triangle"
                onClick={() => {
                  act(ref, "close", {id: value.id});
                }} />

            </Fragment>); 
        })}
      </Section>
    </Fragment>
  );
};
