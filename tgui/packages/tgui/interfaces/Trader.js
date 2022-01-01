// NSV13

import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, ProgressBar, Knob } from '../components';
import { Window } from '../layouts';

export const Trader = (props, context) => {
  const { act, data } = useBackend(context);
  let imgStyle = { // I hate that I have to do this.
    max_width: "500px",
    max_height: "300px",
  };
  return (
    <Window
      resizable
      theme={data.theme}
      width={750}
      height={750}>
      <Window.Content scrollable>
        <Section title={data.desc}>
          <img style={imgStyle} src={data.image} />
          <p>{data.greeting}</p>
          <hr />
        </Section>
        <MissionTracker />
        <Section title={data.next_restock} buttons={(
          <Button fluid content={data.points} />
        )}>
          {Object.keys(data.items_info).map(key => {
            let value = data.items_info[key];
            return (
              <Section title={value.name + " (" + "x" + value.stock + ")"} key={key} buttons={(
                <Button
                  content={"$" + value.price}
                  icon="cart-arrow-down"
                  onClick={() => act('purchase', { target: value.id })} />)}>
                {value.desc}
              </Section>
            );
          })}
        </Section>
      </Window.Content>
    </Window>
  );
};

const MissionTracker = (props, context) => {
  const { act, data } = useBackend(context);
  if (data.holding_cargo && data.holding_cargo.length) {
    return (
      <Section title="Mission Tracking">
        {Object.keys(data.holding_cargo).map(key => {
          let value = data.holding_cargo[key];
          return (
            <Section title={value.name} key={key} buttons={(
              <Button
                content={"Receive Mission Cargo"}
                icon="arrow-circle-down"
                onClick={() => act('receive_cargo', { objective: value.id })} />
            )}>
              {value.brief}
            </Section>
          );
        })}
      </Section>
    );
  } else {
    return;
  }
};
