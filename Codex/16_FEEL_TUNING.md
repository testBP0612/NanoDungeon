# 任務卡 16 — FEEL TUNING（回合節奏 + 彈跳手感微調）

> 打磨軌道。先讀 `Codex/00_MASTER_PROMPT.md`。
> 來源：`Reviews/01_GAME_FEEL_REVIEW.md` 後的實機回饋；決策見 `OPEN_QUESTIONS.md` Q-032。
> 目標：(1) 放慢回合切換橫幅（寶可夢式回合切換感）；(2) 在**不大幅改平衡**前提下，讓撞釘彈跳更輕盈、更脆。
>
> 排程：卡 15 之後。**只做這兩項，不碰控制方式（屬卡 17）、不做 Review P1/P2。**

---

## 核心紀律

- **① 純表現**：回合橫幅停留時間只動 `Data/feel.json`，零玩法影響。
- **② 牽動平衡，須謹慎**：彈跳物理屬「偽裝成手感的平衡調整」。依 Q-032 決議 **採 C**——以視覺 squash 補足爽感、物理只**小幅**調，並**實機前後對照同一局難度**。任何物理改動須資料化、可回退。
- **資料化**：所有數值進 `Data/feel.json` / `Data/player.json` / `Data/field.json`，程式不得寫死。
- **穩定優先**：squash 不得影響碰撞形狀（只動視覺 scale，不動 `CollisionShape2D`）；一整局須穩定跑完。

## 任務範圍（要做）

### ① 回合切換橫幅放慢（寶可夢感）
- `Data/feel.json` → `turn_pacing.banner_duration` 由 `0.92` 調至約 `2.6`（停留約三倍），數值資料化、可再調。
- 視需要連帶微放 `turn_pacing.enemy_turn_pre_delay` / `check_delay`，讓「你的回合 / 敵人回合」之間有呼吸感，**不得**讓整局節奏拖沓到無法在 5–10 分鐘跑完。
- 不改 `show_turn_banner` 的淡入淡出邏輯，只調停留秒數。

### ② 彈跳手感（Q-032 採 C：小幅物理 + 視覺 squash）
- **視覺 squash-stretch**：球命中釘子瞬間做一個短暫 squash→stretch→回正（只動 `Ball` 的繪製 / sprite `scale`，**不動碰撞形狀、不動 `linear_velocity`**）。參數（強度、時長）進 `Data/feel.json`（可放 `scene_fx` 或新增 `ball_squash` 小段）。
- **小幅物理微調**（全在既有 schema 內調值，須實機驗收難度）：
  - `Data/player.json` `ball_gravity_scale` `1.0` → 略降（如 `0.9`）使更輕盈；
  - `ball_bounce` `0.9` → 略升（如 `0.94`）；
  - `peg_bounce_boost` `1.15` → 略升（如 `1.2`）。
  - **幅度保守**：以「明顯更彈但不致一局難度翻盤」為界；若實機發現命中數 / 傷害顯著偏移，回調。
- 先確認卡 15 的 **hitstop** 已讓彈跳知覺提升，再決定物理要動多少——可能只需很小幅度。

## 不做範圍（嚴禁）

- ❌ 不碰發射控制方式（力道 / 方向 / 集氣）——屬卡 17。
- ❌ 不做 Review 的 P1 / P2（敵人飛行反應、結算因果、Boss 舞台、降基線噪音等）。
- ❌ squash 不得改 `CollisionShape2D` 或直接改 `linear_velocity`（那會變成改物理 / 平衡）。
- ❌ 不寫死數值；不大幅改物理導致難度失控。

## 預期產出

- `Data/feel.json`：`turn_pacing` 調整、`ball_squash`（或 `scene_fx`）新增 squash 參數。
- `Data/player.json`：`ball_gravity_scale` / `ball_bounce` / `peg_bounce_boost` 小幅調值。
- `Scripts/Ball.gd`：命中時的視覺 squash（只動 scale）。
- 更新 `CHANGELOG.md`、`PROGRESS_REPORT.md`、`WORK_PLAN.md`。

## 驗收條件（DoD）

- [ ] 回合切換橫幅停留明顯變長（~3x），且整局仍可在合理時間跑完、狀態機不卡。
- [ ] 撞釘有可見 squash-stretch；視覺更脆、更輕盈。
- [ ] 物理微調後一整局（5 場 + 4 升級）仍可穩定跑完；**實機確認難度未明顯失控**（命中數 / 傷害無暴走）。
- [ ] 所有新 / 改數值來自 `Data/*.json`；squash 未動碰撞形狀、未直接改速度。
- [ ] Godot 載入無錯、`Data/*.json` 解析通過。

## 禁止事項

- ❌ 不得碰控制方式、不得做 P1/P2。
- ❌ 不得以 squash 之名改物理速度 / 碰撞。
- ❌ 不得大幅改平衡；如需更大物理改動，先回 `OPEN_QUESTIONS.md`（Q-032）升級提案。

## 完成後

- 依 DoD 自驗、更新 `CHANGELOG.md`、產出 `PROGRESS_REPORT.md`。
- 回報：① 的最終秒數、② 的最終物理數值與 squash 參數、**實機難度對照結論**、建議下一張卡。
- 提醒人類：② 是平衡敏感項，務必實機驗收；可只調 `Data/*.json` 微調。
