export interface LoginResult {
  token: string;
 /* userinfo: {
    /!**
     * 昵称
     *!/
    nickname: string
    /!**
     * 用户名
     *!/
    username: string
    /!**
     * 用户 id
     *!/
    id: string
  }*/
}
/**
 * @description 用户信息 只保留能用到的
 * @param userId 用户id
 * @param userName 用户名
 * @param nickName 昵称
 * @param avatar 头像
 * @param createTime 创建时间
 */
export interface UserInfo {
  userId: number;
  userName: string;
  nickName: string;
  avatar?: string;
  createTime: string;
}
/**
 * @param roles 角色列表
 * @param user 用户信息
 * @param permissions 权限列表
 */
export interface UserInfoResult {
  roles: string[];
  user: UserInfo;
  permissions: string[];
}
