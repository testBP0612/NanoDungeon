# 任務卡 04 — ROGUELITE BUILD（升級三選一與成長）

> Phase 4。先讀 `Codex/00_MASTER_PROMPT.md`。目標：**完成擊敗敵人後的三選一升級，以及球池 / 釘子 / 屬性的成長**，讓一整局（5 場 + 4 次升級）可穩定跑完並感受到 build 成形。

---

## 任務範圍（要做）

### 升級資料讀取
- 從 `upgrades.json` 讀取升級池（每項含 `id / name / description / target_type / target_id / effect_type / effect_value / rarity`）。
- 載入時驗證 `target_id` 能對應到實際的 peg / ball / stat（無效則明確報錯）。

### 升級選項顯示（三選一）
- 每場非 Boss 敵人被擊敗後，切 `UpgradeScreen.tscn`，顯示 3 個升級選項（卡片式，含名稱、描述、rarity 視覺區分）。
- 抽取規則：依 `rarity` 加權抽取，排除「已解鎖 / 已達上限」的選項（遵守 Q-004；若人類尚未決議，採加權 + 排重的暫行假設並記錄）。
- 精英怪獎勵遵守 Q-005 暫行假設（暫定：保底一個較高 rarity 選項）。
- 玩家選擇其一後關閉畫面、進入下一場。

### 選擇後套用效果
依 `effect_type` 套用到 `RunState`（集中於 Effect Resolver / 升級套用器）：
- 提升某種 Peg 傷害（`target_type: peg`，改 `peg_damage_mods`）。
- 提升玩家最大 HP（`stat: max_hp`，並依 `04_BALANCE_RULES.md` 決定補血規則）。
- 增加每回合球數（`stat: balls_per_round`，遵守上限，暫定 6）。
- 解鎖 Blast Ball / Shield Ball（`unlock`，加入 `unlocked_balls`）。
- 提升補血效果（`peg: heal_peg`）。
- 提升倍傷效果（`peg: double_peg`）。
- 降低敵人攻擊（`stat: enemy_attack_down`）。
- 效果**持續整局**，反映在後續所有戰鬥。

### 下一場戰鬥
- 套用升級後，`current_battle_index += 1`，載入下一場敵人，回到戰鬥 FSM 的 INIT / ROUND_START。
- 球池組成依 `unlocked_balls` 與 `balls_per_round` 重新計算（如何分配球種比例若未定，記錄於 `OPEN_QUESTIONS.md`）。

## 不做範圍

- 新增 Peg / Ball / 敵人「種類」（維持 4 釘 3 球 5 場）。
- 跨局存檔 / 永久成長（非目標）。
- 美術定稿 → Phase 5。

## 預期產出

- `UpgradeScreen.tscn`（三選一卡片 UI + 抽取邏輯）。
- 升級抽取器（依 rarity 加權、排重、精英保底）。
- 升級套用器（依 effect_type 改 `RunState`）。
- 與 Phase 3 戰鬥流程串接的「敵死 → 升級 → 下一場」閉環。
- 更新後的 `CHANGELOG.md`。

## 驗收條件（DoD）

- [ ] 每場非 Boss 勝利後出現三選一，選項來自 `upgrades.json`。
- [ ] 抽取會排除已解鎖 / 已達上限的選項，且依 rarity 加權。
- [ ] 選擇後對應數值確實改變（可在後續戰鬥觀察到）。
- [ ] 解鎖 Blast / Shield 球後，後續回合球池確實出現該球種。
- [ ] 增加球數、提升 HP、降低敵人攻擊等效果在下一場可驗證。
- [ ] 一整局（5 場 + 4 次升級）可穩定跑完，最後進勝利結算。
- [ ] 升級效果持續整局、重新開始後歸零。
- [ ] 所有升級數值來自 `upgrades.json`，未寫死。

## 禁止事項

- ❌ 不得新增超出既定清單的升級「類型」（可加同型別的 JSON 條目，但不得新增需要改規則的機制）。
- ❌ 不得讓升級效果寫死在程式，須由 `upgrades.json` 驅動。
- ❌ 不得讓某升級突破 `04_BALANCE_RULES.md` 的上限（如球數封頂）。
- ❌ 不得在未取得 Q-004 / Q-005 決議下，把暫行假設當成既定規格而不記錄。
- ❌ 不得引入存檔 / 跨局成長等非目標。
