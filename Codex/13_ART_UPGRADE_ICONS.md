# 任務卡 13 — ART UPGRADE ICONS（升級卡 icon ×13）

> 美術 Pass 軌道，續 `Codex/12_ART_CORE.md`。先讀 `Codex/00_MASTER_PROMPT.md`。
> 目標：為 `upgrades.json` 的每個升級生一個賽博風 icon 並接到升級卡，**保留 fallback**。
>
> 決策依據見 OPEN_QUESTIONS **Q-026**。**單獨 session 執行**（量最大）。

---

## 鐵律
- 沿用 `12_ART_CORE.md` 的**風格錨點**與工具（`agent-sprite-forge` `$generate2dsprite`，靜態、透明 PNG）。
- **fallback 必留**：缺 icon 時用通用占位（如依 rarity 上色的純色方塊 / 既有卡片樣式），缺圖不崩。
- icon 透明、方形（建議 256²）、置中、單一主體、無文字。
- 不改任何玩法 / 數值；純資產 + 接線。

## 一致性
- 先生 1 個 base icon（建議 `up_normal_peg_dmg`）定調，其餘以它當 reference 串生，確保 13 個同一風格。
- 依 rarity 給邊光色調：common 青、rare 紫 / 洋紅、legendary 金（與卡片既有 rarity 色一致）。

## 命名與清單
- 路徑：`assets/upgrades/<upgrade_id>.png`，檔名 = `upgrades.json` 的 `id`。
- 各 prompt = 風格錨點 + 下列主體（皆 icon 化、象徵性、無文字）：

| upgrade_id | 主體關鍵詞 |
|---|---|
| up_normal_peg_dmg | reinforced glowing node, small power-up arrow |
| up_burst_peg_dmg | exploding energy node, sharp burst |
| up_heal_peg_boost | green repair node, plus/cross symbol |
| up_double_peg_boost | multiplier node, ×2 motif (圖形非文字) |
| up_max_hp | hardened shell / shield core, hp vessel |
| up_max_hp_big | large reinforced core, bigger hp vessel |
| up_balls_per_round | extra energy orbs, multiple pulses |
| up_unlock_blast_ball | blast orb with shock rings |
| up_unlock_shield_ball | shield orb, protective ring |
| up_enemy_attack_down | jamming/down arrow over enemy glyph |
| up_guaranteed_double | proliferating multiplier nodes, surge |
| up_normal_peg_dmg_big | surging overcharged node, strong glow |
| up_double_peg_extra_trigger | chained multiplier nodes, links |

> 「×2」等以**圖形符號**表現，避免 AI 文字拼錯。

## 接線
- `UpgradeScreen` 卡片加 icon 顯示（`TextureRect`），依該選項 `id` 載 `assets/upgrades/<id>.png`。
- **缺圖 fallback**：用通用占位（rarity 上色），不影響卡片名稱 / 描述 / 選取流程。
- Godot import：linear、關 mipmaps。

## 不做範圍（嚴禁）
- ❌ 動畫 / sprite sheet；icon 內硬塞文字當唯一資訊。
- ❌ 不改升級數值 / 抽取 / 套用規則（純視覺）。
- ❌ 不依賴 icon 才能運作（fallback 必留）。

## 預期產出
- `assets/upgrades/*.png`（13，對應 id）。
- `UpgradeScreen` 卡片 icon 接線 + fallback。
- 更新 `CHANGELOG.md`、產出 `PROGRESS_REPORT.md`。

## 驗收條件（DoD）
- [ ] 13 個 icon 風格一致、依 rarity 色調區分、透明乾淨、依 id 正確對應顯示。
- [ ] 升級卡顯示 icon；缺任一 icon 時 fallback、流程不崩。
- [ ] 未改升級規則 / 數值；三選一抽取 / 套用照舊。
- [ ] export 後正常、不掉幀；Godot 載入無錯、`Data/*.json` 可解析。

## 完成後
- 依 DoD 自驗、更新 `CHANGELOG.md`、產出 `PROGRESS_REPORT.md`。美術 Pass 完成後即可進入封版前的最終實機彩排。
