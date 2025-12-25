import {defineAsyncComponent, defineComponent, h, PropType, resolveComponent} from "vue";
import { ElOption, ElRadio, ElCheckbox } from 'element-plus'
import cloneDeep from 'lodash/cloneDeep'
import {Field} from "./interface";

export default defineComponent({
    props: {
        modelValue: {
            type: [String, Number, Boolean, Array, Object] as PropType<any>,
            default: undefined,
            required: false
        },
        field: {
            type: Object as PropType<Field>,
            required: true
        }
    },
    emits: ['update:modelValue'],
    components: {
        Input: defineAsyncComponent(() => import('element-plus/es').then(({ElInput}) => ElInput)),
        Number: defineAsyncComponent(() => import('element-plus/es').then(({ElInputNumber}) => ElInputNumber)),
        Select: defineAsyncComponent(() => import('element-plus/es').then(({ElSelect}) => ElSelect)),
        Radio: defineAsyncComponent(() => import('element-plus/es').then(({ElRadio}) => ElRadio)),
        Checkbox: defineAsyncComponent(() => import('element-plus/es').then(({ElCheckbox}) => ElCheckbox)),
        UserSelection: defineAsyncComponent(() => import('../UserSelection/index')),
        RoleSelection: defineAsyncComponent(() => import('../RoleSelection/index'))
    },
    setup(props, {emit}) {
        /**
         * 构建属性参数
         * @param fieldClone
         */
        const buildProps = (fieldClone: Field) => {
            const dataObject: Record<string, any> = {}
            const _props = fieldClone.props || {}
            Object.keys(_props).forEach(key => {
                dataObject[key] = _props[key]
            })
            if (props.modelValue !== undefined) {
                dataObject.modelValue = props.modelValue
            } else {
                dataObject.modelValue = fieldClone.value
            }
            dataObject['onUpdate:modelValue'] = (value: any) => {
                emit('update:modelValue', value)
            }
            delete dataObject.options
            return dataObject
        }
        /**
         * 构建插槽
         * @param fieldClone
         */
        const buildSlots = (fieldClone: Field) => {
            let children: Record<string, any> = {}
            const slotFunctions: Record<string, any> = {
                Select: (conf: Field) => {
                    return conf.props.options.map((item: any) => {
                        return <ElOption label={item.label} value={item.value}></ElOption>
                    })
                },
                Radio: (conf: Field) => {
                    return conf.props.options.map((item: any) => {
                        return <ElRadio label={item.value}>{item.label}</ElRadio>
                    })
                },
                Checkbox: (conf: Field) => {
                    return conf.props.options.map((item: any) => {
                        return <ElCheckbox label={item.value}>{item.label}</ElCheckbox>
                    })
                }
            }
            const slotFunction = slotFunctions[fieldClone.name]
            if (slotFunction) {
                children.default = () => {
                    return slotFunction(fieldClone)
                }
            }
            return children
        }
        return {
            buildProps,
            buildSlots
        }
    },
    render() {
        const fieldClone: Field = cloneDeep(this.field)
        const slots = this.buildSlots(fieldClone)
        const props = this.buildProps(fieldClone)
        const eleComponent = resolveComponent(fieldClone.name)
        if (typeof eleComponent === 'string') {
            return h(eleComponent, props, slots)
        }
        return h(eleComponent, props, slots)
    }
})