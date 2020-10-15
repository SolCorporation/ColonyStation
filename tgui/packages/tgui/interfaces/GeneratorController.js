import { Fragment } from 'inferno';
import { map } from 'common/collections';
import { useBackend } from '../backend';
import { Button, LabeledList, Section, Tabs, Box, ProgressBar } from '../components';
import { Window } from '../layouts';

export const GeneratorController = (props, context) => {
  const { act, data } = useBackend(context);

  return (
    <Window>
      <Window.Content scrollable>
        <Section title="Turbines">
          {map((value, key) => (
            <Section title={value.name}>
              <LabeledList>
              <LabeledList.Item label="Throughput Usage">
                {Math.round((value.last_tick_steam / value.max_tick) * 100)}%
              </LabeledList.Item>
                <LabeledList.Item label="Throughput">
                  {value.last_tick_steam}L
                </LabeledList.Item>
                <LabeledList.Item label="Max Throughput">
                  {value.max_tick}L
                </LabeledList.Item>
                <LabeledList.Divider />
                <LabeledList.Item label="Efficiency">
                  {Math.round(value.efficiency * 100)}%
                </LabeledList.Item>
                <LabeledList.Item label="Optimal Temperature">
                  {value.optimal_temp}K
                </LabeledList.Item>
                <LabeledList.Item label="Power Conversion">
                  {value.conversion}W per steam unit processed at optimal temperature.
                </LabeledList.Item>
              </LabeledList>
            </Section>
          ))(data.generators)}
        </Section>
      </Window.Content>
    </Window>
  );
};
