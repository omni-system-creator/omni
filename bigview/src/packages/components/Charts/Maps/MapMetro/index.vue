<template>
  <div ref="vChartRef" id="maplibregl" :style="{ width: 500 + 'px', height: 500 + 'px' }">
    <!--     <div style="width: 200px; height: 200px; background-color: aliceblue; position: absolute" id="xxx"></div>
    <div style="width: 200px; height: 200px; top: 40px; right: 100px; position: absolute">
      <n-select v-model:value="sel_map_param_name" :options="options" @update:value="handleUpdateValue" />
    </div>-->
  </div>
</template>

<script setup lang="ts">
import { ref, PropType, toRefs, watch, onMounted } from 'vue'
import AMapLoader from '@amap/amap-jsapi-loader'
import { CreateComponentType } from '@/packages/index.d'
import { useChartDataFetch } from '@/hooks'
import { useChartEditStore } from '@/store/modules/chartEditStore/chartEditStore'
import { isArray } from '@/utils'
import { HexagonLayer } from '@deck.gl/aggregation-layers'
import { MapboxOverlay as DeckOverlay } from '@deck.gl/mapbox'
import { option } from '@/packages/components/Charts/Maps/MapMetro/config'
import maplibregl from 'maplibre-gl'
import { http } from '@/api/http'
import { RequestHttpEnum, ModuleTypeEnum } from '@/enums/httpEnum'

const props = defineProps({
  chartConfig: {
    type: Object as PropType<CreateComponentType>,
    required: true
  }
})

const options = ref([
  { label: '动车横向平稳性', value: 'pingwen_dong_heng' },
  { label: '动车垂向平稳性', value: 'pingwen_dong_chui' },
  { label: '拖车横向平稳性', value: 'pingwen_tuo_heng' },
  { label: '拖车垂向平稳性', value: 'pingwen_tuo_chui' },
  { label: '头车客室噪声', value: 'zaosheng_tou' },
  { label: '中间车客室噪声', value: 'zhaosheng_zhong' },
  { label: '动架轮轨噪声', value: 'zaosheng_dongjia' },
  { label: '拖架轮轨噪声', value: 'zaosheng_tuojia' },
  { label: '横梁折弯测点应力值', value: 'yingli_hengliang' },
  { label: '排障器测点应力值（PZA01S）', value: 'PZA01S' },
  { label: '转臂安装座应力值（LA03SM）', value: 'LA03SM' },
  { label: '电机吊装筋板应力值（MB01SM）', value: 'MB01SM' },
  { label: '头车车内外压差', value: 'tou_wai' },
  { label: '头车车内1s变化量', value: 'tou_1s' },
  { label: '头车车内3s变化量', value: 'tou_3s' },
  { label: '中间车车内外压差', value: 'zhong_wai' },
  { label: '中间车车内1s变化量', value: 'zhong_1s' },
  { label: '中间车车内3s变化量', value: 'zhong_3s' },
  { label: '接触力', value: 'jiechuli' },
  { label: '硬点', value: 'yingdian' },
  { label: '燃弧时间', value: 'ranhu_shijian' },
  { label: '轨距', value: 'guiju' },
  { label: '左高低', value: 'left_gaodi' },
  { label: '右高低', value: 'right_gaodi' },
  { label: '左轨向', value: 'left_guixiang' },
  { label: '右轨向', value: 'right_guixiang' },
  { label: '三角坑', value: 'sanjiaokeng' },
  { label: '水平', value: 'shuiping' },
  { label: '垂向加速度', value: 'chuixiang' },
  { label: '横向加速度', value: 'hengxiang' },
  { label: '轨距变化率', value: 'guiju_bianhua' },
  { label: 'TQI', value: 'tqi' },
  { label: '轨距', value: 'x_guiju' },
  { label: '左轨向', value: 'zuogui' },
  { label: '右轨向', value: 'yougui' },
  { label: '左高低', value: 'zuogao' },
  { label: '右高低', value: 'yougao' },
  { label: '三角坑', value: 'sanjiao' },
  { label: '水平', value: 'x_shuiping' }
])
const sel_map_param_name = ref('yingdian')

const vChartRef = ref<HTMLElement>()
let map: any
let hotLayer: any = null
let zoomStart = 0
let hot_size = 20
let nowId = 1
let pici: any = ''
let shangxia: any = ''
const propOptions = ref<any>({})
const metroInfo = {
  tz: {
    center: [121.342, 28.4869],
    zoom: 11.5,
    rotate: 90,
    pitch: 48,
    marker_center: [121.462, 28.56],
    marker_title: '台州市域S1线'
  },
  fz_f1: {
    center: [119.5, 25.97],
    zoom: 11.7,
    rotate: 12,
    pitch: 60,
    marker_center: [119.4, 26.21],
    marker_title: '福州滨海快线'
  }
}
const zoomArr = [
  {
    level_min: 9,
    level_max: 12.5,
    hot_size: 500,
    radius: 50,
    elevationScale: 6
  },
  {
    level_min: 12.5,
    level_max: 13.5,
    hot_size: 100,
    radius: 25,
    elevationScale: 4
  },
  {
    level_min: 13.5,
    level_max: 14.5,
    hot_size: 100,
    radius: 15,
    elevationScale: 2
  },
  {
    level_min: 14.5,
    level_max: 16.5,
    hot_size: 20,
    radius: 5,
    elevationScale: 1
  },
  {
    level_min: 16.5,
    level_max: 20.5,
    hot_size: 10,
    radius: 1,
    elevationScale: 1
  }
]
const handleUpdateValue = (val: any) => {
  console.log('成功调用UpdateValue', val)
  sel_map_param_name.value = val
  deck_del(hotLayer)
  addNewLayer(
    hotLayer,
    sel_map_param_name.value,
    zoomArr[nowId].hot_size,
    zoomArr[nowId].elevationScale,
    zoomArr[nowId].radius
  )
}

function deck_del(deckOverlay: any) {
  if (!deckOverlay) return
  // const decklayers = deckOverlay._props.layers
  // for (let i = 0; i < decklayers.length; i++) {
  //   decklayers.splice(i, 1)
  //   debugger
  // }
  deckOverlay.setProps({
    layers: []
  })
}

function addNewLayer(deckOverlay: any, param_name: string, size: number, elevationScale: number, radius: number) {
  const label_cn = options.value.filter((map: any) => map.value === param_name)[0].label
  let baseUrl = location.protocol + '//' + location.hostname + (location.port ? ':' + location.port : '') + '/'
  const url = `goview/project/gettz_line_ex?type=${param_name}&size=${size}&pici=${pici}&shangxia=${shangxia}`
  const nowAlpha = propOptions.value.alpha
  console.log('dddddddddd', nowAlpha)
  const layer = new HexagonLayer({
    id: 'HexagonLayer',
    data: baseUrl + url,
    extruded: true,
    getPosition: (d: any) => d.COORDINATES,
    getColorWeight: (d: any) => d.VALUES,
    getElevationWeight: (d: any) => d.VALUES,
    elevationAggregation: 'MAX',
    colorAggregation: 'MAX',
    elevationScale: elevationScale,
    radius: radius,
    pickable: true,
    colorRange: [
      [26, 152, 80, nowAlpha],
      [145, 207, 96, nowAlpha],
      [217, 239, 139, nowAlpha],
      [254, 224, 139, nowAlpha],
      [252, 141, 89, nowAlpha],
      [215, 48, 39, nowAlpha]
    ],
    material: {
      ambient: 0.8,
      shininess: 1,
      specularColor: [0.3, 0.1, 0.2]
    }
  })
  if (deckOverlay == null) {
    const deckOverlay = new DeckOverlay({
      layers: [layer],
      getTooltip: ({ object }: any) => object && `${label_cn}: ${object.elevationValue}`
    })
    return deckOverlay
  } else {
    deckOverlay.setProps({
      layers: [layer],
      getTooltip: ({ object }: any) => object && `${label_cn}: ${object.elevationValue}`
    })
  }
}

const initMap = async (newData: any) => {
  // 初始化
  const baseUrlSuffix = import.meta.env.VITE_MAP_METRO_BASE_URL
  if (!vChartRef.value) return
  map = new maplibregl.Map({ container: vChartRef.value as HTMLElement, ...(option.maplibreglOptions as any) })
  let baseUrl =
    location.protocol + '//' + location.hostname + (location.port ? ':' + location.port : '') + '/' + baseUrlSuffix
  console.log(baseUrl, 'baseUrlbaseUrl')
  const json_file = propOptions.value.line === 'all' ? 'geojson_all' : propOptions.value.line
  const res = await http(RequestHttpEnum.GET)(baseUrl + `/${json_file}.json`)
  // debugger
  var res_station: any = null
  if (json_file == 'geojson_fz_f1') {
    res_station = await http(RequestHttpEnum.GET)(baseUrl + `/getstation_fz_f1.json`)
  } else if (json_file == 'geojson_tz') {
    res_station = await http(RequestHttpEnum.GET)(baseUrl + `/getstation_tz.json`)
    // res_station = await http(RequestHttpEnum.GET)(`/project/gettz_station`)
  } else if (json_file == 'geojson_all') {
    res_station = await http(RequestHttpEnum.GET)(baseUrl + `/getstation_all.json`)
  }

  map.on('load', async () => {
    map.addSource('route', {
      type: 'geojson',
      data: res
    })
    // map.addLayer({
    //   id: 'route',
    //   type: 'line',
    //   source: 'route',
    //   layout: {
    //     'line-join': 'round',
    //     'line-cap': 'round'
    //   },
    //   paint: {
    //     'line-color': '#888',
    //     'line-width': 8
    //   }
    // })
    map.addLayer({
      id: 'route',
      type: 'line',
      source: 'route',
      layout: {
        'line-join': 'round',
        'line-cap': 'round'
      },
      paint: {
        'line-color': propOptions.value.lineColor2,
        'line-width': propOptions.value.lineWidth
      }
    })
    map.addLayer({
      id: 'route-up',
      type: 'line',
      source: 'route',
      paint: {
        'line-dasharray': [propOptions.value.railwayWidth, propOptions.value.railwayWidth * 2],
        'line-color': propOptions.value.lineColor,
        'line-width': propOptions.value.lineWidth
      },
      layout: {
        'line-cap': 'square',
        'line-join': 'bevel',
        visibility: 'visible'
      }
    })
    hotLayer = addNewLayer(
      null,
      'yingdian',
      zoomArr[nowId].hot_size,
      zoomArr[nowId].elevationScale,
      zoomArr[nowId].radius
    )
    map.addControl(hotLayer)
    map.flyTo({
      center: propOptions.value.center,
      zoom: propOptions.value.zoom,
      pitch: propOptions.value.pitch,
      bearing: propOptions.value.bearing
    })
    // let el = document.getElementById('xxx');
    // el.className = 'marker2d';
    // let marker = new maplibregl.Marker(el).setLngLat([121.362, 28.4769]).addTo(map)
    // console.log(marker)
    // 增加站点
    const image = await map.loadImage(baseUrl + '/station.png')
    map.addImage('custom-marker', image.data)
    map.addSource('conferences', res_station)
    const aa = map.addLayer({
      id: 'conferences',
      type: 'symbol',
      source: 'conferences',
      layout: {
        'icon-image': 'custom-marker',
        // get the year from the source's "year" property
        'text-field': ['get', 'name'],
        'text-font': ['Open Sans Semibold', 'Arial Unicode MS Bold'],
        'text-offset': [0, 1.25],
        'text-anchor': 'top'
      },
      paint: {
        'text-color': '#202',
        'text-halo-color': '#fff',
        'text-halo-width': 2
      }
    })
    addPopup(json_file == 'geojson_fz_f1')
  })

  let old_id = -1
  map.on('zoomend', (event: any) => {
    const zoomEnd = map.getZoom()
    let _id = -1
    for (let i = 0; i < zoomArr.length; i++) {
      if (zoomEnd > zoomArr[i].level_min && zoomEnd <= zoomArr[i].level_max) {
        _id = i
        console.log(zoomEnd, zoomArr[i])
        break
      }
    }
    if (_id >= 0) {
      if (old_id != _id) {
        old_id = _id
        nowId = _id
        if (hotLayer) {
          deck_del(hotLayer)
          addNewLayer(
            hotLayer,
            sel_map_param_name.value,
            zoomArr[_id].hot_size,
            zoomArr[_id].elevationScale,
            zoomArr[_id].radius
          )
        }
      }
    }
  })
}

function updateMap(option: any) {
  propOptions.value = option

  // console.error(propOptions.value)
  // map.on('load', () => {
  map.flyTo({
    center: propOptions.value.center,
    zoom: propOptions.value.zoom,
    pitch: propOptions.value.pitch,
    bearing: propOptions.value.bearing
  })
  // });
}

const dataHandle = (newData: any) => {}
// 处理树的数据
function handleTreeData(e: any) {
  if (!e.children) {
    const key = e.key.split('-')
    pici = parseInt(key[0]) + 1 + ''
    shangxia = parseInt(key[1]) + 1 + ''
    const indicator = key[2]
    sel_map_param_name.value = indicator
    deck_del(hotLayer)
    addNewLayer(
      hotLayer,
      sel_map_param_name.value,
      zoomArr[nowId].hot_size,
      zoomArr[nowId].elevationScale,
      zoomArr[nowId].radius
    )
  }
}
let prevPopup: any = null
const addPopup = (isFuzhou: boolean) => {
  if (!propOptions.value.showLabel) {
    return
  }
  const popupTitle = isFuzhou ? '福州滨海快线' : '台州市域S1线'
  const popupCoor = isFuzhou ? [119.4, 26.21] : [121.462, 28.56]
  if (prevPopup) {
    prevPopup.remove()
  }
  const popup = new maplibregl.Popup({ closeOnClick: false })
    .setLngLat(popupCoor as [number, number])
    .setHTML('<h1>' + popupTitle + '</h1>')
    .addTo(map)
  prevPopup = popup
}
const ChangeMetro = (val: string) => {
  let metro_sel: any = null
  if (val === 'tz') {
    metro_sel = metroInfo.tz
  } else if (val == 'fz_f1') {
    metro_sel = metroInfo.fz_f1
  }
  if (metro_sel && map) {
    map.flyTo({
      center: metro_sel.center,
      zoom: metro_sel.zoom,
      pitch: metro_sel.pitch,
      bearing: metro_sel.rotate
    })
  }
  addPopup(val === 'fz_f1')
}
// 处理标签的数据
function handleTabData(e: any) {
  // alert(JSON.stringify(e))
  if (e != '第二次') {
    alert('当前只导入了第二次的数据')
  }
  // alert('成功调用Tab标签数据:'+JSON.stringify(e));
}

onMounted(() => {
  initMap(null)
  // 可以在这里添加额外的地图交互或标记等
})

// 暴露函数试试呢
defineExpose({
  ChangeMetro,
  handleUpdateValue,
  handleTreeData,
  handleTabData
})

const stopWatch = watch(
  () => props.chartConfig.option.mapOptions,
  option => {},
  {
    immediate: true,
    deep: true
  }
)

watch(
  () => props.chartConfig.option.dataset,
  newData => {
    try {
      // empty
    } catch (error) {
      console.log(error)
    }
  },
  {
    deep: false
  }
)

watch(
  () => props.chartConfig.option.maplibreglOptions,
  option => {
    try {
      updateMap(option)
    } catch (error) {
      console.log(error)
    }
  },
  {
    immediate: true,
    deep: true
  }
)

// 预览
useChartDataFetch(props.chartConfig, useChartEditStore, (newData: any) => {
  stopWatch()
  // dataHandle(newData)
})
</script>
<style>
.marker2d {
  width: 100px;
  height: 100px;
  background-color: aliceblue;
  position: absolute;
}
</style>
