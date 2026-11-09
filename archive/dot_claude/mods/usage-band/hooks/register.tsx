import { atom, read, update } from 'claude-code'
import type { Register } from 'claude-code'

import type { UsageWindow } from '../types'

const windows = atom({ plugin: 'usage-band', key: 'windows' } as const, [] as UsageWindow[])
const contextPercent = atom({ plugin: 'usage-band', key: 'contextPercent' } as const, null as number | null)

// Every label takes three cells so the bars start in one column on the terminal.
const ROWS = [
  { kind: 'five_hour', label: '5h ' },
  { kind: 'seven_day', label: '週 ' },
] as const

const CONTEXT_ROW = { kind: 'context', label: 'ctx' } as const

const BAR_CELLS = 20

// Redraws only follow measurements, so a timer keeps the remaining time current while idle.
const REDRAW_MS = 60_000

// Floor so that 100% and a full bar appear only once the window is actually used up.
const bar = (percent: number): string => {
  const filled = Math.floor((Math.min(percent, 100) / 100) * BAR_CELLS)
  return '█'.repeat(filled) + '░'.repeat(BAR_CELLS - filled)
}

const colorOf = (percent: number) =>
  percent >= 90 ? 'error' : percent >= 70 ? 'warning' : 'success'

const formatRemaining = (minutes: number): string => {
  if (minutes >= 24 * 60) return `リセットまで ${Math.floor(minutes / (24 * 60))}d${Math.floor((minutes % (24 * 60)) / 60)}h`
  if (minutes >= 60) return `リセットまで ${Math.floor(minutes / 60)}h${minutes % 60}m`
  return `リセットまで ${minutes}m`
}

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    const result = await next(e)
    const { rateLimits, context } = await $.session.usage()
    await update($, windows, () => rateLimits)
    await update($, contextPercent, () => context.percent ?? null)
    $.clock.every(REDRAW_MS, () => $.ui.invalidate('ui.render'))
    return result
  })

  on('session.measure', async ($, e, next) => {
    await update($, windows, () => e.rateLimits)
    await update($, contextPercent, () => e.context.percent ?? null)
    return next(e)
  })

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    if (e.props.hasSurvey) return next(e)

    const now = await $.clock.now()
    const current = await read($, windows)
    const rateRows = ROWS.flatMap(row => {
      const found = current.find(w => w.kind === row.kind)
      if (found === undefined) return []
      const resetsAt = found.resetsAt === undefined ? NaN : Date.parse(found.resetsAt)
      // A window past its reset still carries the old figure until the next measurement.
      if (resetsAt <= now) return []
      const remaining = Number.isFinite(resetsAt) ? formatRemaining(Math.round((resetsAt - now) / 60000)) : undefined
      return [{ ...row, percent: Math.max(0, Math.floor(found.percentUsed)), remaining }]
    })
    // The context fill is absent until the first response of a fresh or just compacted window.
    const context = await read($, contextPercent)
    const rows = context === null ? rateRows : [...rateRows, { ...CONTEXT_ROW, percent: context, remaining: undefined }]
    if (rows.length === 0) return next(e)

    const { Box, Text } = $.ui.resolve(e)

    return (
      <Box flexDirection="column">
        {rows.map(({ kind, label, percent, remaining }) => (
          <Text key={kind}>
            <Text dimColor>{label} </Text>
            <Text color={colorOf(percent)}>{bar(percent)}</Text>
            <Text> {String(percent).padStart(3)}%</Text>
            {remaining === undefined ? null : <Text dimColor> {remaining}</Text>}
          </Text>
        ))}
      </Box>
    )
  })
}
