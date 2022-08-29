import { filter, map, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { reduce } from '../../tgui-bench/lib/benchmark';
import { useBackend, useLocalState } from '../backend';
import { Button, Section, Stack, Modal, Dropdown, Tabs, Box, Input, Flex, ProgressBar, Collapsible, Icon, Divider } from '../components';
import { Window, NtosWindow } from '../layouts';

export const LawBook = (props, context) => {
  return (
    <Window
    resizable
    width={560}
    height={600}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item width="120px">
            <Section fill scrollable>
              HELLO
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  )
}
