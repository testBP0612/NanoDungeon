# WORK_PLAN — 工作計畫

> 在每一圈（iteration）**開始實作之前**先產生 / 更新本檔。它是 AI 在動手前的「思考留痕」，讓人類能在實作前看見並攔截方向錯誤。
>
> 用法：每圈開始時依下方模板填寫；完成後對應產出 `PROGRESS_REPORT.md`。歷史計畫可往下保留為紀錄（最新在最上方）。

---

## 模板（請複製使用）

```md
# Current State
<目前完成了什麼：已完成的 Phase / 任務卡 / 檔案，簡述現況>

# Current Phase
<目前所處 Phase，對照 ROADMAP.md>

# Recommended Task
<這一圈建議執行的任務卡或增量，例如 Codex/01_FIRST_PLAYABLE.md>

# Why
<為什麼是這一步：對照 ROADMAP 與 DoD 的差距、依賴關係>

# Risks
<可能的風險：物理穩定性、範圍蔓延、規格模糊等>

# Dependencies
<前置條件：需先完成的任務、需先決議的 OPEN_QUESTIONS 題號>

# Estimated Scope
<預估範圍大小：小 / 中 / 大；會動到哪些模組或場景>

# Validation Target
<本圈完成後要對照 VALIDATION_CHECKLIST.md 的哪個區塊 / 哪些項目>
```

---

## 當前工作計畫

# Current State
- MVP Phase 1 ~ 5 已完成並經人類驗收，Demo 可獨立匯出與展示。
- 目前彈珠場釘子位置仍寫死在 `Battle.gd._spawn_pegs()`，釘子半徑仍寫死在 `Peg.gd`，不利於後續可玩性調整。
- 新任務卡 `Codex/06_FIELD_LAYOUT.md` 已指定：把釘子位置與大小搬進 `Data/field.json`，Q-014 採「單一基礎佈局套用全部場次」。

# Current Phase
- **Post-MVP Playability Increment — Field Layout**。

# Recommended Task
- 執行 `Codex/06_FIELD_LAYOUT.md`。
- 新增 `Data/field.json`，沿用目前 8 顆 peg 的座標 / 類型作為行為等價起點，並支援每顆選填 radius。
- `DataLoader` 載入與驗證 field layout；`Battle.gd` 改讀資料生成 peg；`Peg.gd` 改為逐顆獨立 `CircleShape2D` 與繪製半徑。

# Why
- 佈局與半徑資料化後，人類可不改程式反覆調整可玩性。
- 逐顆 radius 是策略性布局的必要基礎，但不新增任何玩法機制或種類。
- 初版沿用現有座標，可保持行為等價並降低回歸風險。

# Risks
- `Peg.tscn` 的 `CircleShape2D` 是共用 sub-resource，若直接改 shape radius 會造成所有 peg 連動；必須在 `Peg.configure()` 為每顆 new 獨立 shape。
- `field.json` 驗證需在 pegs index 建好後執行，避免 id 驗證誤判。
- 移除寫死座標時要避免改變現有 8 顆初始布局與流程。

# Dependencies
- Q-014 採預設：單一基礎佈局套用全部場次；schema 可預留擴充，但本卡不實作每層變化。
- 不新增 Peg / Ball / Enemy / upgrade 種類，不改傷害 / 效果規則。

# Estimated Scope
- 中。新增 `Data/field.json`，修改 `Scripts/DataLoader.gd`、`Scripts/Battle.gd`、`Scripts/Peg.gd`，必要時調整 `Scenes/Peg.tscn` 的預設；更新 CHANGELOG / PROGRESS_REPORT / WORK_PLAN。

# Validation Target
- 對照 `Codex/06_FIELD_LAYOUT.md` DoD：位置 / 半徑全來自 `Data/field.json`、逐顆 radius 獨立、DataLoader 驗證、Godot 場景載入與 JSON parse 通過。
- 同步檢查禁止事項：不新增玩法 / 種類、不保留寫死 peg 座標 / 半徑、不使用共用 shape 套逐顆半徑。

---

## 歷史計畫 — Phase 1（已完成）

# Current State
- Phase 0（文件與資料結構）已完成：README / ROADMAP / OPEN_QUESTIONS / CHANGELOG、`Docs/01–05`、`Codex/00–04` + VALIDATION_CHECKLIST、`Data/` 四份 JSON 皆已建立。
- 已升級為 AI Loop Development Framework：`LOOP.md`、`WORK_PLAN.md`、`PROGRESS_REPORT.md` 皆存在。
- Godot 專案目前仍是空殼：尚未建立 `Scenes/`、`Scripts/`，`project.godot` 尚未指定主場景。

# Current Phase
- **Phase 1 — First Playable**。

# Recommended Task
- 執行 `Codex/01_FIRST_PLAYABLE.md`，建立最小可玩閉環：MainMenu → Battle → 讀取 JSON → 顯示玩家 HP / 敵人 HP / 回合傷害 → 瞄準發射 Normal Ball → 撞 Normal Peg 累積傷害 → 落底或 8 秒超時回收 → 全部球回收後一次結算 → 敵人未死亡則以 `enemies.json` 攻擊值反擊 → 玩家 / 敵人死亡基本判定。

# Why
- ROADMAP 顯示 Phase 1 是下一個未完成目標，DoD 要求主選單進戰鬥、發射、碰撞、落底、結算與可重複遊玩。
- 使用者本圈明確要求補足最小戰鬥閉環中的敵人反擊與玩家死亡判定；以基本扣血處理，不延伸到 Phase 3 的 5 場流程、Boss 行為或完整結算畫面。

# Risks
- 2D 物理穩定性（球穿透、卡住）需用落底 Area2D 與 8 秒超時保險處理（沿用 Q-006 暫行假設）。
- `project.godot` 目前未指定主場景；本圈需設定 `Scenes/MainMenu.tscn` 為 main scene，並在 `CHANGELOG.md` 留痕。
- 敵人反擊是最小閉環需求，但需避免擴張成 Phase 3 的完整敵人系統。
- 不做 Phase 2 的特效、音效、其他 Peg / Ball 效果，避免範圍蔓延。

# Dependencies
- 無阻斷性前置。
- 相關未決：Q-006 已允許以「底部全開 + 8 秒超時回收」暫行推進。

# Estimated Scope
- 中。新增 `Scenes/` 與 `Scripts/`：MainMenu、Battle、Peg、Ball、DataLoader、RunState；更新 `project.godot` main scene；更新 CHANGELOG / PROGRESS_REPORT。

# Validation Target
- `Codex/VALIDATION_CHECKLIST.md` 的 **C. First Playable 驗收** 全部項目。
- 同步檢查 **H. 禁止偏離項目**：不改核心設計文件、不改 ROADMAP、不新增 Phase 2+ 玩法、不寫死可調數值。
