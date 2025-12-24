async function vnodeMounted(e, components, echarts, node_modules, http) {
  const option = components.id_4o4qhbv0v6y000.props.chartConfig.option

  const maxDataPoints = 100
  const dataCache = {}
  const legendData = []

  option.series = [
    {
      name: '默认',
      type: 'line',
      showSymbol: false,
      data: [[new Date().getTime(), 0]],
      dimensions: ['time', 'value'], // 明确维度
      encode: {
        x: 'time',
        y: 'value'
      }
    }
  ]

  // option.title = {
  //     text: '试验数据实时监控',
  //     left: 'center',
  //     textStyle: {
  //       color: '#ffffff'
  //     }
  // };
  option.tooltip = {
    trigger: 'axis',
    axisPointer: {
      type: 'cross', // 十字线，悬停时显示
      snap: true
    },
    alwaysShowContent: true,
    transitionDuration: 0,
    formatter: function (params) {
      if (!params || !params.length) return ''
      let result = params[0].axisValueLabel + ''
      result +=
        '<div style="display:flex;flex-direction:row;align-items:flex-start;justify-content:flex-start;gap:20px;">'
      result += '<div>'
      const row = Math.max(Math.ceil(params.length / 4), 5)
      params.forEach((param, index) => {
        const value = param.value ? param.value[1] : 'N/A'
        result += `${param.seriesName}: ${Number(value).toFixed(2)}`
        if ((index + 1) % row == 0) {
          result += '</div><div>'
        } else {
          result += '<br/>'
        }
      })
      result += '</div></div>'
      window.tooltipInfo1 = {
        seriesIndex: params[0].seriesIndex,
        dataIndex: params[0].dataIndex
      }
      return result
    }
  }
  option.grid = {
    top: 50,
    left: 5,
    right: 10,
    bottom: 10,
    containLabel: true
  }

  const legend = option.legend
  if (legend.x) delete legend.x
  if (legend.y) delete legend.y
  legend.left = 'center'
  legend.padding = [0, 10]
  legend.top = 0
  legend.data = ['默认']
  legend.animation = false

  option.xAxis = {
    type: 'time',
    boundaryGap: false,
    axisLabel: {
      fontSize: 6,
      formatter: function (value) {
        return echarts.format.formatTime('hh:mm:ss', value)
      }
    }
  }
  option.yAxis = [
    {
      type: 'value',
      name: '温度', // 左边 Y 轴
      position: 'left',
      axisLabel: {
        fontSize: 8,
        formatter: '{value}'
      },
      splitLine: {
        show: true,
        lineStyle: {
          color: 'rgba(255,255,255,0.1)', // 颜色加透明度，越小越淡
          width: 1, // 线宽
          type: 'solid' // 实线
        }
      }
    }
    // {
    //   type: 'value',
    //   name: '湿度',   // 右边 Y 轴
    //   position: 'right',
    //   axisLabel: {
    //       formatter: '{value}'
    //   },
    //   splitLine: {
    //     show: true,
    //     lineStyle: {
    //       color: 'rgba(255,255,255,0.1)', // 颜色加透明度，越小越淡
    //       width: 1,                 // 线宽
    //       type: 'dashed'             // 实线
    //     }
    //   }
    // }
  ]

  // components.id_4o4qhbv0v6y000.props.chartConfig.option = baseOption
}
