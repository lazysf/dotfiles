import { expect, mock, test } from 'claude-code/testing'
import type { On, SessionRateLimit } from 'claude-code'

const NOW = Date.parse('2026-10-16T12:00:00Z')

const BAND = {
  plugin: 'usage-band',
  component: 'AbovePrompt',
  props: {
    hasSurvey: false,
    isWorking: false,
    maxRows: 10,
    bodyColumns: 80,
    scroll: { offset: 0, bodyRows: 10 },
    view: {},
  },
} as const

const FIVE_HOUR = { kind: 'five_hour', percentUsed: 58, resetsAt: '2026-10-16T14:10:00Z' }
const SEVEN_DAY = { kind: 'seven_day', percentUsed: 92.5, resetsAt: '2026-10-19T15:00:00Z' }

// Stands in for the engine beneath the plugin: answers the session events and
// draws a marker band when the plugin passes the render through.
const engine = (on: On, rateLimits: SessionRateLimit[] = []) => {
  on('session.start', ($, e) => ({ cwd: e.cwd }))
  on('session.usage', () => ({ value: { startedAt: NOW, context: { window: 200000 }, rateLimits } }))
  on('session.measure', ($, e) => ({ changed: e.changed }))
  on('ui.render', ($, e) => {
    const { Text } = $.ui.resolve(e)
    return h(Text, { key: 'engine' }, 'engine')
  })
}

const measure = (rateLimits: SessionRateLimit[]) => ({
  context: { window: 200000 },
  rateLimits,
  changed: ['rateLimits'] as const,
})

test('draws a bar for each window on every surface', async ($, on) => {
  engine(on)
  mock.clock(on, { now: NOW })
  await $.session.measure(measure([FIVE_HOUR, SEVEN_DAY]))

  for (const surface of ['terminal', 'desktop'] as const) {
    const ui = await $.ui.mount({ ...BAND, surface })
    expect(await ui.find({ type: 'Text', text: /^5h  █{11}░{9}\s+58% リセットまで 2h10m$/ })).toBeDefined()
    expect(await ui.find({ type: 'Text', text: /^週  █{18}░{2}\s+92% リセットまで 3d3h$/ })).toBeDefined()
    await ui.unmount()
  }
})

test('text, color and bar agree at the thresholds', async ($, on) => {
  engine(on)
  mock.clock(on, { now: NOW })
  await $.session.measure(measure([
    { ...FIVE_HOUR, percentUsed: 89.9 },
    { ...SEVEN_DAY, percentUsed: 99.9 },
  ]))

  const ui = await $.ui.mount({ ...BAND, surface: 'terminal' })
  expect((await ui.find({ type: 'Text', text: /^█+░+$/ }))?.props.color).toBe('warning')
  expect(await ui.find({ type: 'Text', text: /^5h .*\s89%/ })).toBeDefined()
  expect(await ui.find({ type: 'Text', text: /^週  █{19}░\s+99%/ })).toBeDefined()
  expect((await ui.findAll({ type: 'Text', text: /^█+░+$/ }))[1]?.props.color).toBe('error')
  await ui.unmount()
})

test('drops windows past their reset, without a reset time and of other kinds', async ($, on) => {
  engine(on)
  mock.clock(on, { now: NOW })
  await $.session.measure(measure([
    { ...FIVE_HOUR, resetsAt: '2026-10-16T11:59:00Z' },
    { kind: 'seven_day', percentUsed: 10 },
    { kind: 'spend_limit', percentUsed: 120 },
  ]))

  const ui = await $.ui.mount({ ...BAND, surface: 'terminal' })
  expect(await ui.find({ type: 'Text', text: /^5h / })).toBeUndefined()
  expect(await ui.find({ type: 'Text', text: /^週  █{2}░{18}\s+10%$/ })).toBeDefined()
  expect(await ui.find({ text: /120/ })).toBeUndefined()
  await ui.unmount()
})

test('adds the context fill as a third row once a response reported it', async ($, on) => {
  engine(on)
  mock.clock(on, { now: NOW })
  await $.session.measure(measure([FIVE_HOUR]))

  const ui = await $.ui.mount({ ...BAND, surface: 'terminal' })
  expect(await ui.find({ text: /^ctx/ })).toBeUndefined()

  await $.session.measure({ ...measure([FIVE_HOUR]), context: { window: 200000, tokens: 150000, percent: 75 } })
  expect((await ui.findAll({ type: 'Text', text: /^(5h|ctx) .*%/ })).map(row => row.text)).toEqual([
    '5h  ███████████░░░░░░░░░  58% リセットまで 2h10m',
    'ctx ███████████████░░░░░  75%',
  ])
  expect((await ui.findAll({ type: 'Text', text: /^█+░+$/ }))[1]?.props.color).toBe('warning')
  await ui.unmount()
})

test('keeps the remaining time current while idle', async ($, on) => {
  engine(on, [FIVE_HOUR])
  const clock = mock.clock(on, { now: NOW })
  await $.session.start({ cwd: '/', surface: 'terminal', isInteractive: true })

  const ui = await $.ui.mount({ ...BAND, surface: 'terminal' })
  expect(await ui.find({ type: 'Text', text: /リセットまで 2h10m$/ })).toBeDefined()
  await clock.advance(60_000)
  expect(await ui.find({ type: 'Text', text: /リセットまで 2h9m$/ })).toBeDefined()
  await ui.unmount()
})

test('leaves the band to the engine before any reading and under a survey', async ($, on) => {
  engine(on)
  mock.clock(on, { now: NOW })
  const ui = await $.ui.mount({ ...BAND, surface: 'terminal' })
  expect(await ui.find({ text: /リセットまで/ })).toBeUndefined()
  expect(await ui.find({ text: 'engine' })).toBeDefined()

  await $.session.measure(measure([FIVE_HOUR]))
  await ui.redraw({ ...BAND.props, hasSurvey: true })
  expect(await ui.find({ text: /リセットまで/ })).toBeUndefined()
  expect(await ui.find({ text: 'engine' })).toBeDefined()
  await ui.unmount()
})
