import { useBackend } from '../backend';
import { Button, LabeledList, Section, Table } from '../components';
import { NtosWindow } from '../layouts';

const missionStatusToText = s => {
  if (s === 2) {
    return "Mission complete!";
  }
  if (s === -1) {
    return "Mission failed!";
  }
  return "Mission active";
};

export const NtosHailLogs = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <NtosWindow
      resizable
      width={440}
      height={650}>
      <NtosWindow.Content scrollable>
        <Section title="Ship status">
          <LabeledList>
            <LabeledList.Item label="Name">
              {data.ship_name}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <MissionTable />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

const MissionTable = (props, context) => {
  const { act, data } = useBackend(context);
  const missions = data.missions || [];
  return (
    <Section title="Missions">
      {missions.map(mission => (
        <Section title={"Request from "+mission.client+" - "+missionStatusToText(mission.status)} key={mission}>
          {mission.desc}
          <br />
          {"Payment: "+mission.reward}
        </Section>
      ))}
    </Section>
  );
};
