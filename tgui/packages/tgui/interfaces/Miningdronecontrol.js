import { Fragment } from 'inferno';
import { map } from 'common/collections';
import { useBackend } from '../backend';
import { Button, LabeledList, Section, Tabs, Box, NoticeBox, Grid } from '../components';
import { Window } from '../layouts';

export const Miningdronecontrol = (props, context) => {
  const { act, data } = useBackend(context);

  return (
    <Window resizable>
      <Window.Content scrollable>
        <Section>
          {map((value, key) => (
            <Section title={value.name}>
              <Box textAlign="center">
                <Box inline><b>Current Hold:</b> {value.cargoLen}/{value.cargoMax}</Box>
                <Box inline ml={2} mr={2}><b>Mining Quantity:</b> {value.mineAmount} ore(s)</Box>
                <Box inline><b>Power Usage:</b> {value.powerUsage} per cycle</Box>
              </Box>
              <br /><br />
              <Fragment>
                <b>Installed upgrades:</b> {value.upgradesLen}/{value.upgradesMax}
              </Fragment>
              <br />
              {map((value2, key) => (
                <Fragment>{value2.upName}<br /></Fragment>

              ))(value.upgrades)}
              <br />
              <b>Battery: {value.charge}/{value.maxcharge} ({value.chargePercent}%)</b>
              <br />
              <br />
              <Box>
                <Button inline icon="play"
                  content={!value.mining && ("Begin Mining") || ("Stop Mining")}
                  onClick={() => act('toggleMining', { bot: value.botID })} />
                <Button ml={2} inline icon="square" content="Unload"
                  onClick={() => act('unload', { bot: value.botID })} />
              </Box>
            </Section>
          ))(data.drones)}
        </Section>
      </Window.Content>
    </Window>
  );
};
