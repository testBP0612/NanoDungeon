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
- MVP Phase 1 ~ 5 已完成，Phase 6 佈局資料化、Phase 7 程序釘盤、Phase 8 集氣發射 / bumper / double_peg 保底、Phase 9 Game Feel、Phase 10 Overclock 皆已落地。
- 目前已有 `Data/feel.json`、`Scripts/BattleFX.gd`、settlement count-up、Overclock 倍率與底排 bumper，可作為 Phase 11 三項手感增量接點。
- Q-023 / Q-024 / Q-025 已決議：回合內累積傷害達標即斬殺、結算 / 斬殺時播放玩家攻擊演繹、一般釘彈跳 boost 並資料化。

# Current Phase
- **Phase 11 — PLAYER ATTACK & BOUNCE（斬殺、玩家攻擊演繹、彈跳手感）**。

# Recommended Task
- 執行 `Codex/11_PLAYER_ATTACK_AND_BOUNCE.md`。
- 新增 `Data/player.json` 的 `execute`、`peg_bounce_boost`、共用 `max_ball_speed`，以及 `Data/feel.json` 的 `overkill_cutin` / `player_attack`。
- 擴充 `Battle.gd`、`BattleFX.gd`、`Ball.gd`、`DataLoader.gd`，接入提前斬殺、玩家攻擊演出與一般釘彈跳 boost。

# Why
- ROADMAP 已將 Phase 11 排在 Phase 10 之後，目標是縮短達標後的等待時間，補足玩家輸出視覺重量，並強化一般釘反彈手感。
- Q-023 / Q-024 / Q-025 已決議且無阻斷問題，任務卡明確要求全資料化、純程序化、不新增種類、不改傷害公式。
- 既有 BattleFX、count-up、Overclock 與 bumper 架構已能小步接入，不需重寫核心戰鬥流程。

# Risks
- 斬殺若與球回收 signal / SETTLE 同時觸發，可能造成重複結算；需加明確 execution guard。
- 玩家攻擊演出需與 settlement count-up 對齊，避免卡住 FSM 或讓敵人受擊回饋重複太多。
- 一般釘 boost 改變物理速度，必須夾 `max_ball_speed` 並保留底排 bumper 獨立倍率。
- 用詞需避開任務卡禁用術語，畫面文字維持賽博化。

# Dependencies
- Q-023 / Q-024 / Q-025 已決議，無阻斷性未決問題。

# Estimated Scope
- 中。會修改 `Data/player.json`、`Data/feel.json`、`Scripts/DataLoader.gd`、`Scripts/Battle.gd`、`Scripts/BattleFX.gd`、`Scripts/Ball.gd`，並更新 CHANGELOG / PROGRESS_REPORT / WORK_PLAN。

# Validation Target
- 對照 `Codex/11_PLAYER_ATTACK_AND_BOUNCE.md` DoD：達標立即斬殺、場上球清除、OVERKILL cut-in、玩家攻擊匯聚→射出→命中、強度隨傷害、一般釘 boost、底排 bumper 不疊加、全參數資料化、可關閉。
- 同步檢查 `VALIDATION_CHECKLIST.md` 的 G/H：Demo 展示穩定性與禁止偏離項目。

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
