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
- Phase 6 已將 peg 位置 / 半徑資料化到 `Data/field.json`。
- 新任務卡 `Codex/07_PROCEDURAL_PEGBOARD.md` 已指定：field 改參數化 generator + bottom_row、每回合重抽類型、新增底排 bounce_peg、場地拉高至 1024×1024。

# Current Phase
- **Post-MVP Playability Increment — Procedural Pegboard**。

# Recommended Task
- 執行 `Codex/07_PROCEDURAL_PEGBOARD.md`。
- 將 `Data/field.json` 改為 `generator + bottom_row`，新增 `FieldGenerator.gd` 算骨架與抽類型。
- `Battle.gd` 在 ROUND_START 重抽動態 peg 類型，位置骨架固定；底排 `bounce_peg` 固定存在。
- 調整 1024×1024 viewport / Battle 場地 / UI / export preset。

# Why
- Q-015 / Q-016 / Q-017 已決議，下一個可玩性目標是柏青哥式程序釘盤與每回合重組。
- 參數化骨架比手列座標更適合反覆調整密度、高度與權重。
- 場地加高到 1024×1024 是容納更多釘排與底部 bounce row 的前置。

# Risks
- 每回合重抽類型會影響輸出波動，需要確保底排 bounce 與 8 秒 timeout 保持穩定。
- 新增 `bounce_peg` 是已決議的第 5 種 peg，但不可順手新增其他種類或效果。
- 1024×1024 調整涉及場景座標、camera、UI 和 export，需 headless/export 回歸。

# Dependencies
- Q-015：程序生成骨架，每回合只重抽類型，位置固定，seed 可選。
- Q-016：新增 `bounce_peg`，只用底排，不進隨機池。
- Q-017：viewport / 場地加高至 1024×1024。

# Estimated Scope
- 大。會修改 `Data/field.json`、`Data/pegs.json`、`Scripts/DataLoader.gd`、`Scripts/Battle.gd`、`Scripts/EffectResolver.gd`、新增 `Scripts/FieldGenerator.gd`，調整 `project.godot`、`Scenes/Battle.tscn`、`export_presets.cfg`，更新 CHANGELOG / PROGRESS_REPORT / WORK_PLAN。

# Validation Target
- 對照 `Codex/07_PROCEDURAL_PEGBOARD.md` DoD：公式生成骨架、ROUND_START 類型重抽、底排 bounce 固定、bounce 無效果、1024×1024 場地、seed 支援、Godot / JSON / export 驗證。
- 同步檢查禁止事項：不做漸變特效、不擾動位置骨架、不把 bounce 放進隨機池、不加其他種類、不改既有規則。

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
