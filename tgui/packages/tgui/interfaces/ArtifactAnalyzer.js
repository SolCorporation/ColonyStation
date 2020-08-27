import { Fragment } from 'inferno';
import { map } from 'common/collections';
import { useBackend } from '../backend';
import { Button, ProgressBar, Section, Box, Grid } from '../components';
import { Window } from '../layouts';

export const ArtifactAnalyzer = (props, context) => {
  const { act, data } = useBackend(context);

  return (
    <Window>
      <Window.Content>
        <Section title="Artifact Analyzer">
          {!!data.art && (
            <Fragment>
              <Fragment><b>Status: </b>{data.status}<br /><br /></Fragment>

              {!!data.running && (
                <Fragment>Analyzer Progress<br />
                  <ProgressBar maxValue={data.max} 
                    value={data.ticksRemaining} content={data.timeRemaining + " second(s)"} />
                  <br /><br />
                  <Button icon="stop" disabled={!data.running}
                    content="Abort" onClick={() => act('abort')} />
                </Fragment>

              ) || (
                <Button icon="play" disabled={data.running}
                  content="Start Examination" onClick={() => act('begin')} />
              )}
              <br /><br />
              <Button icon="eject" disabled={data.running}
                content="Eject Artifact" onClick={() => act('eject')} />
            </Fragment>
          ) || (
            <h2>No Artifact Inserted</h2>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
