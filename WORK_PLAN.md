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
- Phase 7 已完成程序生成釘盤、每回合重抽動態釘類型、底排 `bounce_peg` 與 1024×1024 場地，並經人類實機驗收。
- 新任務卡 `Codex/08_LAUNCH_AND_TUNING.md` 已指定：底排 bumper 主動加速、兩段式集氣發射 + 拋物線瞄準、double_peg 每回合保底與對應升級。

# Current Phase
- **Post-MVP Playability Increment — Launch & Tuning**。

# Recommended Task
- 執行 `Codex/08_LAUNCH_AND_TUNING.md`。
- `bounce_peg` 命中時依 `field.json` 的 `bottom_row.bounce_multiplier` 主動放大速度，並以 `max_ball_speed` 夾住。
- 將 AIMING 輸入改為左鍵 / 空白鍵第一下集氣、第二下依 power 發射；AimLine 改為拋物線預覽，power 表 UI 可見。
- 在 `FieldGenerator` 加入 `guaranteed_double_peg_count` 保底抽取，並新增 `up_guaranteed_double` 讓 RunState 整局提升保底數。

# Why
- Q-018 / Q-019 / Q-020 已決議，Phase 8 的目標是補足發射策略、底部反彈手感與倍傷釘可預期性。
- 這些都是可玩性調校，不應改動既有傷害公式、敵人規則、釘 / 球種類或位置骨架。
- 新數值必須 JSON 化，讓後續只調資料即可微調手感。

# Risks
- 主動 bumper 若速度過高可能造成穿透、飛出或 timeout 變多，需保留 CCD 並夾 `max_ball_speed`。
- 兩段式輸入可能和舊「點一下發射」衝突，需確保未集氣不誤射、飛行中輸入無效。
- double 保底會提高輸出波動與強度，需設上限並讓升級在達上限後排除。

# Dependencies
- Q-018：底排 `bounce_peg` 改主動 bumper，倍率與速度上限資料化。
- Q-019：集氣發射、拋物線瞄準、power 表與發射速度資料化。
- Q-020：`double_peg` 每回合保底數量與升級增加已決議。

# Estimated Scope
- 大。會修改 `Data/field.json`、`Data/player.json`、`Data/upgrades.json`、`Scripts/DataLoader.gd`、`Scripts/Battle.gd`、`Scripts/Ball.gd`、`Scripts/FieldGenerator.gd`、`Scripts/RunState.gd`、`Scripts/UpgradeResolver.gd`、`Scenes/Battle.tscn`，更新 CHANGELOG / PROGRESS_REPORT / WORK_PLAN。

# Validation Target
- 對照 `Codex/08_LAUNCH_AND_TUNING.md` DoD：bumper 加速與上限、集氣表與兩段式輸入、拋物線預覽、power 影響初速、double_peg 保底與升級、JSON 驗證、Godot headless / export 驗證。
- 同步檢查禁止事項：不新增種類、不改傷害 / 敵人 / 既有升級規則、不擾動位置骨架、不把數值寫死。

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
