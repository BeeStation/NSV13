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
          content={`Ticket #${data.currentInfo["id"]}: ${data.currentInfo["initiator"]} (${data.currentInfo["title"]})`}
          onClick={() => {
            act(ref, "reply");
          }} />
        <Button
          icon="arrow-left"
          content="Back"
          onClick={() => {
            act(ref, "back");
          }} />
        <Button
          content="(PP)"
          onClick={() => {
            act(ref, "pp");
          }} />
        <Button
          content="(VV)"
          onClick={() => {
            act(ref, "vv");
          }} />
        <Button
          content="(SM)"
          onClick={() => {
            act(ref, "sm");
          }} />
        <Button
          content="(FLW)"
          onClick={() => {
            act(ref, "flw");
          }} />
        <Button
          content="(SMITE)"
          onClick={() => {
            act(ref, "smite");
          }} />
        <Button
          content="Resolve"
          color="good"
          icon="check-circle"
          onClick={() => {
            act(ref, "resolve");
          }} />
        <Button
          content="Re-class"
          color="average"
          icon="layer-group"
          onClick={() => {
            act(ref, "re-class");
          }} />
        <Button
          content="Close"
          color="bad"
          icon="exclamation-triangle"
          onClick={() => {
            act(ref, "close");
          }} />
      </Section>
      <Section title="Ticket log:">
        {Object.keys(data.log).map(key => {
          let value = data.log[key];
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