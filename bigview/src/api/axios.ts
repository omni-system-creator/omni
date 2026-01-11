import axios, { AxiosResponse, AxiosRequestConfig, Axios, AxiosError, InternalAxiosRequestConfig } from 'axios'
import { RequestHttpHeaderEnum, ResultEnum, ModuleTypeEnum } from '@/enums/httpEnum'
import { PageEnum, ErrorPageNameMap } from '@/enums/pageEnum'
import { StorageEnum } from '@/enums/storageEnum'
import { axiosPre } from '@/settings/httpSetting'
import { SystemStoreEnum, SystemStoreUserInfoEnum } from '@/store/modules/systemStore/systemStore.d'
import { redirectErrorPage, getLocalStorage, routerTurnByName, isPreview } from '@/utils'
import { fetchAllowList } from './axios.config'
import includes from 'lodash/includes'

export interface MyResponseType<T> {
    code: ResultEnum
    data: T
    msg: string
    rows: T // 兼容旧代码，但在标准 ApiResponse 中应使用 data
    message: string // 兼容旧代码，但在标准 ApiResponse 中应使用 msg
}

export interface MyRequestInstance extends Axios {
    <T = any>(config: AxiosRequestConfig): Promise<MyResponseType<T>>
}

const axiosInstance = axios.create({
    baseURL: `${axiosPre}`,
    timeout: ResultEnum.TIMEOUT
}) as unknown as MyRequestInstance

axiosInstance.interceptors.request.use(
    (config: InternalAxiosRequestConfig) => {
        // 白名单校验
        if (includes(fetchAllowList, config.url)) return config
        // 获取 token
        const info = getLocalStorage(StorageEnum.GO_SYSTEM_STORE)
        if (info && info[SystemStoreEnum.TOKEN]) {
            const token = info[SystemStoreEnum.TOKEN]
            // @ts-ignore
            config.headers['Authorization'] = 'Bearer ' + token
        }
        return config
    },
    (err: AxiosError) => {
        Promise.reject(err)
    }
)

// 响应拦截器
axiosInstance.interceptors.response.use(
    (res: AxiosResponse) => {
        // 预览页面错误不进行处理
        if (isPreview()) {
            return Promise.resolve(res.data)
        }
        const { code } = res.data as { code: number }

        if (code === undefined || code === null) return Promise.resolve(res.data)

        // 成功
        if (code === ResultEnum.SUCCESS) {
            return Promise.resolve(res.data)
        }

        // 登录过期
        if (code === ResultEnum.TOKEN_OVERDUE) {
            window['$message'].error(window['$t']('http.token_overdue_message'))
            routerTurnByName(PageEnum.BASE_LOGIN_NAME)
            return new Promise(() => {})
        }

        // 固定错误码重定向
        if (ErrorPageNameMap.get(code)) {
            redirectErrorPage(code)
            return Promise.resolve(res.data)
        }

        // 提示错误
        window['$message'].error(window['$t']((res.data as any).msg))
        return Promise.resolve(res.data)
    },
    (err: AxiosError) => {
        const status = err.response?.status
        switch (status) {
            case 401:
                routerTurnByName(PageEnum.BASE_LOGIN_NAME)
                // 返回一个永远不会 resolve 的 Promise，防止后续代码继续执行并报错，等待路由跳转
                return new Promise(() => {})

            default:
                return Promise.reject(err)
        }
    }
)

export default axiosInstance
