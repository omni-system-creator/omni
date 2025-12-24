interface TreeHelperConfig {
    id: string;
    children: string;
    pid: string;
}
// 默认配置
const DEFAULT_CONFIG:TreeHelperConfig = {
    id: 'id',
    children: 'children',
    pid: 'parentId',
};

export function listToTree<T = any>(list: any[], config?:TreeHelperConfig): T[] {
    const conf = config || DEFAULT_CONFIG;
    const nodeMap = new Map();
    const result: T[] = [];
    const {id, children, pid} = conf;

    for (const node of list) {
        node[children] = node[children] || [];
        nodeMap.set(node[id], node);
    }
    for (const node of list) {
        const parent = nodeMap.get(node[pid]);
        (parent ? parent[children] : result).push(node);
    }
    return result;
}