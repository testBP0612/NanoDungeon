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
- MVP Phase 1 ~ 5 已完成，Phase 6 佈局資料化、Phase 7 程序釘盤、Phase 8 集氣發射 / bumper / double_peg 保底皆已落地。
- 目前已存在 `Data/feel.json`、`Scripts/BattleFX.gd` 與基本 hit / launch / SFX 回饋，可作為 Phase 9 Game Feel 的表現層接點。
- Q-021 已決議：Game Feel 打磨限於純表現，不改玩法數值、傷害公式、敵人規則、抽取或種類。

# Current Phase
- **Phase 9 — Game Feel（轉場、回合節奏與反饋打磨）**。

# Recommended Task
- 執行 `Codex/09_GAME_FEEL.md`。
- 新增共用場景淡入淡出 helper，替換 MainMenu / Battle / UpgradeScreen / GameOver / Victory 的硬切。
- 擴充 `feel.json` 與 `BattleFX`：回合 banner、敵人三拍、Boss special telegraph、受擊 / 低血 / combo / miss / charge / settlement count-up / reroll flash / upgrade card juice。
- 在 `Battle.gd` 只接入表現節奏與 await beat，不改傷害、HP、球池、敵人與升級規則。

# Why
- ROADMAP 指出美術 Pass 前需完成 Phase 9 Game Feel，補齊純色 placeholder 上的成品感。
- 目前回合結算、敵人攻擊與下一回合切換過快，且 scene change 仍硬切，與任務卡 DoD 有明顯差距。
- 所有新增節奏 / 強度 / 開關放入 `Data/feel.json`，後續可只調資料微調體感。

# Risks
- async 回合節奏若接錯可能卡住 FSM；需保持每段 beat 可完成且不依賴 SFX。
- 表現層容易侵入規則層；需把新邏輯集中於 `BattleFX` / UI / Peg feedback，`Battle.gd` 只負責呼叫與等待。
- combo / miss / charge 必須純表現，不能改變傷害、power 映射或球回收規則。

# Dependencies
- Q-021 已決議，無阻斷性未決問題。

# Estimated Scope
- 大。會修改 `Data/feel.json`、`Scripts/DataLoader.gd`、`Scripts/BattleFX.gd`、`Scripts/Battle.gd`、`Scripts/Ball.gd`、`Scripts/Peg.gd`、`Scripts/UpgradeScreen.gd`、各畫面切場腳本、`project.godot` autoload，更新 CHANGELOG / PROGRESS_REPORT / WORK_PLAN。

# Validation Target
- 對照 `Codex/09_GAME_FEEL.md` DoD：淡入淡出、回合 beats、敵攻三拍、Boss telegraph、受擊 / HP / count-up、combo、低血、漏球、集氣、升級卡、重組快閃。
- 同步檢查 `VALIDATION_CHECKLIST.md` 的 G/H：Demo 展示相關穩定性與禁止偏離項目。

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
