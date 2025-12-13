{
  // Base colors
  base:: {
    green: 'green',
    yellow: 'yellow',
    red: 'red',
    blue: 'blue',
    orange: 'orange',
    purple: 'purple',
    transparent: 'transparent',
  },

  // Specific color values (hex)
  hex:: {
    green: '#73BF69',
    lightGreen: '#96D98D',
    darkGreen: '#56A64B',
    yellow: '#FADE2A',
    lightYellow: '#FFEE52',
    orange: '#FF9830',
    red: '#F2495C',
    lightRed: '#FF7383',
    darkRed: '#E02F44',
    blue: '#5794F2',
    lightBlue: '#8AB8FF',
    darkBlue: '#3274D9',
    purple: '#B877D9',
    lightPurple: '#CA95E5',
    darkPurple: '#A352CC',
  },

  // Severity colors
  severity:: {
    success: 'green',
    info: 'blue',
    warning: 'yellow',
    'error': 'red',
    critical: 'dark-red',
  },

  // Log level colors
  logLevel:: {
    debug: 'blue',
    info: 'green',
    warn: 'yellow',
    'error': 'red',
    fatal: 'dark-red',
  },

  // Currency-specific colors
  currency:: {
    buy: 'green',
    sell: 'red',
  },

  // API/Direction colors
  api:: {
    incoming: 'blue',
    outgoing: 'purple',
    success: 'green',
    'error': 'red',
  },

  // System resource colors
  system:: {
    cpu: 'blue',
    memory: 'green',
    disk: 'purple',
    network: 'orange',
  },

  // Fixed color configuration for field overrides
  fixedColor:: function(color) {
    mode: 'fixed',
    fixedColor: color,
  },

  // Threshold-based color configuration
  thresholdColor:: {
    mode: 'thresholds',
  },

  // Palette-based color configuration
  paletteColor:: function(scheme='Classic') {
    mode: 'palette-classic',
  },

  // Create override for field by name
  fieldOverride:: function(fieldName, color) {
    matcher: { id: 'byName', options: fieldName },
    properties: [
      { id: 'color', value: $.fixedColor(color) },
    ],
  },

  // Create multiple overrides for currency pairs (buy/sell)
  currencyOverrides:: [
    $.fieldOverride('Buy Rate', $.hex.green),
    $.fieldOverride('Buy', $.hex.green),
    $.fieldOverride('Sell Rate', $.hex.red),
    $.fieldOverride('Sell', $.hex.red),
  ],

  // Create overrides for log levels
  logLevelOverrides:: [
    $.fieldOverride('DEBUG', $.hex.blue),
    $.fieldOverride('INFO', $.hex.green),
    $.fieldOverride('WARN', $.hex.yellow),
    $.fieldOverride('ERROR', $.hex.red),
    $.fieldOverride('FATAL', $.hex.darkRed),
  ],

  // Create overrides for API directions
  apiDirectionOverrides:: [
    $.fieldOverride('incoming', $.hex.blue),
    $.fieldOverride('Incoming', $.hex.blue),
    $.fieldOverride('outgoing', $.hex.purple),
    $.fieldOverride('Outgoing', $.hex.purple),
  ],
}
