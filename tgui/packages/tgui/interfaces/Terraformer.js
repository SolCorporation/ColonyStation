import { Fragment } from 'inferno';
import { map } from 'common/collections';
import { useBackend } from '../backend';
import { Button, ProgressBar, Section, Box, Grid } from '../components';
import { Window } from '../layouts';

export const Terraformer = (props, context) => {
  const { act, data } = useBackend(context);

  return (
    <Window>
      <Window.Content>
        <Section title="Terraforming Controls">
          <b>Terraforming Gasses</b>
          <br />
          {map((value, key) => (
            <Button icon={!value.active && ("square-o") || ("check-square")} selected={value.active}
              content={value.gasName} onClick={() => act('toggleGas', { gasType: value.gas })} />
          ))(data.gasses)}

          <br /><br />
          <Fragment><b>Terraforming Cycle Delay: </b>{data.cooldown} second(s)</Fragment>
          <br /><br />
          <Fragment><b>Moles per cycle: </b>{data.molesPerCycle} mole(s)</Fragment>
          <br /><br />
          <Fragment><b>Power Usage: </b>{data.powerUsage}</Fragment>
          <br /><br />
          <Button icon={!!data.on && ("stop") || ("play")} selected={data.on}
            content={!!data.on && ("Stop Terraforming") || ("Start Terraforming")}
            onClick={() => act('toggleOn')} />

        </Section>
        <Section title="Atmospheric Contents">
          {!!data.o2 > 0 && (
            <Fragment><b>Oxygen: </b>{data.o2} mole(s)<br /><br /></Fragment>
          )}
          {!!data.n2 > 0 && (
            <Fragment><b>Nitrogen: </b>{data.n2} mole(s)<br /><br /></Fragment>
          )}
          {!!data.co2 > 0 && (
            <Fragment><b>Carbon Dioxide: </b>{data.co2} mole(s)<br /><br /></Fragment>
          )}
          {!!data.n2o > 0 && (
            <Fragment><b>Nitrous Oxide: </b>{data.n2o} mole(s)<br /><br /></Fragment>
          )}
          {!!data.plasma > 0 && (
            <Fragment><b>Plasma: </b>{data.plasma} mole(s)<br /><br /></Fragment>
          )}
          {!!data.temp > 0 && (
            <Fragment><b>Temperature: </b>{data.temp}K<br /><br /></Fragment>
          )}
          {!!data.pressure > 0 && (
            <Fragment><b>Total Pressure: </b>{data.pressure} kPa<br /><br /></Fragment>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
