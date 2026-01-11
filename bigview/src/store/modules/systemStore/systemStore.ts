import {defineStore} from 'pinia'
import {SystemStoreType, UserInfoType, FetchInfoType, SystemStoreEnum, SystemStoreUserInfoEnum} from './systemStore.d'
import {setLocalStorage, getLocalStorage, routerTurnByName, myDecrypt} from '@/utils'
import {StorageEnum} from '@/enums/storageEnum'
import {getUserInfoApi} from "@/api/path";
import {PageEnum} from "@/enums/pageEnum";

const {GO_SYSTEM_STORE} = StorageEnum

const storageSystem: SystemStoreType = getLocalStorage(GO_SYSTEM_STORE)

// 系统数据记录
export const useSystemStore = defineStore({
    id: 'useSystemStore',
    state: (): SystemStoreType => storageSystem || {
        token: undefined,
        userInfo: {
            userId: undefined,
            userName: undefined,
            userToken: undefined,
            nickName: undefined
        },
        fetchInfo: {
            OSSUrl: undefined
        }
    },
    getters: {
        getToken(): string {
            return this.token;
        },
        getUserInfo(): UserInfoType {
            return this.userInfo
        },
        getFetchInfo(): FetchInfoType {
            return this.fetchInfo
        },
    },
    actions: {
        setItem<T extends keyof SystemStoreType, K extends SystemStoreType[T]>(key: T, value: K): void {
            this.$patch(state => {
                state[key] = value
            });
            setLocalStorage(GO_SYSTEM_STORE, this.$state)
        },
        async afterLoginAction(goHome?: boolean): Promise<boolean> {
            console.log(this.getToken, 'this.getTokenthis.getTokenthis.getToken')
            if (!this.getToken) return false;
            // get user info
            const res = await getUserInfoApi()
            if (res && res.data && res.data.user) {
                const {nickName, userName, userId} = res.data.user
                this.setItem(SystemStoreEnum.USER_INFO, {
                    [SystemStoreUserInfoEnum.USER_TOKEN]: this.getToken,
                    [SystemStoreUserInfoEnum.NICK_NAME]: nickName,
                    [SystemStoreUserInfoEnum.USER_NAME]: userName,
                    [SystemStoreUserInfoEnum.USER_ID]: String(userId),
                })
                goHome ? routerTurnByName(PageEnum.BASE_HOME_NAME, true) : ''
                return true;
            }
            return false;
        },
        // 解密token
        decryptToken() {
            try {
                const cryptStr = getLocalStorage('__PRODUCTION__0.1.0__COMMON__LOCAL__KEY__')
                // const cryptStr = '31KDpmVjM+DIRvUGuMbfDBmgFSw6FrmRb/EbEkPnesIRbdQqUgotJMVDQKh0bwgquCl4V70tvthndMqnrPSR83ImNQJYDrfvXNe3sk2cekP8MHcw8GSVNSVTWneWTM1t6GDYa86f5HhHkEh0espqd68iIvgLBgc8Czv1hrVcJ3xaoEjBuQhTd/tR9o8uJkaV4+C/Bnim4gt5ROah8P2jjw=='
                console.log('cryptStr', cryptStr);
                const aesStr = myDecrypt(cryptStr)
                const aesObj = JSON.parse(aesStr)
                const token = aesObj.value['TOKEN__']['value']
                const userInfo = aesObj.value['USER__INFO__']['value']
                this.setItem(SystemStoreEnum.TOKEN, token)
                this.setItem(SystemStoreEnum.USER_INFO, {
                    [SystemStoreUserInfoEnum.USER_TOKEN]: token,
                    ...userInfo,
                })
            } catch (error) {
                console.log(error, 'error')
            }


        }
    }
})