import { defineConfig } from 'vitepress'

export default defineConfig({
  title: "Telem",
  description: "Trivial Extract and Load Engine for Minecraft",
  base: '/telem/',
  cleanUrls: true,
  ignoreDeadLinks: 'localhostLinks',
  markdown: {
    image: {
      lazyLoading: true
    }
  },
  themeConfig: {
    nav: [
      { text: 'Home', link: '/' },
      { text: 'Changelog', link: 'https://github.com/bakaneko152/telem/releases' }
    ],
    
    sidebar: [
      {
        text: 'Getting Started',
        link: '/getting-started'
      },
      {
        text: 'API',
        collapsed: true,
        items: [
          { text: 'Metric', link: '/reference/Metric' },
          { text: 'MetricCollection', link: '/reference/MetricCollection' },
          { text: 'InputAdapter', link: '/reference/InputAdapter' },
          { text: 'OutputAdapter', link: '/reference/OutputAdapter' },
          { text: 'Backplane', link: '/reference/Backplane' },
          { text: 'Middleware', link: '/reference/Middleware' },
        ]
      },
      {
        text: 'Input',
        collapsed: false,
        items: [
          { text: 'Hello World', link: '/reference/input/HelloWorld' },
          { text: 'Item Storage', link: '/reference/input/ItemStorage' },
          { text: 'Item Storage Drawers', link: '/reference/input/ItemStorageDrawers' },
          { text: 'Item Storage Transposer', link: '/reference/input/itemStorageTransposer' },
          { text: 'Fluid Storage Transposer', link: '/reference/input/fluidStorageTransposer' },
          { text: 'Modem', link: '/reference/input/Modem' },
          { text: 'Custom', link: '/reference/input/Custom' },
          {
            text: 'Applied Energistics',
            collapsed: true,
            items: [
              { text: 'ME Storage', link: '/reference/input/applied-energistics/MEStorage' },
            ]
          },
          {
            text: 'Greg5',
            collapsed: true,
            items: [
              { text: 'Battery Buffer', link: '/reference/input/greg/BatteryBuffer' },
            ]
          },
          {
            text: 'Mekanism',
            collapsed: true,
            items: [
              { text: 'Fission Reactor', link: '/reference/input/mekanism/FissionReactor' },
              { text: 'Fusion Reactor', link: '/reference/input/mekanism/FusionReactor' },
              { text: 'Induction Matrix', link: '/reference/input/mekanism/InductionMatrix' },
              { text: 'Industrial Turbine', link: '/reference/input/mekanism/IndustrialTurbine' },
            ]
          },
          {
            text: 'Refined Storage',
            collapsed: true,
            items: [
              { text: 'Refined Storage', link: '/reference/input/refined-storage/RefinedStorage' },
            ]
          }
        ]
      },
      {
        text: 'Output',
        collapsed: false,
        items: [
          { text: 'Hello World', link: '/reference/output/HelloWorld' },
          { text: 'Line Chart', link: '/reference/output/ChartLine' },
          { text: 'Area Chart', link: '/reference/output/ChartArea' },
          { text: 'Modem', link: '/reference/output/Modem' },
          { text: 'Custom', link: '/reference/output/Custom' },
          { text: 'Grafana', link: '/reference/output/Grafana' },
          {
            text: 'Basalt',
            collapsed: true,
            items: [
              { text: 'Label', link: '/reference/output/basalt/Label' },
              { text: 'Graph', link: '/reference/output/basalt/Graph' },
            ]
          }
        ]
      },
      {
        text: 'Middleware',
        collapsed: false,
        items: [
          { text: 'Sort', link: '/reference/middleware/Sort' },
          { text: 'Calculate Average', link: '/reference/middleware/CalcAverage' },
          { text: 'Calculate Delta', link: '/reference/middleware/CalcDelta' },
          { text: 'Custom', link: '/reference/middleware/Custom' },
        ]
      }
    ],
    
    socialLinks: [
      { icon: 'github', link: 'https://github.com/bakaneko152/telem' }
    ],
    
    externalLinkIcon: true,
  }
})
