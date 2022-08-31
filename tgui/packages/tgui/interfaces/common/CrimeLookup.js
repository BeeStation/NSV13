import { useBackend } from '../../backend';
import { Box, Button, Icon, LabeledList } from '../../components';

export const CrimeLookup = (props, context) => {
  const { offence } = props;
  const { act } = useBackend(context);
  if(!offence) {
    return (
      <Box>
        No Crimes Loaded!
      </Box>
    );
  }

  return (
    <LabeledList>
      <LabeledList.Item label="Crime">
        {offence.name}
      </LabeledList.Item>
      <LabeledList.Item label="Description">
        {offence.desc}
      </LabeledList.Item>
    </LabeledList>
  );
};
