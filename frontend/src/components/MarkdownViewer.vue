<template>
  <div class="markdown-body" v-html="renderedContent"></div>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import MarkdownIt from 'markdown-it';
import hljs from 'highlight.js';
import 'highlight.js/styles/github.css';

const props = defineProps({
  content: {
    type: String,
    default: ''
  }
});

// Markdown Setup
const md: any = new MarkdownIt({
  html: true,
  linkify: true,
  typographer: true,
  highlight: function (str: string, lang: string): string {
    if (lang && hljs.getLanguage(lang)) {
      try {
        return '<pre class="hljs"><code>' +
               hljs.highlight(str, { language: lang, ignoreIllegals: true }).value +
               '</code></pre>';
      } catch (__) {}
    }
    return '<pre class="hljs"><code>' + md.utils.escapeHtml(str) + '</code></pre>';
  }
});

const renderedContent = computed(() => {
  return md.render(props.content || '');
});
</script>

<style scoped>
.markdown-body {
  padding: 24px;
  overflow: auto;
  height: 100%;
  box-sizing: border-box;
  color: #24292f;
  background-color: #ffffff;
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji";
  font-size: 16px;
  line-height: 1.5;
  word-wrap: break-word;
}

/* Markdown Styles */
.markdown-body :deep(table) {
  display: block;
  width: 100%;
  max-width: 100%;
  overflow: auto;
  border-spacing: 0;
  border-collapse: collapse;
  margin-bottom: 16px;
}

.markdown-body :deep(th),
.markdown-body :deep(td) {
  padding: 8px 16px;
  border: 1px solid #d0d7de;
  text-align: left;
}

.markdown-body :deep(th) {
  font-weight: 600;
  background-color: #f6f8fa;
}

.markdown-body :deep(tr) {
  background-color: #ffffff;
  border-top: 1px solid #d0d7de;
}

.markdown-body :deep(tr:nth-child(2n)) {
  background-color: #f6f8fa;
}

.markdown-body :deep(h1),
.markdown-body :deep(h2),
.markdown-body :deep(h3),
.markdown-body :deep(h4),
.markdown-body :deep(h5),
.markdown-body :deep(h6) {
  margin-top: 24px;
  margin-bottom: 16px;
  font-weight: 600;
  line-height: 1.25;
}

.markdown-body :deep(p) {
  margin-bottom: 16px;
}

.markdown-body :deep(a) {
  color: #0969da;
  text-decoration: none;
}

.markdown-body :deep(a:hover) {
  text-decoration: underline;
}

.markdown-body :deep(ul),
.markdown-body :deep(ol) {
  padding-left: 2em;
  margin-bottom: 16px;
}

.markdown-body :deep(blockquote) {
  margin: 0 0 16px;
  padding: 0 1em;
  color: #57606a;
  border-left: 0.25em solid #d0d7de;
}

.markdown-body :deep(pre),
.markdown-body :deep(code) {
  padding: 0;
  font-family: "Courier New", "NSimSun", monospace; /* Courier New + NSimSun provides better CJK alignment on Windows */
  font-variant-ligatures: none;
  -webkit-font-smoothing: antialiased;
  letter-spacing: 0;
}

.markdown-body :deep(pre) {
  padding: 16px;
  overflow: auto;
  font-size: 14px; /* Set explicit size */
  line-height: 1.0; /* Tighter line height for ASCII art */
  background-color: #f6f8fa; /* Ensure background is present */
  border-radius: 6px;
  margin-bottom: 16px;
  white-space: pre; /* Ensure whitespace is preserved exactly */
}

.markdown-body :deep(code) {
  padding: 0.2em 0.4em;
  margin: 0;
  font-size: 85%;
  background-color: rgba(175, 184, 193, 0.2); /* Restore inline code background */
  border-radius: 6px;
}

.markdown-body :deep(pre code) {
  padding: 0 !important;
  margin: 0;
  font-size: 100%;
  word-break: normal;
  white-space: pre;
  background: transparent !important; /* Force remove background */
  border: 0;
  border-radius: 0;
  line-height: 1.2;
  font-family: inherit; /* Ensure font matches pre */
}

.markdown-body :deep(img) {
  max-width: 100%;
  box-sizing: content-box;
  background-color: #ffffff;
}

.markdown-body :deep(hr) {
  height: 1px;
  padding: 0;
  margin: 16px 0;
  background-color: #d0d7de;
  border: 0;
}
</style>