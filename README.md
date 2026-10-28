# Dev_Guide — Tech-JI 志愿者入门材料

目标：让新加入的志愿者从 `clone` 走到第一个合规 PR。

| 文件 | 给谁 | 语言 | 说明 |
|---|---|---|---|
| `Guide.md` | 学员（greenhand） | English | 幻灯片式手册（beamer，70 页 / 61 张内容 slide）：项目全景、工具链与本地启动、Git/GitHub 与 Kaneo 协作契约、三项目架构深挖、TDD 与 CI 验证、代码级与 SSH 密钥安全/学生隐私、Vibe Coding 规范与精选学习资源 |
| `mermaid.lua` | 编译脚本 | Lua | Pandoc 过滤器：将 `Guide.md` 中的 `mermaid` 流程图直接渲染为矢量 LaTeX TikZ 图形，避免 ASCII 折行与错位 |

## 编译成 PDF

```bash
cd Dev_Guide
make pdf          # 生成 guide.pdf（等同于 make guide）
make guide        # 只出学员手册（beamer 幻灯片）
make guide-tex    # 只出 guide.tex，用来看 LaTeX log 有没有溢出
make check        # 检查 pandoc / xelatex 是否齐
make clean        # 删除生成物
```

需要 `pandoc`、`texlive`（`xelatex`）与字体 `Noto Sans`、`DejaVu Sans Mono`。

`guide.pdf` 是 4:3 幻灯片：每个 `##` 标题就是一屏，一屏只放一个概念，满屏放映即可阅读，不需要放大。改稿时请守住三条排版约束，否则会溢出页面：

1. 表格每个单元格都要短，整行不超过 110 个字符（pandoc 生成的表格不会自动换行）。
2. 一屏放不下就拆成 `(1/2)`、`(2/2)` 两屏，不要硬塞。
3. 代码块不要用 `├── └── │` 这类框线字符，等宽字体里没有这些字形，用缩进即可。

## 参考资料

- 去年（2025-12-28，56 分 21 秒）CourseReview 结构讲解录课：
  <https://sjtu.feishu.cn/minutes/obcnxdu8kam1bvu7eu6oiaq7>

## 维护

- 内容改动直接改 `Guide.md`，然后 `make pdf`。
