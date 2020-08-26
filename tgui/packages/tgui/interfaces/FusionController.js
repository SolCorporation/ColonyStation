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
        {!data.hasMix && (
          <NoticeBox><h2>No Fuel Mix inserted</h2></NoticeBox>
        )}
        <Section title="Reactor Controls">
          {!!data.meltDown 
            && (<NoticeBox><h2>CORE MELTDOWN - REWELD CONTAINMENT CHAMBER</h2></NoticeBox>)}
          {!!data.overheating 
            && (<NoticeBox><h2>CORE OVERHEATING</h2></NoticeBox>)}
          <br />
          <b>Current Reactor Status:</b> {data.status}
          <br /><br />
          <b>Reactor Deuterium Status:</b>
          <ProgressBar color={data.deuterium >= 50 ? ("good") : ("average")}
            maxValue={100} value={data.deuterium} content={Math.round(data.deuterium) + "%"} />
          <br /><br />
          <b>Reactor Tritium Status:</b>
          <ProgressBar color={data.tritium >= 50 ? ("good") : ("average")}
            maxValue={100} value={data.tritium} content={Math.round(data.tritium) + "%"} />
          <br /><br /><br /><br />
          <Button inline icon={!!data.injecting && ("stop") || ("play")}
            content={!!data.injecting && ("Stop Fuel Injection") || ("Begin Fuel Injection")}
            onClick={() => act('toggleInject')}
            selected={!!data.injecting}
            disabled={!data.hasMix} />
          <Button inline icon="play"
            content="Spark Reaction"
            onClick={() => act('startReaction')}
            disabled={!!data.running && !data.hasMix} />
          <br />
          <Button inline icon={!!data.collecting && ("stop") || ("play")}
            content={!!data.collecting && ("Stop Heat Collection") || ("Start Heat Collection")}
            onClick={() => act('toggleCollect')}
            selected={!!data.collecting}
            disabled={!data.hasMix} />
          <Button inline icon={!!data.preheating && ("stop") || ("play")}
            content={!!data.preheating && ("Stop Preheating") || ("Start Preheating")}
            onClick={() => act('togglePreheat')}
            selected={!!data.preheating}
            disabled={!data.hasMix} />
          <br />
          <br />
          <Button inline icon="ban"
            content="Initiate Shutdown"
            onClick={() => act('flush')}
            disabled={!data.running}
            color="danger" />
          <br />
          <br />
          <b>Cryo Coolant</b>
          <ProgressBar color={data.cryo >= 50 ? ("good") : ("average")}
            maxValue={100} value={data.cryo} content={Math.round(data.cryo) + "%"} />
          <br /><br />
          <Button inline icon="plus"
            content="Inject Cryo Coolant"
            onClick={() => act('cryo')}
            disabled={!data.running} />
        </Section>
        <Section title="Fuel Mix">
          {!data.hasMix && (
            <NoticeBox><h2>No Fuel Mix inserted</h2></NoticeBox>
          ) || (
            <Fragment>
              <b>Inserted Fuel Mix</b>
              <br /><br />
              <b>Deuterium</b>
              <ProgressBar
                maxValue={100} value={data.deuteriumFuel} 
                content={Math.round(data.deuteriumFuel) + "%"} />
              <br /><br />
              <b>Tritium</b>
              <ProgressBar
                maxValue={100} value={data.tritiumFuel} 
                content={Math.round(data.tritiumFuel) + "%"} />
              <br /><br />
              <b>Fuel Additives</b>
              {map((value, key) => (
                <Section><b>{value.fuelName}</b>
                </Section>
              ))(data.fuelAdditives)}
              <br /><br />
              <Button inline icon="eject"
                content="Eject Mix"
                onClick={() => act('ejectMix')}
                disabled={!data.status === "STOPPED"} />
            </Fragment>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
