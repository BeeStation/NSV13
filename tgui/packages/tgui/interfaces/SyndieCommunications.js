import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, LabeledList, NumberInput, Section } from '../components';
import { Window } from '../layouts';

export const SyndieCommunications = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    authenthicated,
    auth_id,
  } = data;
  return(
    <Window resizable theme="syndicate">
      <Window.Content scrollable>
        Currently logged in as {auth_id}
        <Button
          icon={authenthicated ? "sign-out-alt" : "sign-in-alt"}
          content={authenthicated ? "Log Out" : "Log In"}
          color={authenthicated ? "bad" : "good"}
          OnClick={() => {
           act(authenthicated ? 'logout' : 'login');
          }}/>
        </Window.Content>
    </Window>
  );
};
