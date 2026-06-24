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
- Phase 1 ~ 16 已完成，卡 16 已完成回合橫幅節奏與球命中 squash / 小幅彈跳手感調整。
- `OPEN_QUESTIONS.md` Q-031 已由人類決議採 A：發射控制改為只控方向、固定速度、一鍵發射；`Docs/02_GAME_DESIGN.md` 已同步寫入固定 `launch_speed` 與不控制力道。
- 目前遊戲仍殘留卡 8/9 的兩段式集氣發射流程、power UI 與 charge 表現接線；本圈需忠實移除，不復活力道軸。

# Current Phase
- **Phase 17 — Launch Control Direction Only（只控方向）**。

# Recommended Task
- 執行 `Codex/17_LAUNCH_CONTROL_DIRECTION_ONLY.md`。
- 將 `Scripts/Battle.gd` 發射輸入改為滑鼠 / 方向瞄準後，左鍵或空白鍵單次即用 `Data/player.json.launch_speed` 發射。
- 移除 / 中性化集氣狀態、power UI、charge SFX 與力道綁定視覺；保留並強化瞄準軌跡與發射瞬間回饋。
- 將 `Data/player.json` 舊集氣欄位標記 deprecated；將相關 feel 參數資料化且可回退。

# Why
- Q-031 指出集氣 timing 與角度規劃互相干擾；移除力道軸後，玩家唯一技巧軸是「算好角度」。
- 固定速度一鍵發射讓控制更可讀，也讓瞄準軌跡承擔主要決策資訊，因此 aim preview 需要更清楚、即時且漂亮。
- 本卡是已決議的核心方向落地，不涉及平衡 / 物理 / 敵人 / 升級規則調整。

# Risks
- 若只移除集氣而未調整 UI，玩家可能仍以為可控制力道；必須清掉或改名所有 power/charge 文案與顯示。
- 發射速度必須讀 `player.json.launch_speed`，不得把 900 寫進程式。
- 瞄準預覽若做太重可能影響效能；只用現有 Line2D / Polygon2D 與 feel 參數強化。
- 不得碰卡 16 的彈跳物理參數，不改 damage / HP / balls / enemies / upgrade 抽取。

# Dependencies
- Q-031 已決議，且 `Docs/02_GAME_DESIGN.md` 已套用。無阻斷性未決問題。
- Q-028 / Q-029 / Q-030 / Q-032 仍為暫行假設，但本圈不擴張其決策範圍。

# Estimated Scope
- 中。修改 `Scripts/Battle.gd`、`Scripts/BattleFX.gd`、`Scenes/Battle.tscn`、`Data/player.json`、`Data/feel.json`、`Scripts/DataLoader.gd`，並更新 `CHANGELOG.md`、`PROGRESS_REPORT.md`、`WORK_PLAN.md`。

# Validation Target
- 對照 `Codex/17_LAUNCH_CONTROL_DIRECTION_ONLY.md` DoD：瞄準方向 + 單鍵、固定 `launch_speed`、無集氣條 / timing、無誤導力道 UI、deprecated 欄位保留、JSON / Godot / export 通過。
- 同步檢查 `VALIDATION_CHECKLIST.md` D/G/H：發射回饋、Demo 穩定、未改核心方向 / 非目標 / 平衡 / 物理。

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
