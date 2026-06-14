# 任務卡 14 — SCENE POLISH（場景視覺打磨：發光 / bumper / HUD 字體 / 敵人區）

> 美術 / 打磨軌道。先讀 `Codex/00_MASTER_PROMPT.md`。
> 目標：提升戰鬥場景的「霓虹資料介面」質感——強化釘 / 球發光、底排 bumper 改霓虹環、HUD 換字體並改成資料面板、敵人區整合。**純程序化 + 一個字體，不改玩法 / 數值。**
>
> 決策依據見 OPEN_QUESTIONS **Q-027**。

---

## 鐵律
- **純程序化 + 字體**：用 shader / WorldEnvironment glow / `Light2D` / `GPUParticles2D` / `Line2D` / `Tween` + `assets/fonts/JiangChengJianRenHei.ttf`。**不新增其他外部美術素材**。
- **不改玩法 / 數值 / 規則 / 種類**；不動傷害、HP、球池、敵人、抽取、過載等。
- **保留 fallback**：缺字體 / 缺圖時回到現狀，不崩。
- **數值資料化**：新增強度 / 顏色 / 時間參數放 `Data/feel.json`（建議 `scene_fx`、`hud`、`enemy_display` 等區段）。
- **效能優先**：釘子數量多（27+），**不要每顆各放一個 `Light2D`**；優先用 WorldEnvironment glow 調整 + 輕量脈動（modulate / scale Tween）或加性 halo，維持穩定幀率與 export 可用。

## 任務範圍（要做）

### ① 釘 / 球發光強化
- 釘子：在現有中性底圖 + 類型 `modulate` 之上，加**亮核 + 外暈**與**待機微脈動**（alpha / scale 緩動）。整體靠 WorldEnvironment glow 提升通透感。
- 球：強化光暈與拖尾，確保飛行時醒目。
- **保留**：類型上色、命中閃白、過載金色、data-driven 半徑縮放全部不變。
- 強度 / 脈動參數進 `feel.json`。

### ② 底排 bumper 改霓虹發光環
- 底排 `bounce_peg` 改以**程序化霓虹發光環**呈現（如 `Line2D`/`draw_arc`/`Polygon2D` 環 + glow），取代目前灰齒輪外觀。
- 命中時環脈動 / 亮一下，凸顯「強力彈射台」身分。
- **碰撞行為與 `bounce_multiplier` 不變**（只改外觀）。

### ③ HUD 資料面板 + 字體
- 建立 Theme 套用 `assets/fonts/JiangChengJianRenHei.ttf` 到**全部 UI**（Label / Button），取代系統字。
- 把左上資訊（HP / 敵 HP / 回合 / 本回合傷害 / 剩餘球 / POWER / OVERCLOCK）整理成**對齊一致的資料面板**：bar 與外框對齊、加刻度感、用顏色編碼（HP 紅、POWER 青、OVERCLOCK 金 / 洋紅）。
- bar frame 與 bar 本體對齊、不再鬆散雙線。
- 不改任何數值來源，只改呈現。

### ④ 敵人區整合
- 敵人立繪適度放大；**敵人血條 + 名稱移到立繪下方**（與立繪同區），不再只靠左上文字。
- 加底座 / 框與**待機微浮動**（緩動上下 / 脈動）。
- 受擊 flash / 抖動沿用。

### 選配（行有餘力，risk 低）
- ⑤ 場地深度：play field 加極淡 vignette + 低對比資料流粒子；兩側漏球道加危險暗示。**維持低對比、不搶釘 / 球。**
- ⑥ 瞄準線改虛線發光 + 落點准心。

## 不做範圍（嚴禁）
- ❌ 不改玩法 / 數值 / 規則 / 種類（純表現）。
- ❌ 不新增外部美術素材（字體除外）；bumper 用程序化、不重生 PNG。
- ❌ 不每顆釘放 Light2D 等高耗效能做法；不犧牲幀率 / export。
- ❌ 不破壞既有 modulate / flash / 過載 / fallback。

## 預期產出
- `assets/fonts/` 字體經 Theme 套用（新增 `*.tres` theme 或在場景設定）。
- `Data/feel.json`：`scene_fx` / `hud` / `enemy_display` 等新參數。
- `Scripts/BattleFX.gd` / `Peg.gd` / `Ball.gd` / `Battle.gd` / `Scenes/Battle.tscn`：發光、bumper 環、HUD 面板、敵人區整合。
- 更新 `CHANGELOG.md`、產出 `PROGRESS_REPORT.md`。

## 驗收條件（DoD）
- [ ] 釘 / 球明顯更發光、有待機脈動；類型色 / 命中閃白 / 過載金 / 半徑縮放仍正確。
- [ ] 底排 bumper 為霓虹發光環、命中脈動；碰撞與 `bounce_multiplier` 行為不變。
- [ ] 全 UI 套用 JiangChengJianRenHei 字體；HUD 對齊、有刻度與顏色編碼、bar frame 不鬆散。
- [ ] 敵人立繪放大、血條 / 名稱移至立繪下方、有待機浮動；受擊回饋仍有效。
- [ ] 缺字體 / 缺圖可 fallback、不崩；幀率穩定（無逐釘 Light2D 之類重做法）；export（1024²）正常。
- [ ] 未改任何玩法 / 數值；一整局仍可穩定跑完；Godot 載入無錯、`Data/*.json` 可解析。

## 禁止事項
- ❌ 以打磨之名改玩法 / 數值。
- ❌ 高耗效能特效拖垮幀率。
- ❌ 偏離 Q-027；如需擴張先回 `OPEN_QUESTIONS.md` 提案。

## 完成後
- 依 DoD 自驗、更新 `CHANGELOG.md`、產出 `PROGRESS_REPORT.md`。
- 提醒人類用 vulkan（編輯器 ▶ 或重新 export）**可視化驗收**發光強度、字體、HUD 對齊與敵人區構圖；體感不對只調 `feel.json`。下一張：`Codex/13_ART_UPGRADE_ICONS.md`（升級 icon）。
