# MoonBench Web UI 部署

MoonBench Web UI 是纯静态页面，不需要后端服务。`webui/index.html` 默认带 demo 数据，也可以加载 `moon run webui` 生成的 JSON。

页面功能包括中英文切换、JSON 上传、粘贴 JSON、suite health、概要指标、均值图、样本曲线、attention heatmap、结果表格和 CSV 导出。attention case 如果 JSON 里带 `attention_matrix` 会展示该矩阵，否则使用内置示例矩阵。

## 本地预览

```bash
cd moonbench
/home/ubuntu/.moon/bin/moon run webui > webui/report-data.json
python3 -m http.server 4173 --directory webui
```

浏览器打开：

```text
http://127.0.0.1:4173/
```

## 生成数据

```bash
cd moonbench
/home/ubuntu/.moon/bin/moon run webui > webui/report-data.json
```

打开页面后点击 `Load JSON` 选择 `webui/report-data.json`。

也可以直接把 JSON 粘贴到页面输入区并点击 `Apply JSON`，适合 CI 日志、issue 或聊天窗口里的 benchmark 结果快速预览。

## Docker / Nginx

```bash
cd moonbench
docker build -f deploy/Dockerfile -t moonbench-web .
docker run --rm -p 8080:80 moonbench-web
```

访问：

```text
http://127.0.0.1:8080/
```

## 任意静态托管

上传 `webui/` 目录即可部署到 GitHub Pages、Netlify、Vercel Static、Cloudflare Pages、对象存储静态网站或公司内网 Nginx。

需要发布固定报告时，把 MoonBench JSON 一起放到同目录，例如 `report-data.json`；需要交互查看时，直接通过页面上传 JSON。Web UI 没有后端状态，适合放到 GitHub Pages 或任意静态 CDN。
