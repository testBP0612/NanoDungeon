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

（目前無。Q-001~Q-013 皆已決議；下方暫行假設已於 Phase 4 後一次定案。若 Phase 5 平衡微調需要新的取捨，再依模板新增。）

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

### Q-010：釘子可被同一顆球重複命中刷分
- 提出者：Claude（Phase 2 Review）
- 日期：2026-06-13
- 背景：球在同一釘上連續彈跳會多次觸發 `body_entered`，使 normal / burst / heal 傷害與回血可被「卡釘」farming（倍傷已被 `max_triggers_per_round` 保護）。此為 Phase 1 即存在、Phase 2 因 4 釘上線而更明顯的設計問題。
- 選項：
  - A. 每顆球對同一釘加入「再命中冷卻」（re-hit cooldown，資料驅動），冷卻內的重複接觸不計分，但不同球或冷卻後的命中仍計分。
  - B. 釘子命中數次後熄滅 / 消失（pinball-roguelite 常見）。
  - C. 不處理，維持可 farming。
- 結論（人類決議）：**採 A**。加入 per-peg re-hit cooldown，預設 `0.2` 秒，數值放入 feel 設定（見 Q-011）。選項 B 的「釘子耗損 / 消失」屬玩法擴張，列為 MVP 外，暫不實作。
- 決議日期：2026-06-13
- 影響範圍：Scripts/Ball.gd 或 Peg.gd、Data（feel 設定）、Docs/02_GAME_DESIGN.md、Docs/04_BALANCE_RULES.md、Codex/03_ENEMY_SYSTEM.md
- 狀態：✅ 已決議

### Q-011：feel / 表現層數值是否資料化
- 提出者：Claude（Phase 2 Review）
- 日期：2026-06-13
- 背景：Phase 2 的手感常數（screen shake 強度 / 時長、粒子數量 / 壽命、拖尾參數、浮動文字時長、SFX 頻率、peg re-hit cooldown）目前 hardcode 在 `.gd`。這與專案「資料驅動 / 不改程式調數值」原則相違，也不利於由人類 / AI 快速調手感。
- 選項：
  - A. 新增 `Data/feel.json` 集中所有表現層 / 手感數值，程式只讀。
  - B. 併入既有 `Data/player.json` 的新區段。
  - C. 維持 hardcode。
- 結論（人類決議）：**採 A**。新增 `Data/feel.json`，語意清楚、與玩法數值分離；程式改為讀取。實作併入 Phase 3（見任務卡前置段）。
- 決議日期：2026-06-13
- 影響範圍：Data/feel.json、Scripts/Battle.gd（及表現層 helper）、Docs/03_SYSTEM_SPEC.md、Docs/04_BALANCE_RULES.md、Codex/03_ENEMY_SYSTEM.md
- 狀態：✅ 已決議

### Q-012：多顆 Blast Ball 的落底加成是否疊加（延伸 Q-002）
- 提出者：Claude（Phase 2 Review）
- 日期：2026-06-13
- 背景：Q-002 原文為「額外加成一次本回合最高單次傷害」。現行實作 `pending_drop_bonus_multiplier += effect_value`，每多一顆 Blast 球就多加一次。Phase 2 測試每回合僅 1 顆，無影響；Phase 4 正式解鎖後需明確規則。
- 選項：
  - A. 每顆 Blast 球各加成一次（可疊加，現行行為）。
  - B. 不論幾顆，整回合僅加成一次（嚴格照 Q-002 字面）。
- 結論（人類決議）：**採 A**。每顆 Blast 球各加成一次，視為 build 投資的合理回報；Phase 4 的解鎖 / 球池上限本就會限制 Blast 球數量，數值不致爆炸。Q-002 維持選項 A（含倍傷後數值），本題補充「可隨球數疊加」。
- 決議日期：2026-06-13
- 影響範圍：Docs/02_GAME_DESIGN.md、Codex/04_ROGUELITE_BUILD.md
- 狀態：✅ 已決議

### Q-004：升級三選一的抽取規則與 rarity 權重
- 提出者：Claude
- 日期：2026-06-13
- 背景：`upgrades.json` 有 `rarity` 欄位，但抽取權重與「已解鎖類升級不再出現」規則未定。
- 結論（人類決議）：**採 A（rarity 加權 + 排重）**。收斂為以下可直接實作的規則：
  - **rarity 相對權重**：`common = 60`、`rare = 30`、`legendary = 10`。
  - **每次抽 3 個「互不重複」選項**（同一次三選一內不出現重複 id）。
  - **排除規則**：`unlock` 類若該球已在 `unlocked_balls` 則排除；`stat` 類若已達上限（如 `balls_per_round` 上限 6）則排除；其餘類型可在不同場次重複出現。
  - **可選池不足 3 個時**：有幾個給幾個（至少 1 個）。
  - **不做選項 C**「固定劇本 / 展示模式」（保持單一路徑，列為非目標）。
- 決議日期：2026-06-13
- 影響範圍：Data/upgrades.json、Codex/04_ROGUELITE_BUILD.md、Scripts（升級抽取器）
- 狀態：✅ 已決議

### Q-005：敵人攻擊時機與精英怪解鎖內容
- 提出者：Claude
- 日期：2026-06-13
- 背景：精英怪「打倒後可解鎖新球種或新增釘子能力」，需確定解鎖的是哪一項，避免與三選一升級重複。
- 結論（人類決議）：**採 C（精英保底高 rarity）**。收斂為以下規則：
  - **普通怪（normal）擊敗**：三選一照 Q-004 一般加權。
  - **精英怪（elite）擊敗**：三選一「3 槽中保底至少 1 個 rare 或以上」——實作為**第 1 槽只從 `rare + legendary` 池抽**（同樣排重），其餘 2 槽照 Q-004 一般加權。
  - **精英怪不另外固定解鎖球種**：解鎖一律交給升級池的 `unlock` 選項，避免雙重獎勵。
  - **Boss 擊敗**：直接進 Victory，無三選一。
- 決議日期：2026-06-13
- 影響範圍：Data/enemies.json、Data/upgrades.json、Codex/04_ROGUELITE_BUILD.md、Scripts（升級抽取器）
- 狀態：✅ 已決議

### Q-013：球池組成規則（解鎖球種後每回合如何發球）
- 提出者：Claude（Phase 3 Review）
- 日期：2026-06-13
- 背景：Phase 3 已隱性以 round-robin 發球（`已發球數 % unlocked_balls.size()`），但規格未定義球池組成規則，會影響 Phase 4 的 build 手感。
- 結論（人類決議）：**採 A（round-robin 輪替）**。收斂為以下規則：
  - 每回合發球依 `unlocked_balls` 的**解鎖順序**輪替：第 k 顆球 = `unlocked_balls[k % unlocked_balls.size()]`（k 從 0 起算）。
  - **初始 `unlocked_balls`** 依 `balls.json` 的 `unlocked_by_default` 欄位填入（目前為 `normal_ball`），不再僅靠 `starting_ball_id` 硬填。
  - 解鎖新球（升級 `unlock`）時 **append 到 `unlocked_balls` 末端**，使其進入輪替。
  - **不做**隨機抽球 / 玩家自訂球種比例（列為非目標）。
- 決議日期：2026-06-13
- 影響範圍：Scripts/Battle.gd（`_ball_id_for_next_launch`）、Scripts/RunState.gd（初始 unlocked_balls）、Data/balls.json（`unlocked_by_default`）、Codex/04_ROGUELITE_BUILD.md
- 狀態：✅ 已決議

### Q-001：倍傷釘（Double Peg）每回合可觸發次數
- 提出者：Claude
- 日期：2026-06-13
- 背景：規格寫「限一次或可控次數」，數值未定。
- 結論（人類決議）：**採 A — 每回合 1 次、倍率 ×2**（`pegs.json` 既有實作）。可由升級提升（`up_double_peg_boost` 倍率 +0.5、`up_double_peg_extra_trigger` 次數 +1）。經 Phase 2–4 實機驗證穩定，正式定案。
- 決議日期：2026-06-13（Phase 4 後最終確認）
- 影響範圍：Data/pegs.json、Data/upgrades.json、Docs/04_BALANCE_RULES.md
- 狀態：✅ 已決議

### Q-002：爆破球（Blast Ball）「最高單次釘子傷害」的計算基準
- 提出者：Claude
- 日期：2026-06-13
- 背景：需定義「最高單次」是否含倍傷、是否每顆球各自結算。
- 結論（人類決議）：**採 A — 取本回合單次最高傷害（含倍傷後數值）額外加成**；多顆 Blast 球可各加成一次（見 Q-012）。經實機驗證，正式定案。
- 決議日期：2026-06-13（Phase 4 後最終確認）
- 影響範圍：Data/balls.json、Scripts/EffectResolver.gd、Docs/02_GAME_DESIGN.md
- 狀態：✅ 已決議

### Q-003：護盾球（Shield Ball）減傷規則
- 提出者：Claude
- 日期：2026-06-13
- 背景：百分比或固定值、可否疊加。
- 結論（人類決議）：**採 A — 百分比減傷 -30%、多顆取最高不疊加**（`balls.json` effect_value 0.3）。經實機驗證，正式定案。
- 決議日期：2026-06-13（Phase 4 後最終確認）
- 影響範圍：Data/balls.json、Scripts/EffectResolver.gd、Docs/02_GAME_DESIGN.md、Docs/04_BALANCE_RULES.md
- 狀態：✅ 已決議

### Q-006：球落底的「底部」與失球判定
- 提出者：Claude
- 日期：2026-06-13
- 背景：底部是否有出口、是否有超時保險避免卡球。
- 結論（人類決議）：**採 A — 底部全開（碰底線即回收）+ 8 秒未落底強制回收**。不做 flippers / 擋板（列為非目標）。經 Phase 1–4 實機驗證，正式定案。
- 決議日期：2026-06-13（Phase 4 後最終確認）
- 影響範圍：Scripts/Battle.gd、Scripts/Ball.gd、Data/player.json（`ball_timeout_seconds`）
- 狀態：✅ 已決議

### Q-007：玩家初始數值與物理調校值放在哪個 JSON
- 提出者：Codex
- 日期：2026-06-13
- 背景：玩家初始 HP / 球數 / 起始球 / 超時 / 發射力 / 物理參數需資料化。
- 結論（人類決議）：**採 A — 保留 `Data/player.json`**。語意清楚、不污染其他 JSON schema，正式定案為專案標準檔案。
- 決議日期：2026-06-13（Phase 4 後最終確認）
- 影響範圍：Data/player.json、Scripts/DataLoader.gd、Scripts/RunState.gd
- 狀態：✅ 已決議

### Q-015：釘盤改為程序生成、每回合機率重組
- 提出者：Claude（Phase 7 規劃）
- 日期：2026-06-13
- 背景：人類希望釘盤改為「用算的」程序生成，並在每個玩家回合機率性改變場上釘子，增加趣味性與賽博主題感。
- 結論（人類決議）：
  - 佈局改為**參數化格點公式生成**（rows / spacing / 錯位 / 類型權重 / 保留底排），由產生器算座標，取代手列座標。
  - **每回合只重抽「類型」、位置骨架固定**（選項 A）。骨架穩定 → 物理可預期、不會生成卡球 / 全漏的爛盤，仍有視覺亂感。
  - 類型隨機池僅含 Normal / Heal / Burst / Double（Bounce 不進池，見 Q-016）。
  - 允許可選 `seed` 以利展示可重現，但預設每回合隨機。
- 決議日期：2026-06-13
- 影響範圍：Data/field.json（參數化）、Scripts（FieldGenerator / Battle ROUND_START 重抽）、Codex/07_PROCEDURAL_PEGBOARD.md
- 狀態：✅ 已決議

### Q-016：新增純反彈釘 bounce_peg（鎖定 4 釘 → 5 釘）
- 提出者：Claude（Phase 7 規劃）
- 日期：2026-06-13
- 背景：人類要求「底部固定一排純反彈、無效果的釘子」。實現此需求必須新增一種無效果釘；此舉擴充自 MVP 鎖定的「4 種 Peg」不變量。
- 結論（人類決議）：
  - **新增 `bounce_peg`**（`effect_type: "none"`，無傷無效果，只反彈）。
  - **僅用於底部固定排**，不納入每回合隨機類型池（見 Q-015）。
  - 釘子種類正式由 4 → **5**；同步更新 `Docs/02_GAME_DESIGN.md` 與 `Codex/VALIDATION_CHECKLIST.md` 的「4 釘」描述。
  - 仍**不**實作連鎖釘（維持非目標）。
- 決議日期：2026-06-13
- 影響範圍：Data/pegs.json、Data/field.json、Docs/02_GAME_DESIGN.md、Codex/VALIDATION_CHECKLIST.md、Codex/07_PROCEDURAL_PEGBOARD.md
- 狀態：✅ 已決議

### Q-017：場地高度拉高至 1024×1024
- 提出者：Claude（Phase 7 規劃）
- 日期：2026-06-13
- 背景：為容納更多釘子與隨機趣味性，需要更高的場地。
- 結論（人類決議）：**視窗 / viewport 加高為 1024×1024**（維持寬度）。連動調整 launcher、牆、落底感測器、BattleUI 錨點、BattleCamera 與 export preset。場地內部高度相應拉高以多容納數排釘子。
- 決議日期：2026-06-13
- 影響範圍：project.godot（viewport）、Scenes/Battle.tscn、Scripts/Battle.gd、Data/field.json（bounds）、export_presets.cfg、Codex/07_PROCEDURAL_PEGBOARD.md
- 狀態：✅ 已決議
