# 任務卡 12 — ART CORE（核心美術：敵人 / 釘球底圖 / 背景 / logo / 外框）

> 美術 Pass 軌道。先讀 `Codex/00_MASTER_PROMPT.md`。
> 目標：用 Codex 內建生圖（GPT IMAGE-2）+ `agent-sprite-forge` 產出核心美術並接線，**全程保留程序化 / 空白 fallback**。
>
> 決策依據見 OPEN_QUESTIONS **Q-026**。升級 icon ×13 另見 `Codex/13_ART_UPGRADE_ICONS.md`（分開 session 做）。

---

## 鐵律
- **fallback 不可拆**：缺圖 / 生失敗時，沿用現有程序化畫法（釘/球/背景）或空白，遊戲照常跑、現場不開天窗。
- **只用靜態生圖**：`$generate2dsprite` 出單張；**不要動畫 sprite sheet、不要地圖 / prop pack**。
- **一致性**：所有資產共用下方「風格錨點」；每類別先生 1 張 base，其餘以它當 reference 生。
- **透明 PNG**、檔名對 id、置中、正方形（立繪）；Godot import：linear filter、關 mipmaps。
- 不改任何玩法 / 數值 / 規則；本卡純資產 + 接線。

## 風格錨點（所有 prompt 的固定前綴）
```
neon cyberpunk game asset, pure transparent background, glowing cyan and magenta
energy lines, geometric mechanical, data-interface aesthetic, high contrast,
flat vector-like, crisp clean edges, centered, single subject, no text, no watermark
```

## 設定 / 前置
- 安裝並確認 `agent-sprite-forge` skill 與其 Python 依賴（Python3 / Pillow / NumPy）可用；確認 `$generate2dsprite` 可出透明 PNG。
- 產物放 `assets/`（分子目錄），命名見下。

## 資產清單、prompt 與接線

### 1. 敵人立繪 ×5（`assets/enemies/<id>.png`，1024² 透明）
先生 **base = `core_program`**，其餘以它當 reference 維持一致。各 prompt = 風格錨點 + 下列主體：
- `core_program`（Boss base）：large symmetric dungeon-core entity, multiple glowing concentric rings, warning red + magenta, authoritative, imposing
- `virus_scout`：small agile reconnaissance virus drone, simple geometric body, glowing magenta
- `virus_crawler`：segmented self-replicating crawling virus, aggressive, pink/magenta
- `firewall_sentinel`（elite）：blocky armored firewall guardian, shield grid, orange-red
- `virus_swarm`：cluster of many tiny micro-virus units forming one swarm, magenta
- 接線：`Battle.tscn` 的 `EnemyPortrait` 由 ColorRect 改 `Sprite2D`/`TextureRect`，依 `enemy_def.id` 載 `assets/enemies/<id>.png`；**找不到檔則用現有純色占位**。維持現有受擊 flash / 抖動（modulate 仍可作用於 Sprite）。

### 2. 釘子底圖 ×1（`assets/pegs/peg_base.png`，透明，方形）
- prompt = 錨點 + `single glowing circular energy node token, neutral white/grey luminous core, soft outer glow, top-down, crisp`
- **中性白/灰階**——顏色仍由程式 `modulate` 依類型上（normal/burst/heal/double/bounce）。
- 接線：`Peg.gd` 繪製由「程式畫圓」改為貼 `peg_base.png`，**保留**依類型 `modulate` 上色、命中閃白、過載金色、以及**依 data-driven 半徑縮放**（sprite scale = radius / 底圖基準半徑）；缺圖則 fallback 回現有 `_draw()` 畫圓。

### 3. 球底圖 ×1（`assets/balls/ball_base.png`，透明，方形）
- prompt = 錨點 + `single glowing energy pulse orb, neutral white luminous core, soft glow, crisp`
- 中性，程式 `modulate` 依球種上色；拖尾粒子保留。
- 接線：`Ball.gd` 同上做法 + fallback 回現有畫圓。

### 4. 背景 ×2
- 主選單背景 `assets/bg/menu_bg.png`（1024²）：錨點 + `dark cyber space backdrop, subtle circuit grid, low brightness, cyan/magenta accents, clear central area for title`
- 戰鬥背景 `assets/bg/battle_bg.png`（1024²）：錨點 + `very dark cyber backdrop, faint data grid, minimal, low contrast`
- ⚠️ **戰鬥背景必須低亮度低對比**，不可蓋過釘海 / 降低球與釘的辨識度。接線時置於釘盤**最底層**、必要時壓低 alpha。
- 接線：`MainMenu` / `Battle` 的最底層 `TextureRect`；缺圖則維持現有純黑底。

### 5. 外框美化（`assets/ui/`）
- HP 條 / 過載槽 / power 表的賽博風框（建議可 9-slice 的細霓虹框 `bar_frame.png`，或各自一張）。
- prompt = 錨點 + `thin neon rectangular HUD frame, glowing cyan border, sci-fi data panel, hollow center`
- 接線：套在現有 ProgressBar / Label 外層；缺圖則維持現狀。

## logo（文字注意事項）
- 主選單標題 `assets/ui/logo.png`：錨點 + `emblem/sigil for a cyber pinball dungeon game, glowing geometric crest`。
- ⚠️ **AI 生圖的文字常不可靠**：建議生「圖徽 emblem」即可，**「NANO DUNGEON」字樣仍用引擎內 Label 繪製**疊在圖徽下，避免拼錯字。

## 不做範圍（嚴禁）
- ❌ 動畫 sprite sheet、地圖 / prop pack、升級 icon（升級 icon 屬 13 卡）。
- ❌ 不依賴圖才能跑（fallback 必留）；不改玩法 / 數值。
- ❌ 背景不得降低釘 / 球辨識度；不得破壞既有 tint / flash / overload 特效。
- ❌ 不得在 logo 圖內硬塞遊戲標題文字當唯一來源。

## 預期產出
- `assets/enemies/*.png`（5）、`assets/pegs/peg_base.png`、`assets/balls/ball_base.png`、`assets/bg/*.png`（2）、`assets/ui/bar_frame.png`、`assets/ui/logo.png`。
- 接線：`Peg.gd` / `Ball.gd` / `EnemyDisplay` / `MainMenu` / `Battle.tscn` 改貼圖 + fallback；Godot import 設定。
- 更新 `CHANGELOG.md`、產出 `PROGRESS_REPORT.md`。

## 驗收條件（DoD）
- [ ] 5 隻敵人立繪風格一致、透明乾淨、依 id 正確顯示；受擊 flash/抖動仍有效。
- [ ] 釘 / 球改用底圖 + 程式上色；類型色、命中閃白、過載金色、半徑縮放**全部仍正確**。
- [ ] 背景顯示但**不影響釘/球辨識度**；主選單 logo 圖徽 + 引擎文字標題正常。
- [ ] HP/過載/power 外框美化套用且不遮資訊。
- [ ] **任一圖缺失皆 fallback、遊戲不崩**；export（1024×1024）後正常、不掉幀。
- [ ] 未改玩法 / 數值；一整局仍可穩定跑完；Godot 載入無錯、`Data/*.json` 可解析。

## 完成後
- 依 DoD 自驗、更新 `CHANGELOG.md`、產出 `PROGRESS_REPORT.md`，並提醒人類實機驗收風格一致性與背景對比。下一張：`Codex/13_ART_UPGRADE_ICONS.md`。
