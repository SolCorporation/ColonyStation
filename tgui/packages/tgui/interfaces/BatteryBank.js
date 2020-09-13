import { useBackend } from '../backend';
import { Fragment, Box, Button, Flex, LabeledList, ProgressBar, Section, Slider } from '../components';
import { formatPower } from '../format';
import { Window } from '../layouts';
import { LabeledListItem } from '../components/LabeledList';

// Common power multiplier
const POWER_MUL = 1e3;

export const BatteryBank = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    capacityPercent,
    capacity,
    charge,
    input,
    inputting,
    inputLevel,
    inputLevelMax,
    inputAvailable,
    output,
    outputting,
    outputLevel,
    outputLevelMax,
    output_used,
    cells_left,
    cells_right,
    average_condition,
    balanced_charging,
    balanced_charging_possible,
  } = data;
  const inputState = (
    capacityPercent >= 100 && 'good'
    || inputting && 'average'
    || 'bad'
  );
  const outputState = (
    outputting && 'good'
    || charge > 0 && 'average'
    || 'bad'
  );
  return (
    <Window resizable>
      <Window.Content resizable>
        <Flex>
          <Flex.Item>
            <Section title="Left Extension" width="20rem" buttons={
              <Button icon="eject"
                disabled={!cells_left[0]}
                onClick={() => act('remove_cell', {
                  side: "left",
                })} >
                Eject
              </Button>
            }>
              <Flex direction="column" grow={1}>
                <Cell cell_number={1} cell={cells_left[0]} />
                <Cell cell_number={2} cell={cells_left[1]} />
                <Cell cell_number={3} cell={cells_left[2]} />
                <Cell cell_number={4} cell={cells_left[3]} />
              </Flex>
            </Section>
          </Flex.Item>
          <Flex.Item ml={1} mr={1}>
            <Section title="Stored Energy">
              <ProgressBar
                value={capacityPercent * 0.01}
                ranges={{
                  good: [0.5, Infinity],
                  average: [0.15, 0.5],
                  bad: [-Infinity, 0.15],
                }} />
            </Section>
            <Section title="Average Condition">
              <ProgressBar
                value={average_condition}
                ranges={{
                  good: [0.5, Infinity],
                  average: [0.15, 0.5],
                  bad: [-Infinity, 0.15],
                }} />
            </Section>
            <Section title="Input" buttons={
              <Button icon="wrench"
                onClick={() => act('toggle_balanced_charging')}
                disabled={!balanced_charging_possible}
                selected={balanced_charging}>
                Balanced Charging/Discharging
              </Button>
            }>
              <LabeledList>
                <LabeledList.Item
                  label="Charge Mode"
                  buttons={
                    <Button
                      icon={input ? 'sync-alt' : 'times'}
                      selected={input}
                      onClick={() => act('tryinput')}>
                      {input ? 'Auto' : 'Off'}
                    </Button>
                  }>
                  <Box color={inputState}>
                    {capacityPercent >= 100 && 'Fully Charged'
                      || inputting && 'Charging'
                      || 'Not Charging'}
                  </Box>
                </LabeledList.Item>
                <LabeledList.Item label="Target Input">
                  <Flex inline width="100%">
                    <Flex.Item>
                      <Button
                        icon="fast-backward"
                        disabled={inputLevel === 0}
                        onClick={() => act('input', {
                          target: 'min',
                        })} />
                      <Button
                        icon="backward"
                        disabled={inputLevel === 0}
                        onClick={() => act('input', {
                          adjust: -10000,
                        })} />
                    </Flex.Item>
                    <Flex.Item grow={1} mx={1}>
                      <Slider
                        value={inputLevel / POWER_MUL}
                        fillValue={inputAvailable / POWER_MUL}
                        minValue={0}
                        maxValue={inputLevelMax / POWER_MUL}
                        step={5}
                        stepPixelSize={4}
                        format={value => formatPower(value * POWER_MUL, 1)}
                        onDrag={(e, value) => act('input', {
                          target: value * POWER_MUL,
                        })} />
                    </Flex.Item>
                    <Flex.Item>
                      <Button
                        icon="forward"
                        disabled={inputLevel === inputLevelMax}
                        onClick={() => act('input', {
                          adjust: 10000,
                        })} />
                      <Button
                        icon="fast-forward"
                        disabled={inputLevel === inputLevelMax}
                        onClick={() => act('input', {
                          target: 'max',
                        })} />
                    </Flex.Item>
                  </Flex>
                </LabeledList.Item>
                <LabeledList.Item label="Available">
                  {formatPower(inputAvailable)}
                </LabeledList.Item>
              </LabeledList>
            </Section>
            <Section title="Output">
              <LabeledList>
                <LabeledList.Item
                  label="Output Mode"
                  buttons={
                    <Button
                      icon={output ? 'power-off' : 'times'}
                      selected={output}
                      onClick={() => act('tryoutput')}>
                      {output ? 'On' : 'Off'}
                    </Button>
                  }>
                  <Box color={outputState}>
                    {outputting
                      ? 'Sending'
                      : charge > 0
                        ? 'Not Sending'
                        : 'No Charge'}
                  </Box>
                </LabeledList.Item>
                <LabeledList.Item label="Target Output">
                  <Flex inline width="100%">
                    <Flex.Item>
                      <Button
                        icon="fast-backward"
                        disabled={outputLevel === 0}
                        onClick={() => act('output', {
                          target: 'min',
                        })} />
                      <Button
                        icon="backward"
                        disabled={outputLevel === 0}
                        onClick={() => act('output', {
                          adjust: -10000,
                        })} />
                    </Flex.Item>
                    <Flex.Item grow={1} mx={1}>
                      <Slider
                        value={outputLevel / POWER_MUL}
                        minValue={0}
                        maxValue={outputLevelMax / POWER_MUL}
                        step={5}
                        stepPixelSize={4}
                        format={value => formatPower(value * POWER_MUL, 1)}
                        onDrag={(e, value) => act('output', {
                          target: value * POWER_MUL,
                        })} />
                    </Flex.Item>
                    <Flex.Item>
                      <Button
                        icon="forward"
                        disabled={outputLevel === outputLevelMax}
                        onClick={() => act('output', {
                          adjust: 10000,
                        })} />
                      <Button
                        icon="fast-forward"
                        disabled={outputLevel === outputLevelMax}
                        onClick={() => act('output', {
                          target: 'max',
                        })} />
                    </Flex.Item>
                  </Flex>
                </LabeledList.Item>
                <LabeledList.Item label="Outputting">
                  {formatPower(output_used)}
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Flex.Item>
          <Flex.Item>
            <Section title="Right Extension" width="20rem" buttons={
              <Button icon="eject"
                disabled={!cells_right[0]}
                onClick={() => act('remove_cell', {
                  side: "right",
                })} >
                Eject
              </Button>
            }>
              <Flex direction="column" grow={1}>
                <Cell cell_number={5} cell={cells_right[0]} />
                <Cell cell_number={6} cell={cells_right[1]} />
                <Cell cell_number={7} cell={cells_right[2]} />
                <Cell cell_number={8} cell={cells_right[3]} />
              </Flex>
            </Section>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

const Cell = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    cell_number,
    cell,
  } = props;
  return (
    <Section title={"Cell " + cell_number}>
      <LabeledList>
        <LabeledList.Item label="Charge">
          {cell && (
            <ProgressBar value={cell.percent / 100} ranges={{
              good: [0.5, Infinity],
              average: [0.15, 0.5],
              bad: [-Infinity, 0.15],
            }} />
          ) || (
            <Fragment>Bay Empty</Fragment>
          )}
        </LabeledList.Item>
        <LabeledList.Item label="Condition">
          {cell && (
            <ProgressBar value={cell.condition / 100} ranges={{
              good: [0.7, Infinity],
              average: [0.4, 0.7],
              bad: [-Infinity, 0.4],
            }} />
          ) || (
            <Fragment>Bay Empty</Fragment>
          )}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
