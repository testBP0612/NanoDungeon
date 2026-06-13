# 任務卡 03 — ENEMY SYSTEM（敵人與回合制戰鬥）

> Phase 3。先讀 `Codex/00_MASTER_PROMPT.md`。目標：**完成完整回合制戰鬥與 5 場敵人流程**，含敵人攻擊、HP UI、勝敗判定與結算畫面。

---

## Phase 2 Review 併入前置（必做，先於敵人系統或併行）

來自 Phase 2 Architecture Review 的已決議事項，併入本圈處理（人類已決議，見 OPEN_QUESTIONS）：

1. **抽出 Presentation / BattleFX 模組**（控制 `Battle.gd` 體積）：把命中粒子、拖尾、screen shake、浮動傷害數字、SFX 從 `Battle.gd` 抽成獨立模組，由 `Battle.gd` 呼叫。**行為等價**，不改視覺 / 手感結果。
2. **feel 數值資料化**（Q-011）：新增 `Data/feel.json`，將 shake 強度 / 時長、粒子數量 / 壽命、拖尾參數、浮動文字時長、SFX 頻率、peg re-hit cooldown 等常數移入，程式改為讀取，不再 hardcode。`DataLoader` 比照其他 JSON 載入 / 驗證。
3. **Peg 再命中冷卻**（Q-010）：實作 per-peg re-hit cooldown（預設 0.2 秒，讀自 `feel.json`），同一顆球冷卻內的重複接觸不計分；不同球或冷卻後命中仍計分。倍傷釘維持既有 `max_triggers_per_round` 限制。
4. **移除 Phase 2 測試球序列的副作用**：`phase2_test_ball_sequence` 屬 Phase 2 測試用；本圈做敵人系統時，球種來源應改回依 `RunState.unlocked_balls`（Phase 4 才接升級解鎖）。若本圈尚未接升級，至少確保預設只發 Normal Ball，不要讓測試序列影響正式戰鬥節奏（如需保留測試序列，改為可關閉的 debug flag）。

> 註：Blast 球落底加成「可隨球數疊加」、Shield 不疊加（Q-012 / Q-003）已是既定規則，本圈不需改動，僅在 Phase 4 解鎖時遵循。

## 任務範圍（要做）

### 敵人資料讀取
- 從 `enemies.json` 讀取 5 場敵人（順序：普通 / 普通 / 精英 / 普通 / Boss）。
- 依 `RunState.current_battle_index` 載入當前敵人的 `name / type / hp / attack / description / dialogue`。
- 敵人立繪 / 占位圖以 `id` 對應（無圖則用純色 + 標籤占位，見 `05_ART_DIRECTION.md`）。

### 回合流程（完整 FSM）
依 `03_SYSTEM_SPEC.md` 的狀態機：
```txt
INIT → ROUND_START → AIMING → LAUNCHED → SETTLE → ENEMY_TURN → CHECK → (ROUND_START | REWARD | GAME_OVER | VICTORY)
```
- 結算後若敵人存活 → 進入 ENEMY_TURN。
- CHECK 分流：玩家死 → GAME_OVER；敵人死且為 Boss → VICTORY；敵人死非 Boss → 進入下一場（Phase 4 接升級，本卡先做「下一場」切換，升級畫面可先占位）。

### 敵人攻擊
- 普通怪 / 精英怪：每個敵人回合對玩家造成 `attack` 點傷害。
- Boss：普通攻擊為 `attack`；每固定回合數（見 `04_BALANCE_RULES.md`，暫定每 3 回合）施放一次強攻擊 / 必殺（較高傷害）。
- 敵人攻擊須套用本回合 Shield Ball 減免（與 Phase 2 的 `damage_reduction` 串接，遵守 Q-003）。
- 攻擊有可見回饋（敵人攻擊動作 / 玩家受擊閃紅 + 螢幕震動）。

### HP UI
- 玩家 HP 條（含數值）。
- 敵人 HP 條（含數值、敵人名稱、場次指示如「3 / 5」）。
- 回合數、本回合傷害累計顯示。
- HP 變化用 Tween 平滑過渡，受擊有明顯提示。

### 勝敗判定
- 玩家 HP ≤ 0 → 切 `GameOver.tscn`（死亡結算）。
- 擊敗第 5 場 Boss → 切 `Victory.tscn`（勝利結算）。
- 結算畫面內容：
  - 死亡結算：到達場次 / 層數、擊殺數、（若有）當前 build 摘要、重新開始 / 回主選單。
  - 勝利結算：用時、剩餘 HP、最終 build 摘要、重新開始 / 回主選單。

## 不做範圍

- 升級三選一的「選項生成與套用」→ Phase 4（本卡敵人死後先做場次推進，升級畫面可占位）。
- 美術定稿、敵人逐幀動畫 → Phase 5（占位即可）。

## 預期產出

- `Battle.tscn` 完整 FSM 與敵人攻擊邏輯。
- `EnemyDisplay` 元件（讀 enemy 定義、顯示立繪 / 占位、HP、dialogue）。
- `GameOver.tscn`、`Victory.tscn`（含結算資訊與導航）。
- 玩家 / 敵人 HP UI 元件。
- 場次推進邏輯（5 場依序，Boss 為最後）。
- 更新後的 `CHANGELOG.md`。

## 驗收條件（DoD）

- [ ] （前置）表現層已抽成 BattleFX 模組，`Battle.gd` 不再 inline 粒子 / shake / 跳字 / SFX，且行為等價。
- [ ] （前置）`Data/feel.json` 已建立，feel 常數改由其驅動，程式無對應 hardcode。
- [ ] （前置）Peg re-hit cooldown 生效，卡釘無法 farming；正常彈跳命中仍計分。
- [ ] （前置）正式戰鬥不再受 `phase2_test_ball_sequence` 影響（預設只發 Normal Ball 或依 unlocked_balls）。
- [ ] 5 場敵人能依序載入，數值取自 `enemies.json`。
- [ ] 完整回合流程可循環：發射 → 結算 → 敵人攻擊 → 下一回合。
- [ ] 敵人存活時會攻擊玩家、扣 HP，且 Shield 減免生效。
- [ ] Boss 會在指定回合施放強攻擊。
- [ ] 玩家 / 敵人 HP UI 正確顯示並隨數值更新。
- [ ] 玩家 HP ≤ 0 出現死亡結算；擊敗 Boss 出現勝利結算。
- [ ] 結算畫面可重新開始或回主選單，且重來後狀態乾淨。
- [ ] 可從第 1 場一路打到第 5 場（即使升級先占位）不崩潰。
- [ ] 所有數值來自 `Data/*.json`。

## 禁止事項

- ❌ 不得改動敵人場數（固定 5 場）或類型定義。
- ❌ 不得把敵人 HP / 攻擊 / Boss 必殺數值寫死。
- ❌ 不得在本卡實作升級套用邏輯（避免與 Phase 4 衝突，僅可占位）。
- ❌ 不得讓敵人攻擊繞過 Shield 減免機制。
- ❌ 規格未明處（如 Boss 必殺週期、精英怪獎勵，見 Q-005）→ 採暫行假設並記錄，不擅自定方向。
