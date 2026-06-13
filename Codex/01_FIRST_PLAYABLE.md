# 任務卡 01 — FIRST PLAYABLE（最小可玩）

> Phase 1。先讀 `Codex/00_MASTER_PROMPT.md`。目標：**讓遊戲跑起來**，能發射球、撞釘、結算傷害給一個敵人。**醜沒關係，會跑最重要。**

---

## 任務範圍（要做）

1. **主選單 MainMenu.tscn**：標題 + 「開始」「離開」按鈕；按開始進入戰鬥。
2. **戰鬥場景 Battle.tscn**：含彈珠場（邊界牆、底部偵測）、釘子、發射器、單一敵人顯示、基本 UI。
3. **彈珠物理**：一種球（Normal Ball，`RigidBody2D`），可瞄準方向、發射、受重力、撞牆與釘子彈跳、落底回收。
4. **釘子（先只做 Normal Peg）**：在場上佈置一批普通釘，球命中時累積傷害到「回合傷害累計器」。
5. **回合與結算**：每回合給 N 顆球（讀 `balls_per_round`），逐顆發射；全部落底（含超時回收）後，一次把累計傷害套用到敵人 HP。
6. **單一假敵人**：讀 `enemies.json` 第 1 場的 HP，被結算傷害扣血；HP ≤ 0 顯示一個簡單「勝利 / 結束」提示即可（完整結算畫面留待 Phase 3）。
7. **資料驅動**：球數、Normal Peg 傷害、敵人 HP 從 `Data/*.json` 讀取，不寫死。
8. **落底保險**：球超過 N 秒（暫定 8 秒，見 Q-006）未落底則強制回收。

## 不做範圍（這張不碰）

- 其他 3 種釘子（Burst / Heal / Double）→ Phase 2。
- 其他 2 種球（Blast / Shield）→ Phase 2。
- 完整回合制敵人攻擊、5 場流程、HP UI 細節 → Phase 3。
- 升級三選一 → Phase 4。
- 命中特效、傷害數字、音效、螢幕震動、glow 美術 → Phase 2 / 5。
- 完整死亡 / 勝利結算畫面 → Phase 3。

## 預期產出

- `MainMenu.tscn`（+ 對應腳本）。
- `Battle.tscn`（+ 戰鬥狀態機腳本，最小狀態：ROUND_START → AIMING → LAUNCHED → SETTLE → CHECK）。
- `Peg.tscn`（Normal Peg）、`Ball.tscn`（Normal Ball）可重用場景。
- Data Loader（讀取並驗證 `Data/*.json`，至少支援 pegs / balls / enemies 的必要欄位）。
- `RunState`（持有 `balls_per_round`、敵人索引、玩家 HP 等，可為 autoload）。
- 更新後的 `CHANGELOG.md`。

## 驗收條件（DoD）

- [ ] 從主選單按「開始」能進入戰鬥場景，不報錯。
- [ ] 戰鬥開始時依 `balls_per_round` 給出正確球數。
- [ ] 玩家能瞄準並逐顆發射球。
- [ ] 球會與牆、釘子碰撞彈跳，並受重力落底。
- [ ] 命中 Normal Peg 會累積傷害（數值取自 `pegs.json`）。
- [ ] 所有球落底（或超時）後觸發一次結算，敵人 HP 下降對應總傷害。
- [ ] 敵人 HP ≤ 0 時出現簡單結束提示，且可回到主選單 / 重來。
- [ ] 球不會永久卡住（超時回收生效）。
- [ ] 連續玩 3 回合不崩潰、狀態不殘留。
- [ ] 所有用到的數值皆來自 `Data/*.json`，原始碼中無對應魔術數字。

## 禁止事項

- ❌ 不得實作不在「任務範圍」內的 Peg / Ball / 敵人機制。
- ❌ 不得把球數 / 傷害 / HP 寫死在程式裡。
- ❌ 不得為了好看而加特效拖累進度（這張只求會跑）。
- ❌ 不得一次重寫或重構未要求的部分。
- ❌ 遇到規格未明（如落底判定細節）不得擅自定方向 → 採暫行假設並記錄於 `OPEN_QUESTIONS.md`。
- ❌ 不得引入存檔、登入、Web Export、3D 等非目標內容。
