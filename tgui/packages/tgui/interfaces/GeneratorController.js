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
        <Section>
          {map((value, key) => (
            <Section title={value.gName}>
              <Box inline><b>Generator Heat:</b></Box>
              <br />
              <ProgressBar
                color={value.heat >= value.cutoff * 1.5 ? ("good") : value.heat >= value.cutoff ? ("average") : ("bad")}
                maxValue={value.maxHeat} value={value.heat} content={Math.round(value.heat) + "%"} />
              <br /><br />
              <Box inline><b>Generator Condition:</b></Box>
              <br />
              <ProgressBar color={value.condition >= 70 ? ("good") : value.condition >= 40 ?("average") : ("bad")}
                maxValue={100} value={value.condition} content={Math.round(value.condition) + "%"} />
              <br /><br />
              <b>Installed upgrades:</b>
              <br />
              {map((value2, key) => (
                <Fragment>{value2.upNameG}<br /></Fragment>

              ))(value.gUps)}
              <br />
              <b>Last Cycle Output:</b> {value.lastOutput}
              <br /><br />
              <b>Status:</b> {value.status}
              <br /><br />
              <Button inline icon={!value.on && ("play") || ("stop")}
                content={value.status === "SPINNING UP" || value.status === "STARTED"
                  ? ("Stop Generator")
                  : value.status === "STOPPING"
                    ? ("Generator Spinning down..")
                    : ("Spin up Generator")}
                selected={!!value.on && value.status !== "STOPPING"}
                disabled={value.status === "STOPPING"}
                onClick={() => act('toggleOn', { G: value.gen })} />
            </Section>
          ))(data.generator)}
        </Section>
      </Window.Content>
    </Window>
  );
};
