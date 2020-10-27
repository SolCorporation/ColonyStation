import { Fragment } from 'inferno';
import { map } from 'common/collections';
import { useBackend } from '../backend';
import { Button, LabeledList, Section, Tabs, Box, ProgressBar } from '../components';
import { Window } from '../layouts';

export const CoolingController = (props, context) => {
  const { act, data } = useBackend(context);

  return (
    <Window>
      <Window.Content scrollable>
        <Section title="Condensers">
          {map((value, key) => (
            <Section title={value.name}>
              <LabeledList>
              <LabeledList.Item label="Cooling Output Temperature">
                {value.cooling}K
              </LabeledList.Item>
                <LabeledList.Item label="Last Throughput">
                  {value.cooled_last}L
                </LabeledList.Item>
                <LabeledList.Item label="Cooling Capacity">
                  {value.max_capacity}L
                </LabeledList.Item>
                <LabeledList.Item label="Temperature Outputted">
                  {value.temp_output}K
                </LabeledList.Item>
              </LabeledList>
            </Section>
          ))(data.condensers)}
        </Section>
        <Section title="Heat Exchangers">
          {map((value, key) => (
            <Section title={value.name}>
              <LabeledList>
              <LabeledList.Item label="Cooling Output Temperature">
                {value.cooling}K
              </LabeledList.Item>
                <LabeledList.Item label="Last Throughput">
                  {value.cooled_last}L
                </LabeledList.Item>
                <LabeledList.Item label="Cooling Capacity">
                  {value.max_capacity}L
                </LabeledList.Item>
                <LabeledList.Item label="Temperature Outputted">
                  {value.temp_output}K
                </LabeledList.Item>
              </LabeledList>
            </Section>
          ))(data.heat_exchangers)}
        </Section>
      </Window.Content>
    </Window>
  );
};
