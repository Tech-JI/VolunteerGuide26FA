-- Pandoc Lua filter: converts ```mermaid flowchart LR blocks into crisp vector Beamer TikZ diagrams.

local function escape_latex(s)
  s = s:gsub("\\n", "\n")
  local lines = {}
  for line in (s .. "\n"):gmatch("(.-)\n") do
    line = line:gsub("([#$%&_{}])", "\\%1")
    line = line:gsub("%-%->", "$\\rightarrow$")
    line = line:gsub("<%-%->", "$\\leftrightarrow$")
    table.insert(lines, line)
  end
  if #lines > 1 then
    return "\\textbf{" .. lines[1] .. "}\\\\\\scriptsize " .. table.concat(lines, "\\\\", 2)
  else
    return "\\textbf{" .. (lines[1] or "") .. "}"
  end
end

local function escape_edge_label(s)
  s = s:gsub("([#$%&_{}])", "\\%1")
  return "\\texttt{\\scriptsize " .. s .. "}"
end

function CodeBlock(block)
  if not block.classes:includes("mermaid") then
    return nil
  end

  local nodes = {}
  local node_order = {}
  local node_seen = {}
  local edges = {}

  local function register_node(id, label)
    if not node_seen[id] then
      node_seen[id] = true
      table.insert(node_order, id)
    end
    if label and label ~= "" then
      nodes[id] = label
    elseif not nodes[id] then
      nodes[id] = id
    end
  end

  for raw_line in block.text:gmatch("[^\r\n]+") do
    local line = raw_line:match("^%s*(.-)%s*$")
    if line ~= "" and not line:match("^flowchart%s") and not line:match("^graph%s") and not line:match("^%%%%") then
      -- Parse definitions like ID["Label"] or ID[Label]
      for id, lbl in line:gmatch('([%w_]+)%s*%["(.-)"%]') do
        register_node(id, lbl)
      end
      for id, lbl in line:gmatch('([%w_]+)%s*%[([^"%]]-)%]') do
        register_node(id, lbl)
      end

      -- Remove bracket definitions from line to parse edges cleanly
      local clean = line:gsub('%["(.-)"%]', ""):gsub('%[([^%]]-)%]', "")

      -- Match edge with label: A -->|label| B or A <-->|label| B
      local u, arrow, elbl, v = clean:match("([%w_]+)%s*(<?%-%-+>|?)%s*|([^|]-)|%s*([%w_]+)")
      if u and v then
        register_node(u, nil)
        register_node(v, nil)
        table.insert(edges, { from = u, to = v, arrow = arrow, label = elbl })
      else
        -- Match edge without label: A --> B or A <--> B
        local u2, arrow2, v2 = clean:match("([%w_]+)%s*(<?%-%-+>)%s*([%w_]+)")
        if u2 and v2 then
          register_node(u2, nil)
          register_node(v2, nil)
          table.insert(edges, { from = u2, to = v2, arrow = arrow2, label = nil })
        end
      end
    end
  end

  if #node_order == 0 then
    return nil
  end

  -- Determine horizontal spacing based on node count and edge labels
  local has_edge_labels = false
  for _, e in ipairs(edges) do
    if e.label and e.label ~= "" then
      has_edge_labels = true
      break
    end
  end

  local node_dist = "1.6cm"
  if has_edge_labels then
    node_dist = "2.2cm"
  elseif #node_order >= 6 then
    node_dist = "0.7cm"
  elseif #node_order == 4 then
    node_dist = "1.2cm"
  end

  local tex = {}
  table.insert(tex, "\\begin{center}")
  table.insert(tex, "\\resizebox{0.98\\linewidth}{!}{%")
  table.insert(tex, "\\begin{tikzpicture}[")
  table.insert(tex, "  node distance=" .. node_dist .. ",")
  table.insert(tex, "  mnode/.style={rectangle, rounded corners=4pt, draw=blue!60!black, line width=0.8pt, fill=blue!6, align=center, inner sep=6pt, minimum height=1.1cm, font=\\footnotesize\\sffamily},")
  table.insert(tex, "  medge/.style={-{Stealth[length=2.5mm, width=1.8mm]}, line width=0.9pt, draw=blue!50!black},")
  table.insert(tex, "  mbedge/.style={{Stealth[length=2.5mm, width=1.8mm]}-{Stealth[length=2.5mm, width=1.8mm]}, line width=0.9pt, draw=blue!50!black}")
  table.insert(tex, "]")

  for i, id in ipairs(node_order) do
    local label_tex = escape_latex(nodes[id] or id)
    if i == 1 then
      table.insert(tex, string.format("  \\node[mnode] (%s) {%s};", id, label_tex))
    else
      local prev = node_order[i - 1]
      table.insert(tex, string.format("  \\node[mnode, right=of %s] (%s) {%s};", prev, id, label_tex))
    end
  end

  for _, e in ipairs(edges) do
    local style = (e.arrow:sub(1, 1) == "<") and "mbedge" or "medge"
    if e.label and e.label ~= "" then
      table.insert(tex, string.format("  \\draw[%s] (%s) -- node[above, font=\\scriptsize, inner sep=3pt] {%s} (%s);", style, e.from, escape_edge_label(e.label), e.to))
    else
      table.insert(tex, string.format("  \\draw[%s] (%s) -- (%s);", style, e.from, e.to))
    end
  end

  table.insert(tex, "\\end{tikzpicture}%")
  table.insert(tex, "}")
  table.insert(tex, "\\end{center}")

  return pandoc.RawBlock("latex", table.concat(tex, "\n"))
end
