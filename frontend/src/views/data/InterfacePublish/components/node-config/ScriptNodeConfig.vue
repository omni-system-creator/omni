<template>
  <a-alert message="脚本逻辑" type="info" show-icon style="margin-bottom: 16px">
    <template #description>
      <div style="font-size: 12px;">
        <p>执行自定义脚本进行数据转换。</p>
        <p><strong>Available Vars:</strong> <code>context</code> (dictionary/object)</p>
        <p><strong>Return:</strong> 返回结果将存入 <code>scriptResult</code></p>
      </div>
    </template>
  </a-alert>
  <a-form-item label="脚本语言">
    <a-select v-model:value="node.data.language" defaultValue="javascript" @change="onChange">
      <a-select-option value="JavaScript">JavaScript</a-select-option>
      <a-select-option value="CSharp">C#</a-select-option>
      <a-select-option value="Python">Python</a-select-option>
      <a-select-option value="Matlab">Matlab</a-select-option>
    </a-select>
  </a-form-item>
  <a-form-item label="脚本代码">
    <a-textarea v-model:value="node.data.script" :rows="10" :placeholder="getScriptPlaceholder(node.data.language)" @input="onChange" style="font-family: monospace;" />
  </a-form-item>
</template>

<script setup lang="ts">
const props = defineProps<{
  node: any;
  readOnly?: boolean;
}>();

const emit = defineEmits(['change']);

const onChange = () => {
  emit('change');
};

const getScriptPlaceholder = (lang: string) => {
    const l = lang || 'javascript';
    switch (l) {
        case 'csharp':
            return `// C# Script
// Variables: context (Dictionary<string, object>), log (Action<string>)
// Return: Any object

// Example:
var rows = context["dbResult"] as List<object>;
if (rows != null) {
    log("Processing " + rows.Count + " rows");
    return new { Count = rows.Count, Status = "OK" };
}
return null;`;
        case 'python':
            return `# Python Script
# Input: 'context.json' file (in current dir)
# Output: Print JSON to stdout

import json
import sys

# Read context
try:
    with open('context.json', 'r', encoding='utf-8') as f:
        context = json.load(f)
    
    # Logic here
    result = { "status": "ok", "data": context.get("dbResult") }
    
    print(json.dumps(result))
except Exception as e:
    print(json.dumps({ "error": str(e) }));`;
        case 'matlab':
            return `% Matlab Script
% Input: 'context.json'
% Output: Write to 'result.json'

data = jsondecode(fileread('context.json'));

% Logic here
result.status = 'ok';
result.processed = true;

fid = fopen('result.json', 'w');
fprintf(fid, '%s', jsonencode(result));
fclose(fid);`;
        case 'javascript':
        default:
            return `// Example: Process DB results
var rows = context.dbResult;
if (!rows) return { count: 0 };

var total = 0;
for (var i = 0; i < rows.length; i++) {
    // Assuming row has 'price' field
    total += (rows[i].price || 0);
}

log('Calculated total: ' + total);
return { total: total, count: rows.length };`;
    }
};
</script>
