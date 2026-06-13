# OPEN_QUESTIONS — 待決策問題

這份檔案是 **AI 與人類之間的決策緩衝區**。任何 AI（Claude / Codex / Reviewer / Tester）遇到規格未涵蓋、或可能影響核心方向的不確定事項，**不得擅自決定**，而是寫進這裡，等待人類拍板。

---

## 使用規則

1. **不確定就記錄，不要猜**。凡是「規格沒寫、但實作必須選一個答案」的問題，一律寫進本檔。
2. **不得擅自更改核心方向**。核心方向（玩法循環、MVP 範圍、Peg/Ball/Enemy 種類數）只能由人類更動。
3. **每題要可被回答**。提供背景、選項、與你（AI）的建議，讓人類能快速拍板。
4. **被回答後**：把該題移到「已決議」區，記錄結論與日期，並在 `CHANGELOG.md` 留痕；若影響規格，回頭更新對應 `Docs/`。
5. **臨時假設（Assumption）允許但要標記**：若為了不卡住而先採用某假設，必須在此標記 `⚠️ 暫行假設`，並列為待確認。
6. 編號不重用，已決議的題號保留。

## 記錄格式（請複製此模板）

```markdown
### Q-XXX：<一句話問題>
- 提出者：<Claude / Codex / Reviewer / Tester / 人類>
- 日期：YYYY-MM-DD
- 背景：<為什麼會碰到這個問題、影響哪個檔案 / Phase>
- 選項：
  - A. <選項一>
  - B. <選項二>
  - C. <選項三>
- AI 建議：<傾向哪個、理由>
- 影響範圍：<Docs / Data / 哪張任務卡 / 是否動到核心方向>
- 狀態：⬜ 待決策 ｜ ⚠️ 暫行假設 ｜ ✅ 已決議
```

---

## 目前待決策問題

### Q-001：倍傷釘（Double Peg）每回合可觸發次數
- 提出者：Claude
- 日期：2026-06-13
- 背景：規格寫「限一次或可控次數」，數值未定，影響 `Data/pegs.json` 的 `effect_value` 與 Phase 2 實作。
- 選項：
  - A. 每回合僅可觸發 1 次（最穩定、好平衡）
  - B. 每回合可觸發 2 次但倍率不疊加（取最高）
  - C. 可疊加但設上限（如 ×4 封頂）
- AI 建議：A。Demo 階段最容易平衡且不會數值爆炸。
- 影響範圍：Data/pegs.json、Docs/04_BALANCE_RULES.md、Codex/02_PINBALL_FEEL.md
- 狀態：⚠️ 暫行假設（目前 JSON 先以「每回合 1 次、倍率 ×2」實作）

### Q-002：爆破球（Blast Ball）「最高單次釘子傷害」的計算基準
- 提出者：Claude
- 日期：2026-06-13
- 背景：規格寫「落底時額外加成一次本回合最高單次釘子傷害」，需定義「最高單次」是否含倍傷加成、是否每顆爆破球各自結算。
- 選項：
  - A. 取本回合所有命中中「單次最高傷害值」，再額外加一次（含倍傷後的數值）
  - B. 同 A 但以倍傷前的基礎值計算
  - C. 每顆爆破球各自記錄自己命中的最高值
- AI 建議：A。直覺、好懂、Demo 可見效果明顯。
- 影響範圍：Data/balls.json、Codex/02_PINBALL_FEEL.md
- 狀態：⚠️ 暫行假設（先採 A）

### Q-003：護盾球（Shield Ball）減傷是百分比還是固定值、可否疊加
- 提出者：Claude
- 日期：2026-06-13
- 背景：影響 `Data/balls.json` 的 `effect_type / effect_value` 與敵人攻擊結算。
- 選項：
  - A. 百分比減傷（如 -30%），多顆取最高不疊加
  - B. 固定減傷（如 -3），多顆可疊加但有下限 0
  - C. 百分比且可疊加（風險：可能完全免傷）
- AI 建議：A。避免完全免傷讓戰鬥失去張力。
- 影響範圍：Data/balls.json、Docs/04_BALANCE_RULES.md、Codex/03_ENEMY_SYSTEM.md
- 狀態：⚠️ 暫行假設（先採 A，-30%）

### Q-004：升級三選一的抽取規則與 rarity 權重
- 提出者：Claude
- 日期：2026-06-13
- 背景：`upgrades.json` 有 `rarity` 欄位，但抽取權重與「已解鎖類升級不再出現」規則未定。
- 選項：
  - A. 依 rarity 加權（common 高、rare 低、legendary 最低），已達上限或已解鎖的選項自動排除
  - B. 完全均勻隨機
  - C. 固定劇本（每場給定三選一，不隨機）
- AI 建議：A，但 Demo 若想要可預測展示，可保留 C 作為「展示模式」開關。
- 影響範圍：Data/upgrades.json、Codex/04_ROGUELITE_BUILD.md
- 狀態：⬜ 待決策

### Q-005：敵人攻擊時機與精英怪解鎖內容
- 提出者：Claude
- 日期：2026-06-13
- 背景：精英怪「打倒後可解鎖新球種或新增釘子能力」，需確定解鎖的是哪一項，避免與三選一升級重複。
- 選項：
  - A. 精英怪固定解鎖一種球（如 Blast Ball），與三選一升級分離
  - B. 精英怪不特別解鎖，全部交給三選一
  - C. 精英怪提供「保底高 rarity 三選一」
- AI 建議：C。簡化系統、又保留精英怪的獎勵感。
- 影響範圍：Data/enemies.json、Data/upgrades.json、Codex/04_ROGUELITE_BUILD.md
- 狀態：⬜ 待決策

### Q-006：球落底的「底部」與失球判定
- 提出者：Claude
- 日期：2026-06-13
- 背景：彈珠台需定義底部是否有出口、是否所有球都會落底、是否有時間上限避免球卡住。
- 選項：
  - A. 底部全開（球碰到底線即視為落底回收），並加「N 秒未落底強制回收」保險
  - B. 底部有擋板 / flippers（增加複雜度，暫不建議）
- AI 建議：A。Phase 1 先不做 flippers，靠重力與超時回收確保流程不卡死。
- 影響範圍：Codex/01_FIRST_PLAYABLE.md、Codex/02_PINBALL_FEEL.md
- 狀態：⚠️ 暫行假設（先採 A，超時 8 秒）

### Q-007：玩家初始數值與 Phase 1 物理調校值應放在哪個 JSON
- 提出者：Codex
- 日期：2026-06-13
- 背景：Phase 1 需要玩家初始 HP、每回合球數、起始球種、球超時秒數、發射力度、球半徑、重力倍率與彈性等數值。既有 `Data/pegs.json` / `balls.json` / `enemies.json` / `upgrades.json` 未提供這些玩家與場地基礎設定，但任務要求數值從 `Data/*.json` 讀取且不得寫死。
- 選項：
  - A. 新增 `Data/player.json` 保存玩家初始狀態與 Phase 1 物理調校值
  - B. 把玩家初始狀態加入既有 `Data/balls.json` 的 `_meta` 或新欄位
  - C. 另建更廣義的 `Data/run_config.json` 保存整局初始設定
- AI 建議：A。語意清楚、範圍最小，不改既有四份 JSON 的 schema；Phase 1 先以暫行資料來源推進。
- 影響範圍：Data/player.json、Scripts/DataLoader.gd、Scripts/RunState.gd、Codex/01_FIRST_PLAYABLE.md
- 狀態：⚠️ 暫行假設（本圈先新增 `Data/player.json`，待人類確認）

---

## 已決議

### Q-008：Battle 場地 / UI 採場景節點或程式化生成
- 提出者：Claude（Phase 1.5 Architecture Review）
- 日期：2026-06-13
- 背景：Phase 1 將彈珠場與 BattleUI 全部由 `Battle.gd` 程式化生成，與 `03_SYSTEM_SPEC.md` 建議的場景樹背離，影響 Phase 2 特效與 Phase 5 美術的可視化調校。
- 結論（人類決議）：**改為 `Battle.tscn` 內的實際節點**，`Battle.gd` 改以 `@onready` 取用、只負責邏輯。視覺與座標須與重構前一致。
- 決議日期：2026-06-13
- 影響範圍：Scenes/Battle.tscn、Scripts/Battle.gd、Codex/01b_REFACTOR.md
- 狀態：✅ 已決議

### Q-009：是否清理 `project.godot` 的 3D 物理 / d3d12 設定
- 提出者：Claude（Phase 1.5 Architecture Review）
- 日期：2026-06-13
- 背景：專案為 2D，但 `project.godot` 仍含 `3d/physics_engine = Jolt Physics` 與 d3d12 設定（對 2D 物理無影響，屬噪音）。
- 結論（人類決議）：**Phase 1.5 暫不動**。保持現狀，不在重構圈處理，避免擴大範圍。日後若需要再另開圈。
- 決議日期：2026-06-13
- 影響範圍：project.godot
- 狀態：✅ 已決議
