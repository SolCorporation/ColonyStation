import { Fragment } from 'inferno';
import { map } from 'common/collections';
import { useBackend } from '../backend';
import { Button, LabeledList, Section, Tabs, Box, NoticeBox, Grid } from '../components';
import { Window } from '../layouts';

export const NeutronController = (props, context) => {
  const { act, data } = useBackend(context);

  return (
    <Window resizable>
      <Window.Content scrollable>
        <Section>
          {map((value, key) => (
            <Section title={value.injName}>
              <Box inline><b>Fuel Production Amount:</b> {value.fuelAmount}% per cycle</Box>
              <br /><br />
              <b>Installed upgrades:</b>
              <br />
              {map((value2, key) => (
                <Fragment>{value2.upNameN}<br /></Fragment>

              ))(value.NUps)}
              <br />
              <b>Produced Fuel:</b>
              <br />
              <Button inline icon="cog"
                content={!!value.fuel && ("Tritium") || ("Deuterium")}
                onClick={() => act('toggleFuel', { inj: value.inj })} />
              <br />
              <br />
              <Button inline icon={!value.running && ("play") || ("stop")}
                content={!!value.running && ("Stop Fuel Production") || ("Start Fuel Production")}
                selected={!!value.running}
                onClick={() => act('toggleActive', { inj: value.inj })} />
            </Section>
          ))(data.injector)}
        </Section>
      </Window.Content>
    </Window>
  );
};
