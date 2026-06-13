# 任務卡 01b — ARCHITECTURE REFACTOR（行為等價重構）

> Phase 1.5。先讀 `Codex/00_MASTER_PROMPT.md`。
> 目標：**在不改變任何遊戲行為的前提下**，清理 Phase 1 累積的架構債，為 Phase 2 鋪路。
>
> ⚠️ 本卡的最高紀律：**這是行為等價重構（behavior-preserving refactor），不是重寫，也不加任何新玩法。** 重構後遊戲的可見行為必須與重構前**完全相同**。

---

## 背景（為什麼有這張卡）

Phase 1 已達 DoD 並經人類實機驗證可玩。但 Phase 1.5 Architecture Review 指出，Phase 2（4 釘 3 球效果、傷害數字、粒子）會直接踩中以下既有債：
- 沒有 Effect Resolver，傷害邏輯 inline 在 `Battle.gd`。
- 沒有 `RoundContext`，回合暫存散在 `Battle.gd` 成員變數。
- FSM 入口不一致（部分 `state = ...` 直接賦值）。

若不先處理，Phase 2 會在 god object 上複利累積技術債。本卡先還清這筆債。

## 任務範圍（要做）

1. **抽出 Effect Resolver**
   - 新增 `Scripts/EffectResolver.gd`（autoload 或被 `Battle.gd` 持有的一般節點 / 類別皆可）。
   - 將「依 `effect_type` 套用 Peg / Ball 效果」的邏輯集中於此，以查表 / `match` 分派。
   - Phase 1 目前只有 `damage`（Normal Peg）一種分支 → 先只搬這一種，**不得趁機實作其他 effect_type**。
   - `Battle.gd` 改為呼叫 Resolver，而非自己 inline 判斷 `effect_type`。

2. **建立 RoundContext 結構**
   - 新增 `Scripts/RoundContext.gd`（`RefCounted` 或 `Resource` 皆可），集中回合暫存欄位。
   - 至少納入目前已用到的 `damage_accumulator`（即現 `round_damage`）。
   - **預留**（宣告但不啟用、給 Phase 2 用）：`round_multiplier`、`highest_single_hit`、`incoming_damage_reduction`、`balls_remaining`、`balls_in_play`。預留欄位需有合理初值，但本卡不接任何邏輯。
   - `Battle.gd` 改用 `RoundContext` 持有回合暫存，取代散落的成員變數。

3. **統一 FSM 入口**
   - 所有狀態切換一律走 `_transition_to(next_state)`，移除散落的 `state = ...` 直接賦值（如 `_fire_ball`、`_end_battle`）。
   - 在 `_transition_to` 內集中處理每個狀態的進入行為。
   - （建議）加入非法轉移的防呆 / 警告，但不得改變合法流程。

4. **場景 / 程式分離（人類已決議：執行，見 OPEN_QUESTIONS Q-008）**
   - 將程式化生成的彈珠場（牆、BottomSensor、容器）與 BattleUI（標籤、按鈕）改為 `Battle.tscn` 內的實際節點，`Battle.gd` 改為 `@onready` 取用節點、只負責邏輯。
   - 視覺與座標必須與重構前一致。

5. **清除殘渣**
   - 刪除根目錄殘留的 `node_2d.tscn`（空場景、無人引用）。確認無任何 `.tscn` / 腳本引用後再刪。

## 不做範圍（嚴禁觸碰）

- ❌ 不實作任何新 Peg / Ball / 敵人 / 升級 / 特效 / 音效 / 傷害數字（那是 Phase 2）。
- ❌ 不改任何可見行為、數值、物理參數、場地座標、UI 版面。
- ❌ 不啟用 RoundContext 的預留欄位邏輯（只宣告）。
- ❌ 不動 `project.godot` 的 3D 物理 / d3d12 設定（人類已決議 Phase 1.5 暫不處理，見 OPEN_QUESTIONS Q-009）。
- ❌ 不改 `Data/*.json` 的數值與 schema。
- ❌ 不重寫未列在本卡範圍內的模組。

## 預期產出

- `Scripts/EffectResolver.gd`（集中效果分派，目前僅 `damage`）。
- `Scripts/RoundContext.gd`（回合暫存結構 + Phase 2 預留欄位）。
- 重構後的 `Scripts/Battle.gd`（瘦身：邏輯與生成 / 結算職責分離，FSM 入口統一）。
- （預設）重構後的 `Scenes/Battle.tscn`（場地 + UI 成為實際節點）。
- 移除 `node_2d.tscn`。
- 更新 `CHANGELOG.md`（標註「行為等價重構」）。
- 產出 `PROGRESS_REPORT.md`（含下方回歸驗收結果）。

## 驗收條件（DoD）— 以「行為等價」為核心

對照重構前後，下列**全部**必須一致 / 通過：

- [ ] `Codex/VALIDATION_CHECKLIST.md` 的 **C. First Playable 驗收** 全部項目重新逐項通過（回歸測試）。
- [ ] 主選單 → 戰鬥 → 發射 → 撞釘累積 → 落底 / 超時 → 結算 → 敵人反擊 → 重來 / 回主選單，行為與重構前**完全相同**。
- [ ] 球數、Normal Peg 傷害、敵人 HP / attack、超時秒數仍來自 JSON，數值未變。
- [ ] 場地座標、peg 佈點、UI 版面與重構前視覺一致。
- [ ] 傷害邏輯只存在於 `EffectResolver`，`Battle.gd` 不再 inline 判斷 `effect_type`。
- [ ] 回合暫存集中於 `RoundContext`，`Battle.gd` 無散落的回合成員變數（除持有 context 外）。
- [ ] 所有狀態切換都經 `_transition_to`，無散落 `state = ...`。
- [ ] `node_2d.tscn` 已移除，專案仍可正常載入與遊玩。
- [ ] Godot 載入無腳本解析 / 場景錯誤。

## 禁止事項

- ❌ 不得在「重構」名義下改變任何玩法或數值（行為等價是鐵律）。
- ❌ 不得一次重寫整個專案或重構未列範圍的檔案。
- ❌ 不得啟用 / 實作 Phase 2 的效果（預留欄位只宣告）。
- ❌ 不得擅改 `Docs/*`、`ROADMAP.md`、`Data/*` schema、核心玩法（只能提案，見 Permission Matrix）。
- ❌ 遇到無法在不改行為下完成的情況 → 停下，寫入 `OPEN_QUESTIONS.md`，不自行裁示。

## 完成後

- 更新 `CHANGELOG.md`、產出 `PROGRESS_REPORT.md`、把新發現的不確定寫進 `OPEN_QUESTIONS.md`。
- 回報：做了什麼、回歸驗收結果（逐項）、未解問題、建議下一張任務卡（預期為 `Codex/02_PINBALL_FEEL.md`）。
