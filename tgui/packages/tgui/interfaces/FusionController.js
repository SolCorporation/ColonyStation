import { Fragment } from 'inferno';
import { map } from 'common/collections';
import { useBackend } from '../backend';
import { Button, LabeledList, Section, Tabs, Box, NoticeBox, Grid, ProgressBar } from '../components';
import { Window } from '../layouts';

export const FusionController = (props, context) => {
  const { act, data } = useBackend(context);

  return (
    <Window resizable>
      <Window.Content scrollable>
        <Section title="Reactor Monitoring">
        <LabeledList>
        <LabeledList.Item label="Internal Heat">
          {data.internal_heat}K
        </LabeledList.Item>
          <LabeledList.Item label="Max Internal Heat">
            {data.internal_heat_max}K
          </LabeledList.Item>
          <LabeledList.Divider />
          <LabeledList.Item label="Containment Heat">
            {data.core_heat}K
          </LabeledList.Item>
          <LabeledList.Item label="Max Containment Heat">
            {data.core_heat_max}K
          </LabeledList.Item>
          <LabeledList.Item label="Containment Health">
            {data.health}%
          </LabeledList.Item>
          <LabeledList.Divider />
          <LabeledList.Item label="Fuel Use">
            {data.fuel_use} moles per rod, per activation.
          </LabeledList.Item>
          <LabeledList.Item label="Fuel Rods">
            {data.fuel && (
              <Fragment>
              {map((value, key) => (
                <Section>
                  <LabeledList>
                  <LabeledList.Item label="Fuel Type">
                    {value.name}
                  </LabeledList.Item>
                  <LabeledList.Item label="Fuel Amount">
                    {value.amount} moles ({Math.round((value.amount / value.max_amount) * 100)}%)
                  </LabeledList.Item>
                  <LabeledList.Item label="Fuel Power Multiplier">
                    {value.power_multi}x per activation.
                  </LabeledList.Item>
                  <LabeledList.Item label="Fuel Heat Multiplier">
                    {value.heat_multi}x per activation.
                  </LabeledList.Item>
                  </LabeledList>
                </Section>

              ))(data.fuel)}
              </Fragment>
            ) || "None"}

          </LabeledList.Item>

        </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
