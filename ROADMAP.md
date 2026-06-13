# ROADMAP — 奈米地下城 Nano Dungeon

開發採**分階段、可驗收**推進。每個 Phase 都有明確的「完成定義（Definition of Done, DoD）」，未達 DoD 不進下一階段。對應任務卡見 `Codex/`，驗收見 `Codex/VALIDATION_CHECKLIST.md`。

| Phase | 名稱 | 任務卡 | 狀態 |
| --- | --- | --- | --- |
| 0 | 文件與資料結構 | （本批文件） | ✅ 完成 |
| 1 | First Playable | `Codex/01_FIRST_PLAYABLE.md` | ✅ 完成（人類實機驗證） |
| 1.5 | Architecture Refactor | `Codex/01b_REFACTOR.md` | ✅ 完成（人類實機驗證行為等價） |
| 2 | Pinball Feel | `Codex/02_PINBALL_FEEL.md` | ✅ 完成（人類實機驗證） |
| 3 | Enemy System | `Codex/03_ENEMY_SYSTEM.md` | ✅ 完成（人類實機驗證） |
| 4 | Roguelite Build | `Codex/04_ROGUELITE_BUILD.md` | ✅ 完成（人類實機驗證） |
| 5 | Polish & Demo | `Codex/05_POLISH_DEMO.md` | ⬜ 待開始（MVP 功能已齊） |

---

## Phase 0 — 文件與資料結構

**目標**：建立規格與資料底座，讓 AI 能可控接手。

工作項：
- README / ROADMAP / OPEN_QUESTIONS / CHANGELOG。
- `Docs/` 5 份設計文件。
- `Codex/` 總控提示 + 4 張任務卡 + 驗收清單。
- `Data/` 4 份 JSON 初版假資料。

**完成定義（DoD）**：
- 所有列出的 Markdown 與 JSON 檔案存在且有實質內容。
- JSON 可被解析（合法格式），欄位齊全。
- 任一 AI 讀完 `Codex/00_MASTER_PROMPT.md` + `Docs/` 後，能在不問人類的情況下開始 Phase 1。

## Phase 1 — First Playable

**目標**：最小可玩。能發射一顆球、撞到釘子、結算傷害給一個假敵人。

工作項：
- 主選單 → 戰鬥場景的最小流程。
- 一種球（普通球）可瞄準、發射、受重力落底。
- 釘子可被命中並累積傷害（先只做普通釘）。
- 球全部落底後結算總傷害給單一敵人。
- 從 `Data/` 讀取基本數值（不寫死）。

**完成定義（DoD）**：
- 能從主選單進入戰鬥並發射球。
- 球會碰撞釘子、落底、觸發一次結算。
- 敵人 HP 會因結算而下降。
- 全程不崩潰，可重複進行。

## Phase 1.5 — Architecture Refactor

**目標**：在**不改變任何遊戲行為**的前提下，清理 Phase 1 累積的架構債，為 Phase 2 鋪路。由 Phase 1.5 Architecture Review 觸發，任務卡見 `Codex/01b_REFACTOR.md`。

工作項：
- 抽出 Effect Resolver（集中 `effect_type` 分派，目前僅 `damage`）。
- 建立 `RoundContext`（集中回合暫存，並預留 Phase 2 欄位）。
- 統一 FSM 入口（所有切換走 `_transition_to`）。
- 場景 / 程式分離（彈珠場與 UI 改為 `Battle.tscn` 實際節點；若人類選擇維持程式化生成，則改為在 SPEC 提案記錄為慣例）。
- 清除殘渣（`node_2d.tscn`）。

**完成定義（DoD）**：
- **行為等價**：重構前後遊戲可見行為完全相同，C 區驗收逐項回歸通過。
- 傷害邏輯只存在於 Effect Resolver；回合暫存集中於 RoundContext；無散落 `state = ...`。
- 數值、座標、UI 版面、物理參數皆未變。
- 專案可正常載入與遊玩，無載入錯誤。

## Phase 2 — Pinball Feel

**目標**：把「能動」變成「好玩」。強化彈珠手感與回饋。

工作項：
- 發射感（瞄準線、力度、發射動畫）。
- 碰撞回饋（彈跳、螢幕微震、命中閃光）。
- 命中特效（粒子 / glow）。
- 傷害數字跳出。
- 音效占位（placeholder SFX）。
- 4 種釘子全部生效（普通 / 爆裂 / 補血 / 倍傷）。
- 3 種球全部生效（普通 / 爆破 / 護盾）。

**完成定義（DoD）**：
- 發射、命中、結算都有可見 / 可聽回饋。
- 4 種釘子、3 種球的效果可在遊戲中觀察到。
- 維持穩定幀率，無物理卡死。

## Phase 3 — Enemy System

**目標**：完整回合制戰鬥與 5 場敵人流程。

> **併入前置（來自 Phase 2 Review，已決議）**：抽出 Presentation / BattleFX 模組、新增 `Data/feel.json` 將手感常數資料化（Q-011）、實作 Peg re-hit cooldown（Q-010）、移除 `phase2_test_ball_sequence` 對正式戰鬥的影響。詳見 `Codex/03_ENEMY_SYSTEM.md`。

工作項：
- 從 `enemies.json` 讀取 5 場敵人。
- 回合流程：玩家發射 → 結算 → 敵人攻擊 → 下一回合。
- 敵人攻擊扣玩家 HP。
- 玩家 / 敵人 HP UI。
- 勝敗判定（玩家 HP 0 → 死亡結算；Boss 死 → 勝利結算）。

**完成定義（DoD）**：
- 可依序打完 5 場（普通 / 普通 / 精英 / 普通 / Boss）。
- 敵人會反擊、玩家會死亡、Boss 被擊敗會勝利。
- 死亡結算與勝利結算畫面都會出現。

## Phase 4 — Roguelite Build

**目標**：成長系統。打倒敵人後三選一升級並套用。

工作項：
- 從 `upgrades.json` 讀取升級池。
- 擊敗敵人後彈出三選一（依 rarity 抽取）。
- 選擇後套用效果（提升釘子傷害 / 最大 HP / 球數 / 解鎖球種 / 降低敵人攻擊…）。
- 套用後進入下一場戰鬥，效果持續整局。

**完成定義（DoD）**：
- 每場勝利後出現三選一且選項有效。
- 選擇後數值確實改變，並反映在後續戰鬥。
- 一整局（5 場 + 4 次升級）可穩定跑完。

## Phase 5 — Polish & Demo

**目標**：比賽現場可穩定展示的完成度。任務卡見 `Codex/05_POLISH_DEMO.md`。MVP 功能（Phase 1–4）已 100% 到齊，本階段不加新玩法。

工作項：
- 美術一致性（霓虹賽博風、glow、UI）。
- 流程順手（過場、提示、重新開始）。
- 邊界情況處理（球卡住、極端數值、連點）。
- Windows Desktop Export 驗證。
- 一局 5–10 分鐘節奏調校（見 `Docs/04_BALANCE_RULES.md`）。

**完成定義（DoD）**：
- 匯出的 Desktop 版本可獨立執行、不需編輯器。
- 連續展示 3 局不崩潰。
- 通過 `VALIDATION_CHECKLIST.md` 的「Demo 展示驗收」全部項目。
