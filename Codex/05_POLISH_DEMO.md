# 任務卡 05 — POLISH & DEMO（收尾與展示穩定）

> Phase 5。先讀 `Codex/00_MASTER_PROMPT.md`。目標：**讓專案成為比賽現場可穩定展示的完成品**。MVP 功能已 100% 到齊（Phase 1–4），本圈**不加新玩法**，只做回歸、平衡、polish、export 與穩定性。
>
> ⚠️ 紀律：**平衡只調 JSON、不改規則**；polish 不得破壞既有流程；遇到要動玩法 / 種類 / 核心方向 → 停下寫 `OPEN_QUESTIONS.md`。

---

## 任務範圍（要做）

### 1. 完整實機回歸與穩定性
- 確認「主選單 → 5 場（含 4 次三選一）→ Boss → Victory」可順暢跑完。
- 死亡 → GameOver → 重來 / 回主選單路徑乾淨，狀態不殘留。
- 連續展示 3 局不崩潰、無記憶體洩漏徵兆（粒子 / Label / AudioStreamPlayer 都有被釋放）。
- 邊界情況：球卡住（靠 8 秒超時）、連點發射、極端 build（球數封頂、敵攻壓到 1）皆不崩潰。

### 2. 平衡微調（只動 JSON）
- 目標：一局 **5–10 分鐘**、正常玩家**不會在前 2 場暴斃**、Boss 有張力但可擊敗。
- 僅調整 `Data/enemies.json`、`pegs.json`、`balls.json`、`upgrades.json`、`player.json`、`feel.json` 的數值。
- 留意 `enemy_attack_down` 多次堆疊（floor=1）是否讓後段過易；必要時調升級 `effect_value` 或敵人數值。
- 每次調整在 `CHANGELOG.md` 標 `Data`，不改任何規則邏輯。

### 3. UI / 一致性 polish
- 將 `GameOver` / `Victory` 由程式生成 UI 改為場景節點（`.tscn`），與 Q-008 既定慣例一致（`UpgradeScreen` 已是 .tscn）。
- `RunState.build_summary` 顯示**球種顯示名**（如「爆破球 Blast Ball」）而非原始 id。
- `UpgradeScreen` 卡片視覺套用霓虹賽博風（見 `Docs/05_ART_DIRECTION.md`），rarity 以顏色區分。
- 整體套用 WorldEnvironment Glow、UI 描邊等內建效果，維持風格一致（不得犧牲幀率）。

### 4. Windows Desktop Export 驗證
- 設定並產出 Windows Desktop Export，確認**可獨立執行、不需編輯器**。
- 確認 export 後 `Data/*.json` 仍可正確載入（資源路徑 `res://` 打包無誤）。

### 5. 死設定 / 殘渣清理
- 移除或復用 `feel.json` 中已不再使用的 `reward_advance_delay_seconds`（Phase 4 後已無引用）。
- 掃一次有無其他未使用欄位 / 死碼，清理但不重構無關模組。

## 不做範圍（嚴禁）

- ❌ 新增 Peg / Ball / Enemy / 升級「種類」或任何新玩法機制。
- ❌ 連鎖釘、連射球、flippers、存檔、登入、Web Export、多人、商城（全為非目標）。
- ❌ 改動核心玩法規則、Vision / Design / Roadmap（只能提案）。
- ❌ 為了美術 / 特效犧牲穩定幀率或流程完整性。
- ❌ 大規模重構與本圈無關的模組。

## 預期產出

- `Scenes/GameOver.tscn` / `Scenes/Victory.tscn` 場景化版本（含對應腳本瘦身）。
- 調整後的 `Data/*.json`（平衡）。
- 套用風格的 `UpgradeScreen` 與整體 UI polish。
- Windows Desktop Export 設定與一份可執行產物（或 export preset）。
- 清理後的 `feel.json`。
- 更新 `CHANGELOG.md`、產出 `PROGRESS_REPORT.md`。

## 驗收條件（DoD，對應 VALIDATION_CHECKLIST G 區）

- [ ] Windows Desktop Export 可獨立執行（不需編輯器）。
- [ ] 一局可在 5–10 分鐘內完成。
- [ ] 連續展示 3 局不崩潰。
- [ ] 正常玩家不會在前 2 場暴斃（下限保護有效）。
- [ ] 整體霓虹賽博風一致（黑底、glow、發光節點）。
- [ ] 過場 / 提示 / 重新開始順手，無卡死。
- [ ] 邊界情況（球卡住、連點、極端升級）已處理。
- [ ] 音效可關、無刺耳爆音。
- [ ] GameOver / Victory 已場景化；build 摘要顯示名正確。
- [ ] `feel.json` 無死設定。
- [ ] 平衡調整全部只動 JSON，未改規則邏輯。

## 禁止事項

- ❌ 不得用 polish 名義改玩法 / 數值規則（數值只改 JSON）。
- ❌ 不得引入任何非目標功能。
- ❌ 不得讓 export / 美術破壞既有可運行流程。
- ❌ 不得偏離已決議事項（Q-001~Q-013 皆已定案）；如需調整先回 `OPEN_QUESTIONS.md` 提案。

## 完成後

- 依 `VALIDATION_CHECKLIST.md` G 區 + H 區自我檢查並逐項回報。
- 更新 `CHANGELOG.md`、產出 `PROGRESS_REPORT.md`。
- 這是 MVP 的最後一個 Phase；完成後回報 Demo 是否達「比賽現場可穩定展示」標準。
