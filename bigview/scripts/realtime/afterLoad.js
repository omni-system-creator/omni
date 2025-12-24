async function vnodeMounted(e, components, echarts, node_modules, http) {
  // 根据当前页面协议决定使用 ws 或 wss
  const wsProtocol = window.location.protocol === 'https:' ? 'wss://' : 'ws://'

  // WebSocket 服务器地址（替换成你的实际地址，不带协议部分）
  const wsHost = window.location.host // 这是一个公共测试服务器

  // 完整的 WebSocket URL
  const wsUrl = wsProtocol + wsHost + '/prod-api/realtime/ws'

  // 创建 WebSocket 连接
  const socket = new WebSocket(wsUrl)

  // 连接成功时
  socket.addEventListener('open', event => {
    console.log('WebSocket 连接已建立')

    // 准备要发送的 JSON 数据
    const messageData = {
      bootstrapServers: '10.220.180.210:9092',
      topic: 'test',
      groupId: 'devtest-' + new Date().getTime(),
    }

    // 将对象转换为 JSON 字符串
    const jsonString = JSON.stringify(messageData)

    // 发送 JSON 数据
    socket.send(jsonString)
    console.log('已发送消息:', jsonString)
  })

  let chart = null
  const chartConfig = components.id_4o4qhbv0v6y000.props.chartConfig
  const option = components.id_4o4qhbv0v6y000.props.chartConfig.option
  const legend = option.legend
  let seriesConfig = []
  let legendData = []
  const maxDataPoints = 1200
  let dataCache = {}
//   let once = false
//   document.addEventListener('click', () => {
//     if (window.tooltipInfo1) {
//       window.tooltipInfo1 = undefined
//     }
//   })
  let enters = []
  window.addEventListener('message', e => {
    if (e.data.type == 'enterChannel') {
      if (!enters.includes(e.data.data)) {
        enters.push(e.data.data)
      }
    }
    if (e.data.type == 'leaveChannel') {
      if (enters.includes(e.data.data)) {
        enters = enters.filter(o => o != e.data.data)
      }
    }
  })
  // 接收到消息时
  socket.addEventListener('message', event => {
    // 如果消息是 JSON 格式，可以解析它
    try {
      if (!this.refs.vChartRef) return
      // 获取echart实例
      chart = this.refs.vChartRef.chart
      const chartOption = chart.getOption()
      // 获取当前 legend 选中状态
      let legendSelectedMap = chartOption.legend[0].selected
      let legendScrollDataIndex = chartOption.legend[0].scrollDataIndex

    //   if (!once) {
    //     console.log(chartOption, 'chartOption....')
    //     chart.on('showTip', function (params) {
    //       if (window.tooltipInfo1) {
    //         window.tooltipInfo1 = {
    //           ...window.tooltipInfo1,
    //           x: params.x,
    //           y: params.y
    //         }
    //       }
    //     })
    //   }

      const onReceiveData = (jsonData) => {
        const timestamp = new Date(jsonData.time || Date.now()).getTime()
        let minTime = timestamp
        let maxTime = timestamp
        const xAxis = { ...option.xAxis }
        const yAxis = { ...option.yAxis }
        // 处理每个通道
        Object.entries(jsonData.datas).forEach(([channel, value]) => {
          const yAxisIndex = parseInt(channel.slice(-3), 10) > 44 ? 1 : 0
          if (yAxisIndex > 0) return
          // 初始化数据缓存
          if (!dataCache[channel]) {
            const tempData = []
            for (let i = 0; i < maxDataPoints; i++) {
              tempData.push([timestamp - ((maxDataPoints - i) / 2.0) * 1000, null])
            }
            dataCache[channel] = tempData
            // 创建新系列配置
            const newSeries = {
              name: channel,
              type: 'line',
              connectNulls: false,
              showSymbol: false,
              data: [],
              smooth: 0.2,
              lineStyle: { width: 1.5 },
              emphasis: {
                lineStyle: { width: 3 }
              },
              yAxisIndex: yAxisIndex
            }

            seriesConfig.push(newSeries)
            legendData.push({ name: channel })
          }

          Object.keys(components).forEach(key => {
            if (
              components[key].props.chartConfig.option.channel == channel ||
              (!components[key].props.chartConfig.option.channel &&
                components[key].props.chartConfig.chartConfig.title == channel)
            ) {
              components[key].props.chartConfig.option.value = Number(value).toFixed(2)
            }
          })

          // 添加新数据点
          dataCache[channel].push([timestamp, Number(value)])
          if (dataCache[channel].length > maxDataPoints) {
            dataCache[channel].shift()
          }
          minTime = Math.min(dataCache[channel][0][0], minTime)
          maxTime = Math.max(timestamp, maxTime)

          const val = Number(value)
          const tempMin = Math.floor(val)
          const tempMax = Math.ceil(val)
          if (yAxis[yAxisIndex].min === undefined) {
            yAxis[yAxisIndex].min = tempMin
            yAxis[yAxisIndex].max = tempMax
          } else {
            yAxis[yAxisIndex].min = Math.min(yAxis[yAxisIndex].min, tempMin)
            yAxis[yAxisIndex].max = Math.max(yAxis[yAxisIndex].max, tempMax)
          }

          // 更新系列数据
          const targetSeries = seriesConfig.find(s => s.name === channel)
          if (targetSeries) {
            targetSeries.data = dataCache[channel]
            if (enters.includes(channel)) {
              targetSeries.lineStyle.width = 3
              targetSeries.z = 999
            } else {
              targetSeries.lineStyle.width = 1.5
              targetSeries.z = 2
            }
          }
        })
        xAxis.min = minTime
        xAxis.max = maxTime
        option.xAxis = xAxis

        legendData.forEach(item => {
          if (enters.includes(item.name)) {
            item.textStyle = { fontWeight: 'bold' }
          } else {
            item.textStyle = { fontWeight: 'normal' }
          }
        })

        option.series = seriesConfig
        option.legend.data = legendData
        option.legend.selected = legendSelectedMap
        option.legend.scrollDataIndex = legendScrollDataIndex
        // setTimeout(() => {
        //   if (window.tooltipInfo1 && window.tooltipInfo1.dataIndex > 0) {
        //     window.tooltipInfo1.dataIndex--
        //     chart.dispatchAction({
        //       type: 'showTip',
        //       ...window.tooltipInfo1
        //     })
        //   }
        // }, 0)
      }
      const onReceiveDatas = (jsonArray) => {
        // 重置所有数据缓存和配置
        dataCache = {}
        seriesConfig = []
        legendData = []
        legendSelectedMap = {}
        legendScrollDataIndex = 0
        const xAxis = { ...option.xAxis }
        const yAxis = { ...option.yAxis }

        // 计算时间范围
        let minTime = Infinity
        let maxTime = -Infinity
        // 处理每个数据项
        jsonArray.forEach(jsonData => {
          const timestamp = new Date(jsonData.time || Date.now()).getTime()
          minTime = Math.min(minTime, timestamp)
          maxTime = Math.max(maxTime, timestamp)
          xAxis.min = minTime
          xAxis.max = maxTime

          // 处理每个通道
          Object.entries(jsonData.datas).forEach(([channel, value]) => {
            const yAxisIndex = parseInt(channel.slice(-3), 10) > 44 ? 1 : 0
            if (yAxisIndex > 0) return

            // 初始化数据缓存
            if (!dataCache[channel]) {
              dataCache[channel] = []

              // 创建新系列配置
              const newSeries = {
                name: channel,
                type: 'line',
                connectNulls: false,
                showSymbol: false,
                data: [],
                smooth: 0.2,
                lineStyle: { width: 1.5 },
                emphasis: {
                  lineStyle: { width: 3 }
                },
                yAxisIndex: yAxisIndex
              }

              seriesConfig.push(newSeries)
              legendData.push({ name: channel })
              legendSelectedMap[channel] = true // 默认选中所有通道
            }

            const val = Number(value)
            const tempMin = Math.floor(val)
            const tempMax = Math.ceil(val)
            if (yAxis[yAxisIndex].min === undefined) {
              yAxis[yAxisIndex].min = tempMin
              yAxis[yAxisIndex].max = tempMax
            } else {
              yAxis[yAxisIndex].min = Math.min(yAxis[yAxisIndex].min, tempMin)
              yAxis[yAxisIndex].max = Math.max(yAxis[yAxisIndex].max, tempMax)
            }
            // 添加数据点
            dataCache[channel].push([timestamp, val])

            // 更新系列数据
            const targetSeries = seriesConfig.find(s => s.name === channel)
            if (targetSeries) {
              targetSeries.data = dataCache[channel]
            }
          })
        })

        // 设置图表选项
        option.xAxis = xAxis
        option.series = seriesConfig
        option.legend.data = legendData
        option.legend.selected = legendSelectedMap
        option.legend.scrollDataIndex = legendScrollDataIndex
      }
      const jsonData = JSON.parse(event.data)
      if (Array.isArray(jsonData)) {
        onReceiveDatas(jsonData)
      } else {
        onReceiveData(jsonData)
      }
    } catch (e) {
      console.log(e)
    }
    // once = true
  })

  // 连接关闭时
  socket.addEventListener('close', event => {
    console.log('WebSocket 连接已关闭', event)
  })

  // 发生错误时
  socket.addEventListener('error', event => {
    console.error('WebSocket 错误:', event)
  })
}
