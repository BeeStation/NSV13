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
          <Button content="Do you have any work going?" onClick={() => act('mission')} />
        </Section>
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
