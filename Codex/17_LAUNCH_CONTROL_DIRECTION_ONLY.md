# 任務卡 17 — LAUNCH CONTROL：只控方向（移除力道集氣）

> 核心機制改動。先讀 `Codex/00_MASTER_PROMPT.md`。
> 依據：`OPEN_QUESTIONS.md` **Q-031（人類決議：採 A — 只控方向）**。**這是人類已拍板的核心方向改動，你只忠實實作，不得自行另選方案。**
> 目標：移除玩家可控的「力道集氣」軸，發射改為**只控方向、固定發射速度、一鍵發射**（Peggle / Peglin 模型），契合 `Docs/01_GAME_VISION.md`「算好角度」核心幻想。
>
> 排程：卡 16 之後（或與其獨立）。**僅做控制方式，不碰彈跳物理（卡 16）、不做 Review P1/P2。**

---

## 前置（Docs 同步）

- 本卡實作前，`Docs/02_GAME_DESIGN.md` 的「發射階段」措辭應已依 Q-031 的「Docs/02 修訂提案」由**人類**更新。
- 若實作時 Docs 尚未更新：**以 Q-031 結論為準繼續實作**，並於回報中提醒人類補上 Docs 修訂；**不得自行改寫 `Docs/`**。

## 核心紀律

- **忠實實作既定決議**：只控方向、固定速度。不得保留 / 復活力道集氣，也不得自行改成拉弓等其他模型（那些是 Q-031 已排除的 B / C）。
- **固定發射速度資料化**：取 `Data/player.json` 既有 `launch_speed`(900)；**不得寫死**。
- **欄位保留標記 deprecated**：`launch_speed_min` / `launch_speed_max` / `charge_cycle_seconds` 暫不刪除，於 `player.json` `_meta` 或註解標記 `deprecated（Q-031）`，避免破壞 schema / 其他讀取。
- **瞄準體驗保留**：現有瞄準預覽（`AimLine` / aim preview 軌跡）維持或強化，因為角度現在是唯一技巧軸，瞄準回饋要更清楚。

## 任務範圍（要做）

1. **輸入流程簡化**（`Scripts/Battle.gd`）：
   - 移除「第一次按鍵鎖方向並開始集氣 → 第二次按鍵發射」的兩段流程（`_handle_launch_input` / `is_charging_launch` / `charge_elapsed` / `charge_power` 相關）。
   - 改為：滑鼠 / 方向決定瞄準方向，**單次按鍵（左鍵 / 空白鍵）即以固定 `launch_speed` 發射**該球。
   - 發射方向取當前瞄準方向（沿用 `_aim_direction()`）。
2. **移除集氣相關表現**：power bar 的集氣顯示、`update_charge_feedback`、集氣 SFX、launcher 顏色隨 power 變化等，與力道綁定的回饋移除或改為固定態（launcher 後座力 `play_launcher_recoil` 可保留為發射回饋）。
3. **HUD 調整**：power label / power bar 若僅服務集氣，移除或改用途；不得留下誤導玩家「可控力道」的 UI。
4. **瞄準回饋強化（輕量）**：確保發射前瞄準軌跡清楚可讀（沿用 `aim_preview` 參數；如需微調預覽點數 / 步長，數值進 `Data/feel.json`）。**不新增玩法**。

## 不做範圍（嚴禁）

- ❌ 不改任何傷害 / HP / 球數 / 倍率 / 敵人 / 抽取規則與數值。
- ❌ 不碰彈跳物理（gravity / bounce / peg_bounce_boost）——屬卡 16。
- ❌ 不實作拉弓 / 力道 / 任何 Q-031 已排除的替代控制。
- ❌ 不刪除 `player.json` 既有欄位（只標 deprecated）。
- ❌ 不做 Review P1 / P2。

## 預期產出

- `Scripts/Battle.gd`：簡化後的發射輸入（單鍵、固定速度、只控方向）；移除集氣狀態與其表現接線。
- `Scripts/BattleFX.gd`：移除 / 中性化 `update_charge_feedback` 等力道綁定回饋（保留發射後座力）。
- `Scenes/Battle.tscn`：power bar / label 視 UI 調整（移除或改用途）。
- `Data/player.json`：力道集氣欄位標記 deprecated（不刪）。
- `Data/feel.json`：`charge` 區段視情況標記停用 / 保留；aim preview 如有微調。
- 更新 `CHANGELOG.md`、`PROGRESS_REPORT.md`、`WORK_PLAN.md`。

## 驗收條件（DoD）

- [ ] 發射為「瞄準方向 + 單鍵」一步完成；無集氣條、無力道擺動、無 timing。
- [ ] 每球以固定 `launch_speed`(取自 `player.json`) 發射；程式未寫死速度。
- [ ] 瞄準軌跡清楚可讀；玩家能據角度規劃彈跳。
- [ ] 無殘留誤導「可控力道」的 UI / 文字。
- [ ] 傷害 / 平衡 / 球數 / 敵人規則完全未變；一整局（5 場 + 4 升級）可穩定跑完。
- [ ] `player.json` 的 `launch_speed_min/max` / `charge_cycle_seconds` 已標 deprecated 且未被刪除；`Data/*.json` 解析通過。
- [ ] Godot 載入無錯、export 可獨立執行。

## 禁止事項

- ❌ 不得偏離 Q-031 決議 A（不得保留力道、不得改其他控制模型）。
- ❌ 不得擅自改寫 `Docs/`（Docs 修訂屬人類；你只提醒）。
- ❌ 不得順手改物理 / 平衡 / 其他模組。

## 完成後

- 依 DoD 自驗、更新 `CHANGELOG.md`、產出 `PROGRESS_REPORT.md`。
- 回報：發射手感是否更貼「算好角度」、瞄準回饋是否足夠、deprecated 欄位清單、建議下一張卡（Review P1：敵人存在感與結算因果）。
- 提醒人類：補上 `Docs/02_GAME_DESIGN.md` 的 Q-031 修訂；實機確認新控制手感。
