local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

{
  // Grid constants
  gridWidth:: 24,
  defaultHeight:: 8,

  // Basic grid position helper
  gridPos:: function(x, y, w, h) {
    gridPos: {
      x: x,
      y: y,
      w: w,
      h: h,
    },
  },

  // Size presets
  sizes:: {
    fullWidth: 24,
    halfWidth: 12,
    thirdWidth: 8,
    quarterWidth: 6,
    twoThirds: 16,
    threeQuarters: 18,
  },

  // Height presets
  heights:: {
    small: 6,
    medium: 8,
    large: 10,
    xlarge: 12,
    xxlarge: 15,
    huge: 20,
  },

  // Set panel size
  setSize:: function(panel, width, height)
    panel
    + { gridPos+: { w: width, h: height } },

  // Width helpers
  fullWidth:: function(panel, height=$.defaultHeight)
    $.setSize(panel, $.sizes.fullWidth, height),

  halfWidth:: function(panel, height=$.defaultHeight)
    $.setSize(panel, $.sizes.halfWidth, height),

  thirdWidth:: function(panel, height=$.defaultHeight)
    $.setSize(panel, $.sizes.thirdWidth, height),

  quarterWidth:: function(panel, height=$.defaultHeight)
    $.setSize(panel, $.sizes.quarterWidth, height),

  twoThirds:: function(panel, height=$.defaultHeight)
    $.setSize(panel, $.sizes.twoThirds, height),

  threeQuarters:: function(panel, height=$.defaultHeight)
    $.setSize(panel, $.sizes.threeQuarters, height),

  // Custom size
  customSize:: function(panel, width, height=$.defaultHeight)
    $.setSize(panel, width, height),

  // Row creator (visual grouping)
  row:: function(title, collapsed=false)
    g.panel.row.new(title)
    + g.panel.row.withCollapsed(collapsed),

  // Grid layout generators

  // Simple grid with auto-flow (wraps at 24 width)
  grid:: function(panels, panelWidth=12, panelHeight=8, startY=0)
    g.util.grid.makeGrid(panels, panelWidth, panelHeight, startY),

  // Layout panels in a single row
  rowLayout:: function(panels, height=$.defaultHeight)
    local widthPerPanel = $.gridWidth / std.length(panels);
    [
      $.setSize(panels[i], widthPerPanel, height)
      for i in std.range(0, std.length(panels) - 1)
    ],

  // Layout panels in columns
  columnLayout:: function(panels, width=$.sizes.fullWidth, height=$.defaultHeight)
    [
      $.setSize(panels[i], width, height)
      for i in std.range(0, std.length(panels) - 1)
    ],

  // Two column layout (50/50 split)
  twoColumns:: function(leftPanels, rightPanels, height=$.defaultHeight)
    local left = [
      $.halfWidth(leftPanels[i], height)
      for i in std.range(0, std.length(leftPanels) - 1)
    ];
    local right = [
      $.halfWidth(rightPanels[i], height)
      for i in std.range(0, std.length(rightPanels) - 1)
    ];
    left + right,

  // Three column layout (33/33/33 split)
  threeColumns:: function(col1, col2, col3, height=$.defaultHeight)
    local c1 = [$.thirdWidth(col1[i], height) for i in std.range(0, std.length(col1) - 1)];
    local c2 = [$.thirdWidth(col2[i], height) for i in std.range(0, std.length(col2) - 1)];
    local c3 = [$.thirdWidth(col3[i], height) for i in std.range(0, std.length(col3) - 1)];
    c1 + c2 + c3,

  // Four column layout (25/25/25/25 split)
  fourColumns:: function(col1, col2, col3, col4, height=$.defaultHeight)
    local c1 = [$.quarterWidth(col1[i], height) for i in std.range(0, std.length(col1) - 1)];
    local c2 = [$.quarterWidth(col2[i], height) for i in std.range(0, std.length(col2) - 1)];
    local c3 = [$.quarterWidth(col3[i], height) for i in std.range(0, std.length(col3) - 1)];
    local c4 = [$.quarterWidth(col4[i], height) for i in std.range(0, std.length(col4) - 1)];
    c1 + c2 + c3 + c4,

  // Sidebar layout (25% sidebar, 75% main)
  sidebarLayout:: function(sidebarPanels, mainPanels, height=$.defaultHeight)
    local sidebar = [
      $.quarterWidth(sidebarPanels[i], height)
      for i in std.range(0, std.length(sidebarPanels) - 1)
    ];
    local main = [
      $.threeQuarters(mainPanels[i], height)
      for i in std.range(0, std.length(mainPanels) - 1)
    ];
    sidebar + main,
}
