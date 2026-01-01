<script setup lang="ts">
import { ref, reactive, h } from 'vue'
import { useProjectStore } from '../stores/projectStore'
import { 
    NCard, NGrid, NGridItem, NButton, NTag, NEmpty, NModal, NForm, NFormItem, 
    NInput, NDatePicker, NSelect, useMessage, NDataTable, NSpace, NPopconfirm
} from 'naive-ui'
import type { DataTableColumns } from 'naive-ui'

const store = useProjectStore()
const message = useMessage()

// --- Project Logic ---
const showCreateProjectModal = ref(false)
const newProject = reactive({
    code: '',
    name: '',
    type: '车辆工程',
    description: '',
    manager: '',
    plannedStartDate: null as number | null,
    plannedEndDate: null as number | null
})

const handleSelectProject = async (projectId: string) => {
    await store.loadProjectFromServer(projectId);
    window.history.pushState({}, '', `/pm/project/${projectId}`);
}

const handleCreateProject = async () => {
    if (!newProject.code || !newProject.name) {
        message.warning('请输入项目编号和名称')
        return
    }

    const projectData = {
        ...newProject,
        plannedStartDate: newProject.plannedStartDate ? new Date(newProject.plannedStartDate).toISOString().split('T')[0] : '',
        plannedEndDate: newProject.plannedEndDate ? new Date(newProject.plannedEndDate).toISOString().split('T')[0] : ''
    }

    const success = await store.createProject(projectData as any)
    if (success) {
        message.success('项目创建成功')
        showCreateProjectModal.value = false
        await store.fetchProjects()
        // Reset form
        newProject.code = ''
        newProject.name = ''
        newProject.description = ''
        newProject.manager = ''
        newProject.plannedStartDate = null
        newProject.plannedEndDate = null
    } else {
        message.error('项目创建失败')
    }
}

// --- User Management Logic ---
const showUserModal = ref(false)
const userList = ref<any[]>([])
const showUserEditModal = ref(false)
const isEditingUser = ref(false)
const userForm = reactive({
    id: 0,
    username: '',
    password: '',
    name: '',
    role: 'user'
})

const columns: DataTableColumns = [
    { title: 'ID', key: 'id', width: 60 },
    { title: '用户名', key: 'username' },
    { title: '姓名', key: 'name' },
    { 
        title: '角色', 
        key: 'role',
        render(row: any) {
            return h(NTag, { type: row.role === 'admin' ? 'error' : 'info' }, { default: () => row.role === 'admin' ? '管理员' : '普通用户' })
        }
    },
    {
        title: '操作',
        key: 'actions',
        render(row: any) {
            return h(NSpace, null, {
                default: () => [
                    h(NButton, { size: 'small', onClick: () => openEditUser(row) }, { default: () => '编辑' }),
                    h(NPopconfirm, {
                        onPositiveClick: () => handleDeleteUser(row.id)
                    }, {
                        default: () => '确认删除该用户吗？',
                        trigger: () => h(NButton, { size: 'small', type: 'error' }, { default: () => '删除' })
                    })
                ]
            })
        }
    }
]

const openUserManagement = async () => {
    userList.value = await store.fetchUsers()
    showUserModal.value = true
}

const openAddUser = () => {
    isEditingUser.value = false
    userForm.id = 0
    userForm.username = ''
    userForm.password = ''
    userForm.name = ''
    userForm.role = 'user'
    showUserEditModal.value = true
}

const openEditUser = (user: any) => {
    isEditingUser.value = true
    userForm.id = user.id
    userForm.username = user.username
    userForm.password = '' // Don't show password
    userForm.name = user.name
    userForm.role = user.role
    showUserEditModal.value = true
}

const handleSaveUser = async () => {
    if (!userForm.username || (!isEditingUser.value && !userForm.password)) {
        message.warning('请填写必要信息')
        return
    }

    let success = false
    if (isEditingUser.value) {
        success = await store.updateUser(userForm.id, userForm)
    } else {
        success = await store.createUser(userForm)
    }

    if (success) {
        message.success(isEditingUser.value ? '用户更新成功' : '用户创建成功')
        showUserEditModal.value = false
        userList.value = await store.fetchUsers()
    } else {
        message.error('操作失败')
    }
}

const handleDeleteUser = async (id: number) => {
    const success = await store.deleteUser(id)
    if (success) {
        message.success('用户删除成功')
        userList.value = await store.fetchUsers()
    } else {
        message.error('删除失败')
    }
}

const handleLogout = () => {
    store.logout();
}

// --- Change Password Logic ---
const showChangePasswordModal = ref(false)
const passwordForm = reactive({
    oldPassword: '',
    newPassword: '',
    confirmPassword: ''
})

const openChangePassword = () => {
    passwordForm.oldPassword = ''
    passwordForm.newPassword = ''
    passwordForm.confirmPassword = ''
    showChangePasswordModal.value = true
}

const handleChangePassword = async () => {
    if (!passwordForm.oldPassword || !passwordForm.newPassword || !passwordForm.confirmPassword) {
        message.warning('请填写所有字段')
        return
    }
    if (passwordForm.newPassword !== passwordForm.confirmPassword) {
        message.warning('两次输入的密码不一致')
        return
    }

    // Call store action
    const success = await store.changePassword(passwordForm.oldPassword, passwordForm.newPassword)
    if (success) {
        message.success('密码修改成功，请重新登录')
        showChangePasswordModal.value = false
        store.logout()
    } else {
        message.error('密码修改失败：原密码错误')
    }
}
</script>

<template>
    <div class="project-list-container">
        <div class="header">
            <div class="title-area">
                <h2>项目列表</h2>
                <n-space>
                    <n-button type="primary" @click="showCreateProjectModal = true">新建项目</n-button>
                    <n-button v-if="store.currentUser?.role === 'admin'" type="info" @click="openUserManagement">用户管理</n-button>
                </n-space>
            </div>
            <div class="user-info">
                <span>欢迎, {{ store.currentUser?.name }} ({{ store.currentUser?.role === 'admin' ? '管理员' : '用户' }})</span>
                <n-space>
                    <n-button size="small" type="default" @click="openChangePassword">修改密码</n-button>
                    <n-button size="small" type="error" @click="handleLogout">退出登录</n-button>
                </n-space>
            </div>
        </div>
        
        <div class="content">
            <n-empty v-if="store.projectList.length === 0" description="暂无项目" />
            
            <n-grid v-else :cols="3" :x-gap="16" :y-gap="16">
                <n-grid-item v-for="project in store.projectList" :key="project.code">
                    <n-card :title="project.name" hoverable class="project-card">
                        <template #header-extra>
                            <n-tag type="success" size="small">{{ project.type || '未分类' }}</n-tag>
                        </template>
                        <p class="description">{{ project.description || '暂无描述' }}</p>
                        <div class="meta">
                            <div>编号: {{ project.code }}</div>
                            <div>负责人: {{ project.manager }}</div>
                            <div>时间: {{ project.plannedStartDate }} ~ {{ project.plannedEndDate }}</div>
                        </div>
                        <template #action>
                            <n-button type="primary" block @click="handleSelectProject(project.code)">
                                进入项目
                            </n-button>
                        </template>
                    </n-card>
                </n-grid-item>
            </n-grid>
        </div>

        <!-- Create Project Modal -->
        <n-modal v-model:show="showCreateProjectModal" preset="card" title="新建项目" style="width: 600px">
            <n-form label-placement="left" label-width="100">
                <n-form-item label="项目编号">
                    <n-input v-model:value="newProject.code" placeholder="例如: PRJ-2024-002" />
                </n-form-item>
                <n-form-item label="项目名称">
                    <n-input v-model:value="newProject.name" placeholder="请输入项目名称" />
                </n-form-item>
                <n-form-item label="项目类型">
                    <n-select v-model:value="newProject.type" :options="[
                        { label: '车辆工程', value: '车辆工程' },
                        { label: '软件开发', value: '软件开发' },
                        { label: '基础设施', value: '基础设施' }
                    ]" />
                </n-form-item>
                <n-form-item label="负责人">
                    <n-input v-model:value="newProject.manager" placeholder="项目经理姓名" />
                </n-form-item>
                <n-form-item label="计划时间">
                    <n-date-picker v-model:value="newProject.plannedStartDate" type="date" style="width: 48%" placeholder="开始日期" />
                    <span style="margin: 0 4px">-</span>
                    <n-date-picker v-model:value="newProject.plannedEndDate" type="date" style="width: 48%" placeholder="结束日期" />
                </n-form-item>
                <n-form-item label="项目描述">
                    <n-input v-model:value="newProject.description" type="textarea" />
                </n-form-item>
            </n-form>
            <template #footer>
                <n-space justify="end">
                    <n-button @click="showCreateProjectModal = false">取消</n-button>
                    <n-button type="primary" @click="handleCreateProject">创建</n-button>
                </n-space>
            </template>
        </n-modal>

        <!-- User Management Modal -->
        <n-modal v-model:show="showUserModal" preset="card" title="用户管理" style="width: 800px">
            <n-space style="margin-bottom: 15px">
                <n-button type="primary" @click="openAddUser">添加用户</n-button>
            </n-space>
            <n-data-table :columns="columns" :data="userList" :pagination="{ pageSize: 10 }" />
        </n-modal>

        <!-- Add/Edit User Modal -->
        <n-modal v-model:show="showUserEditModal" preset="card" :title="isEditingUser ? '编辑用户' : '添加用户'" style="width: 500px">
            <n-form label-placement="left" label-width="80">
                <n-form-item label="用户名">
                    <n-input v-model:value="userForm.username" :disabled="isEditingUser" placeholder="登录账号" />
                </n-form-item>
                <n-form-item label="姓名">
                    <n-input v-model:value="userForm.name" placeholder="显示名称" />
                </n-form-item>
                <n-form-item label="密码">
                    <n-input v-model:value="userForm.password" type="password" :placeholder="isEditingUser ? '留空则不修改' : '登录密码'" />
                </n-form-item>
                <n-form-item label="角色">
                    <n-select v-model:value="userForm.role" :options="[{label:'普通用户', value:'user'}, {label:'管理员', value:'admin'}]" />
                </n-form-item>
            </n-form>
            <template #footer>
                <n-space justify="end">
                    <n-button @click="showUserEditModal = false">取消</n-button>
                    <n-button type="primary" @click="handleSaveUser">保存</n-button>
                </n-space>
            </template>
        </n-modal>

        <!-- Change Password Modal -->
        <n-modal v-model:show="showChangePasswordModal" preset="card" title="修改密码" style="width: 400px">
            <n-form label-placement="left" label-width="80">
                <n-form-item label="原密码">
                    <n-input type="password" v-model:value="passwordForm.oldPassword" placeholder="请输入原密码" />
                </n-form-item>
                <n-form-item label="新密码">
                    <n-input type="password" v-model:value="passwordForm.newPassword" placeholder="请输入新密码" />
                </n-form-item>
                <n-form-item label="确认密码">
                    <n-input type="password" v-model:value="passwordForm.confirmPassword" placeholder="请再次输入新密码" />
                </n-form-item>
            </n-form>
            <template #footer>
                <n-space justify="end">
                    <n-button @click="showChangePasswordModal = false">取消</n-button>
                    <n-button type="primary" @click="handleChangePassword">确认修改</n-button>
                </n-space>
            </template>
        </n-modal>
    </div>
</template>

<style scoped>
.project-list-container {
    padding: 20px;
    background-color: #f0f2f5;
    min-height: 100vh;
}

.header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
    background: white;
    padding: 15px 20px;
    border-radius: 8px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.1);
}

.title-area {
    display: flex;
    align-items: center;
    gap: 20px;
}

.title-area h2 {
    margin: 0;
}

.user-info {
    display: flex;
    gap: 15px;
    align-items: center;
}

.description {
    color: #666;
    margin-bottom: 15px;
    height: 40px;
    overflow: hidden;
    text-overflow: ellipsis;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
}

.meta {
    font-size: 12px;
    color: #999;
    margin-bottom: 10px;
}
</style>
