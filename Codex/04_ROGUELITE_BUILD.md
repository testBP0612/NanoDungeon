# 任務卡 04 — ROGUELITE BUILD（升級三選一與成長）

> Phase 4。先讀 `Codex/00_MASTER_PROMPT.md`。目標：**完成擊敗敵人後的三選一升級，以及球池 / 釘子 / 屬性的成長**，讓一整局（5 場 + 4 次升級）可穩定跑完並感受到 build 成形。

---

## 任務範圍（要做）

### 升級資料讀取
- 從 `upgrades.json` 讀取升級池（每項含 `id / name / description / target_type / target_id / effect_type / effect_value / rarity`）。
- 載入時驗證 `target_id` 能對應到實際的 peg / ball / stat（無效則明確報錯）。

### 升級選項顯示（三選一）
- 每場非 Boss 敵人被擊敗後，切 `UpgradeScreen.tscn`，顯示 3 個升級選項（卡片式，含名稱、描述、rarity 視覺區分）。
- **抽取規則（Q-004 已決議，定案）**：
  - rarity 相對權重：`common = 60`、`rare = 30`、`legendary = 10`。
  - 每次抽 **3 個互不重複** 的選項（同一次三選一內不重複 id）。
  - 排除：`unlock` 類若該球已在 `unlocked_balls` 則排除；`stat` 類若已達上限（如 `balls_per_round` 上限 6）則排除；其餘可跨場次重複出現。
  - 可選池不足 3 個時，有幾個給幾個（至少 1 個）。
  - 不實作「固定劇本 / 展示模式」（非目標）。
- **精英怪保底（Q-005 已決議，定案）**：
  - 普通怪（`normal`）：3 槽全照上述一般加權。
  - 精英怪（`elite`）：**第 1 槽只從 `rare + legendary` 池抽**（仍排重），其餘 2 槽照一般加權 → 保底至少 1 個 rare 以上。
  - 精英怪**不**另外固定解鎖球種（解鎖一律交給 `unlock` 選項，避免雙重獎勵）。
  - Boss：直接 Victory，無三選一。
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
- **球池組成（Q-013 已決議，定案）**：每回合第 k 顆球 = `unlocked_balls[k % unlocked_balls.size()]`（round-robin，k 從 0 起）。初始 `unlocked_balls` 依 `balls.json` 的 `unlocked_by_default` 填入；解鎖新球時 append 到末端使其進入輪替。不做隨機抽球 / 玩家自訂比例。
- **沿用 Phase 3 既有實作**：`_ball_id_for_next_launch` 已是 round-robin，本圈只需確保 `unlocked_balls` 初始化改讀 `unlocked_by_default`，並讓 `unlock` 升級正確 append。

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
- [ ] 抽取依 rarity 權重 60/30/10、3 個互不重複、排除已解鎖 / 已達上限的選項。
- [ ] 精英怪三選一保底至少 1 個 rare 以上；普通怪一般加權；Boss 無三選一。
- [ ] 初始 `unlocked_balls` 來自 `balls.json` 的 `unlocked_by_default`；`unlock` 升級會 append 並進入 round-robin 球池。
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
- ❌ 不得偏離已決議的抽取 / 保底 / 球池規則（Q-004 / Q-005 / Q-013）；如需調整須先回 `OPEN_QUESTIONS.md` 提案。
- ❌ 不得引入存檔 / 跨局成長等非目標。
