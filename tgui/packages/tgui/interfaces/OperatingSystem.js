/* eslint-disable */
import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { map } from 'common/collections';
import { Button, ColorBox, Section, Table, NoticeBox } from '../components';
import { Window } from '../layouts';


export const OperatingSystem = (props, context) => {
  const { act, data } = useBackend(context);
  let available_programs_filtered = [];

  // Dirty filtering. Done to avoid spamming the UI with all the available programs all the time
  for (let i = 0; i < data.available_programs.length; i++) {
    let pass = true
    for (let i2 = 0; i2 < data.installed_programs_text.length; i2++) {
      if (data.available_programs[i].name === data.installed_programs_text[i2]) {
        pass = false
        break
      }
    }
    if(pass) {
      available_programs_filtered.push(data.available_programs[i]);
    }
  }

  for (let i = 0; i < data.emagged_programs.length; i++) {

    let pass = true
    if(!data.emagged) pass = false
    for (let i2 = 0; i2 < data.installed_programs_text.length; i2++) {
      if (data.emagged_programs[i].name === data.installed_programs_text[i2]) {
        pass = false
        break
      }
    }
    if(pass) {
      available_programs_filtered.push(data.emagged_programs[i]);
    }
  }


  return (
    <Window theme={'ntos'}>
    <Window.Content scrollable>
      <Section title="Dashboard">
        {!!data.emagged && (
          <NoticeBox>Malicious Foreign Code Detected</NoticeBox>
        )}
        <Table>
          <Table.Row>
            <Table.Cell>
              <Fragment><b>Current Charge: </b>{Math.round((data.charge + Number.EPSILON) * 100) / 100}/{data.max_charge}</Fragment>
            </Table.Cell>
            <Table.Cell>
              <Fragment><b>Power Usage :</b> {data.power_usage} per cycle</Fragment>
            </Table.Cell>
            <Table.Cell>
              <Fragment><b>Harm Prevention:</b> {!data.can_use_guns && ("Active") || (<b>DISABLED</b>)}</Fragment>
            </Table.Cell>
          </Table.Row>
          <Table.Row>
            <Table.Cell>
              <br />
              <Fragment><b>Free CPU Power:</b> {data.free_cpu}/{data.total_cpu} gFLOPS</Fragment>
            </Table.Cell>
            <Table.Cell>
              <br />
              <Fragment><b>Internal CPU Power:</b> {data.local_cpu} gFLOPS</Fragment>
            </Table.Cell>
            <Table.Cell>
              <br />
              <Fragment><b>External CPU Power:</b> {data.external_cpu} gFLOPS</Fragment>
            </Table.Cell>
          </Table.Row>
          <Table.Row>
            <Table.Cell>

              <Fragment><b>Free RAM:</b> {data.free_ram}/{data.total_ram} TB</Fragment>
            </Table.Cell>
            <Table.Cell>

              <Fragment><b>Internal RAM:</b> {data.local_ram} TB</Fragment>
            </Table.Cell>
            <Table.Cell>

              <Fragment><b>External RAM Power:</b> {data.external_ram} TB</Fragment>
            </Table.Cell>
          </Table.Row>
          <Table.Row>
            <Table.Cell>
              <br />
            </Table.Cell>
            <Table.Cell>
              <br />
              <Fragment><b>Signal Strength:</b> NO SIGNAL</Fragment>
            </Table.Cell>
            <Table.Cell>
              <br />
            </Table.Cell>
          </Table.Row>
        </Table>
      </Section>
      <Section title="Installed Programs">
        {data.installed_programs.length === 0 && (
          <NoticeBox>No Programs Installed</NoticeBox>
        )}
        {map((value, key) => (
          <Section>
            <Table>
              <Table.Row>
                <Table.Cell>
                  <Fragment><h3>{value.name}</h3>
                    {value.desc}
                  </Fragment>
                </Table.Cell>
                <Table.Cell collapsing width={3}>
                  {!value.requires_button && (
                    <Fragment>
                      {!!value.active && (
                        <Button width={25} icon="stop" content="Stop" onClick={
                          () => act('stop', { name: value.name })
                        } />
                      ) || (
                        <Button width={25} icon="play" content="Run" onClick={
                          () => act('run', { name: value.name })
                        } />
                      )}
                    </Fragment>
                  )}
                  {!!data.can_uninstall && !value.active && (
                    <Button width={15} icon="trash" content="Uninstall" onClick={
                      () => act('uninstall', { name: value.name })
                    } />
                  )}
                  <br />
                  <b>RAM Usage:</b> {value.ram_cost} TB
                  <br />
                  <b>CPU Usage:</b> {value.cpu_cost} gFLOPS
                </Table.Cell>
              </Table.Row>
            </Table>
          </Section>
        ))(data.installed_programs)}
      </Section>
      <Section title="Available Programs">
        {available_programs_filtered.length === 0 && (
          <NoticeBox>No Available Programs</NoticeBox>
        )}
        {map((value, key) => (
          <Section>
            <Table>
              <Table.Row>
                <Table.Cell>
                  <Fragment><h3>{value.name}</h3>
                    {value.desc}
                  </Fragment>
                </Table.Cell>
                <Table.Cell collapsing width={3}>
                  <Button width={25} icon="cog" content="Install" onClick={
                    () => act('install', { name: value.name })
                  } />
                  <br />
                  <b>RAM Usage:</b> {value.ram_cost} TB
                  <br />
                  <b>CPU Usage:</b> {value.cpu_cost} gFLOPS
                </Table.Cell>
              </Table.Row>
            </Table>
          </Section>
        ))(available_programs_filtered)}
      </Section>
    </Window.Content>
    </Window>
  );
};
