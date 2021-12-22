// NSV13

import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Button, ProgressBar, Section } from '../components';
import { Window } from '../layouts';

export const IFF = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      resizable
      theme={data.iff_theme}
      width={600}
      height={800}>
      <Window.Content scrollable>
        {!data.is_hackerman && (
          <Section title="ACCESS DENIED.">
            <img src="https://wiki.baystation12.net/images/thumb/1/1f/Sol_Gov_Flag.png/300px-Sol_Gov_Flag.png" />
            <br />
            {"FILE ACCESS ENCRYPTED."}
            <br />
            {"Reprogramming IFF chips is in violation of SolGov conflict regulation #A230385-C. Lethal force is authorised for ships found to have tampered with their IFF."}
          </Section>
        )}
        {!!data.is_hackerman && (
          <Section title="./iff_bustr.exe">
            {`
.####.########.########.........########..##.....##..######..########.########.
..##..##.......##...............##.....##.##.....##.##....##....##....##.....##
..##..##.......##...............##.....##.##.....##.##..........##....##.....##
..##..######...######...........########..##.....##..######.....##....########.
..##..##.......##...............##.....##.##.....##.......##....##....##...##..
..##..##.......##...............##.....##.##.....##.##....##....##....##....##.
.####.##.......##.......#######.########...#######...######.....##....##.....##
            `}
            <br />
            {"___________________________________"}
            <br />
            {"br34ch3r.dll: loaded"}
            <br />
            {"5ysbr34k3r.dll: loaded"}
            <br />
            {"bye_bye_iff.dll: loaded"}
            <br />
            {"Hack Progress: "}
            <br />
            <ProgressBar
              value={(data.hack_progress / data.hack_goal * 100) * 0.01}
              ranges={{
                good: [0.95, Infinity],
                average: [0.15, 0.9],
                bad: [-Infinity, 0.15],
              }} />

          </Section>
        )}

      </Window.Content>
    </Window>
  );
};
