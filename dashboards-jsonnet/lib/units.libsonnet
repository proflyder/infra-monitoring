{
  // Time units
  time:: {
    nanoseconds: 'ns',
    microseconds: 'µs',
    milliseconds: 'ms',
    seconds: 's',
    minutes: 'm',
    hours: 'h',
    days: 'd',
  },

  // Data units
  data:: {
    bytes: 'bytes',
    kilobytes: 'kbytes',
    megabytes: 'mbytes',
    gigabytes: 'gbytes',
    terabytes: 'tbytes',
    decimalBytes: 'decbytes',
    decimalKilobytes: 'deckbytes',
    decimalMegabytes: 'decmbytes',
    decimalGigabytes: 'decgbytes',
    decimalTerabytes: 'dectbytes',
  },

  // Data rate units
  dataRate:: {
    bytesPerSec: 'Bps',
    kilobytesPerSec: 'KBs',
    megabytesPerSec: 'MBs',
    gigabytesPerSec: 'GBs',
    bitsPerSec: 'bps',
    kilobitsPerSec: 'Kbps',
    megabitsPerSec: 'Mbps',
    gigabitsPerSec: 'Gbps',
  },

  // Percentage units
  percentage:: {
    percent: 'percent',
    percentUnit: 'percentunit',
  },

  // Numeric units
  numeric:: {
    none: 'none',
    short: 'short',
    number: 'none',
    requests: 'short',
    ops: 'ops',
    reqPerSec: 'reqps',
    opsPerSec: 'ops',
    writesPerSec: 'wps',
    readsPerSec: 'rps',
  },

  // Currency units
  currency:: {
    usd: 'currencyUSD',
    eur: 'currencyEUR',
    gbp: 'currencyGBP',
    jpy: 'currencyJPY',
    rub: 'currencyRUB',
    short: 'short',
  },

  // Misc units
  misc:: {
    humidity: 'humidity',
    pressure: 'pressurembar',
    temperature: 'celsius',
  },

  // Helper to get unit config with min/max
  withMinMax:: function(unit, min=null, max=null) {
    unit: unit,
    min: min,
    max: max,
  },

  // Common unit configurations
  configs:: {
    // Percentage (0-100)
    percent: $.withMinMax($.percentage.percent, 0, 100),
    // Percentage unit (0-1)
    percentUnit: $.withMinMax($.percentage.percentUnit, 0, 1),
    // Duration in milliseconds
    durationMs: $.withMinMax($.time.milliseconds, 0, null),
    // Duration in seconds
    durationS: $.withMinMax($.time.seconds, 0, null),
    // Bytes
    bytes: $.withMinMax($.data.bytes, 0, null),
    // Short numbers (requests, counts)
    short: $.withMinMax($.numeric.short, 0, null),
    // Operations per second
    ops: $.withMinMax($.numeric.opsPerSec, 0, null),
  },
}
