# 任務卡 09 — GAME FEEL（轉場、回合節奏與反饋打磨）

> 打磨軌道。先讀 `Codex/00_MASTER_PROMPT.md`。
> 目標：**在純色 placeholder 上把「成品感」補齊**——柔化轉場、加入回合節奏、強化各種反饋。**不加玩法、不碰美術、不改任何平衡數值。**
>
> 排程：Phase 8 之後、美術之前。決策依據見 OPEN_QUESTIONS **Q-021**（已決議）。

---

## 核心紀律

- **純表現層**：本卡只做視覺 / 聽覺 / 時間節奏的回饋，**不得改動任何玩法數值或規則**（傷害、HP、倍率、抽取、球池、敵人皆不變）。
- **資料化**：所有新增的時間 / 強度 / 開關參數一律進 `Data/feel.json`（如 `transitions`、`turn_pacing`、`combo`、`telegraph`、`low_hp`、`charge`、`reroll_flash` 區段）。
- **穩定優先**：任何效果不得犧牲穩定幀率或既有流程；可被關閉 / 不應卡住狀態機。
- 盡量複用既有 `BattleFX`；新表現邏輯集中於 `BattleFX` 或對應 UI 節點，不把它塞回 `Battle.gd` 的規則區。

## 任務範圍（要做）

### 基本盤
1. **轉場柔化**：MainMenu / Battle / UpgradeScreen / GameOver / Victory 之間以淡入淡出（或快速 wipe）取代硬切。用一個共用過場（CanvasLayer + ColorRect + Tween 或 SceneTransition helper）。
2. **回合節奏（beats）**：在 `SETTLE → ENEMY_TURN → CHECK → ROUND_START` 之間插入**短暫、有反饋的停頓**（用計時器 / await），避免一幀內全部發生。停頓秒數進 `feel.json`。
3. **敵人攻擊三拍**：預兆（wind-up：敵人前傾 / 閃爍 / 警示）→ 衝擊（命中瞬間：玩家受擊閃紅 + shake + 數字）→ 收手（短暫回復）。三段時間資料化。
4. **受擊反饋**：敵人受傷時閃白 + 輕抖、HP 條順移（沿用 tween）；玩家受擊強化現有回饋。
5. **結算戲劇性**：本回合總傷害數字 **count-up**，敵人 HP 分段下降而非瞬減。
6. **回合提示**：「你的回合 / 敵人回合」短橫幅或字樣淡入淡出。

### 追加反饋（Q-021 A–G）
- **A 連擊 / 彈跳升階反饋**：單顆球連續命中時，命中回饋逐步加強（粒子變大 / 音高上升 / 輕微累積）。**純表現，不改傷害**；可顯示「combo ×N」字樣。combo 計數於該球回收後重置。
- **B Boss 必殺預兆**：Boss 將施放 special（每 `every_n_rounds`）的該回合，**事前明顯 telegraph**（警示橫幅「核心過載 來襲」+ 紅色閃光 / 較強 shake），再進入攻擊三拍。
- **C 低血警示**：玩家 HP 低於門檻（如 ≤25%，門檻進 `feel.json`）時，畫面邊緣紅色 vignette 脈動。
- **D 失球 / 漏球反饋**：球落底時，若該球本趟命中極少（門檻可設），給輕量「可惜 / miss」提示（暗色字 / 低音）；正常落底維持現有回饋。
- **E 集氣手感**：集氣表上升時音高 / 視覺漸強；發射瞬間 launcher 輕微後座力（位移回彈）。
- **F 升級卡 juice**：UpgradeScreen 卡片 hover 放大 / 發光、選定時脈動確認感。
- **G 釘盤重組輕量閃光**：每回合 ROUND_START 重抽動態釘類型時，釘子做一個**輕量快閃**（淡白 / 縮放彈一下）點出「重組」，呼應賽博自我重構主題。**僅輕量閃光、不做複雜漸變**，不得影響穩定或拖慢回合開始。

## 不做範圍（嚴禁）

- ❌ 不加任何玩法 / 種類 / 機制；不改傷害、HP、倍率、抽取、球池、敵人等規則與數值。
- ❌ 不做美術素材（立繪 / icon / 背景貼圖）——維持現有純色 + Glow 占位。
- ❌ combo 不得成為傷害加成（純表現）。
- ❌ 不做複雜漸變 / 大型動畫；G 僅輕量閃光。
- ❌ 不重構與表現無關的模組；不把表現邏輯與規則邏輯混在一起。

## 預期產出

- `Data/feel.json`：新增 `transitions / turn_pacing / enemy_attack / combo / telegraph / low_hp / charge / drain / reroll_flash / upgrade_card` 等參數區段。
- 共用場景過場 helper（淡入淡出）。
- `Scripts/BattleFX.gd`（與必要 UI 節點）：combo、telegraph、低血 vignette、漏球、重組閃光、結算 count-up 等表現。
- `Scripts/Battle.gd`：回合 beats 的節奏停頓接線（不改規則，只加時序）；敵人攻擊三拍時序。
- `Scenes/Battle.tscn` / `UpgradeScreen.tscn`：vignette、橫幅、卡片 juice 等節點。
- 更新 `CHANGELOG.md`、產出 `PROGRESS_REPORT.md`。

## 驗收條件（DoD）

- [ ] 場景切換為淡入淡出，無硬切。
- [ ] 結算→敵攻→下一回合之間有可感知的節奏停頓，不再一瞬完成。
- [ ] 敵人攻擊有預兆→衝擊→收手三拍；Boss 必殺有明顯事前 telegraph。
- [ ] 敵人受傷有閃白/抖動、HP 順移；結算總傷 count-up。
- [ ] 連擊升階反饋可見（純表現，傷害數值未變，可驗證傷害公式不受影響）。
- [ ] 低血時邊緣紅脈動；漏球有輕量提示；集氣有音高/視覺漸強 + 發射後座力；升級卡有 hover/選定回饋。
- [ ] 每回合重組有輕量閃光，且不拖慢回合開始、不卡狀態機。
- [ ] 所有新參數來自 `feel.json`；關掉 SFX 仍正常；幀率穩定。
- [ ] 既有玩法 / 平衡完全不變；一整局（5 場 + 4 次升級）仍可穩定跑完。
- [ ] Godot 載入無錯、`Data/*.json` 解析通過、export 在 1024×1024 可獨立執行。

## 禁止事項

- ❌ 不得以打磨之名改動任何玩法數值 / 規則。
- ❌ 不得引入美術素材或非目標功能。
- ❌ 不得讓 combo / 特效變成傷害或機制。
- ❌ 不得偏離 Q-021；如需擴張先回 `OPEN_QUESTIONS.md` 提案。

## 完成後

- 依本卡 DoD 自驗、更新 `CHANGELOG.md`、產出 `PROGRESS_REPORT.md`。
- 提醒人類：節奏停頓與反饋強度是體感項，**務必實機驗收**並可只調 `feel.json` 微調快慢 / 強弱。下一條軌道為美術 Pass。
