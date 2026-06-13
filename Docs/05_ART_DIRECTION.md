# 05 — ART DIRECTION 美術方向

> 原則：**用最少的美術成本，達到最高的「賽博發光」辨識度。** 優先使用 Godot 內建效果（Glow、粒子、Shader），避免大量手繪資產與複雜動畫，確保現場穩定展示。

---

## 霓虹賽博風定義（Neon Cyber）

- 世界觀：玩家是一團能量體，潛入賽博空間的奈米地下城，對抗病毒、防火牆、核心程式。
- 視覺關鍵字：**暗底高光、發光線條、資料介面感、能量脈衝、機械病毒**。
- 整體像是在操作一個會發光的偵錯 / 資料視覺化介面，而不是寫實場景。
- 動態優先於貼圖：能用發光、粒子、拖尾表現的，就不用靜態圖。

## 色彩方向（Palette）

- **背景**：純黑或極深色（#000000 ~ #0A0E14），保留發光對比空間。
- **主能量色（玩家 / 球）**：青藍 cyan（#00E5FF）、電光藍。
- **危險 / 敵人色**：洋紅 magenta（#FF2D95）、警示紅（#FF3B3B）。
- **正面回饋（補血 / 增益）**：螢光綠（#39FF14）。
- **強調 / 倍傷**：金黃 / 琥珀（#FFC83D）。
- 規則：**一個畫面主色不超過 2–3 種發光色**，避免過曝糊成一團。黑底 + 高飽和高亮 + 少量白。

### Peg 顏色建議（對應 `pegs.json`）
| Peg | 色 |
| --- | --- |
| Normal Peg | 青藍 cyan |
| Burst Peg | 橙紅（爆裂感） |
| Heal Peg | 螢光綠 |
| Double Peg | 金黃琥珀 |

## UI 風格

- 簡潔、霓虹、**工程感 / 資料介面感**：細線框、單線字重、等寬或科技感字體。
- 數值用「儀表 / 終端機」呈現（HP 條帶刻度、傷害以跳動數字、回合以計數器）。
- 半透明深色面板 + 發光描邊，避免實心大色塊。
- 動效克制：數字跳出、條漸變即可，不做花俏轉場（保穩定）。

## 敵人視覺方向

- 三類：**病毒（Virus）/ 防火牆（Firewall）/ 核心程式（Core）**。
- 風格：賽博機械風插圖，發光線條 + 幾何 + 故障（glitch）感。
- 病毒：有機 × 機械混合、扭動、洋紅。
- 防火牆：方正、護盾感、橙紅格柵。
- 核心程式（Boss）：龐大、對稱、多層發光環、權威感、warning 紅。
- 立繪可用 AI 生成（見下），以單張 PNG（透明背景）置於 `EnemyDisplay`，受擊時加閃白 / 抖動，不需逐幀動畫。

## Godot 內建效果使用建議

- **WorldEnvironment + Glow**：開啟 Glow（bloom）讓亮色節點與球自然發光，是本風格核心，成本低。
- **CPUParticles2D / GPUParticles2D**：命中爆出火花、球拖尾、Peg 環境微粒。
- **Line2D + 漸變**：瞄準線、球拖尾、UI 描邊。
- **CanvasItem Shader（選用）**：故障 glitch、掃描線、能量脈動，可後期 Phase 5 再加。
- **Tween**：受擊閃白、數字跳出、面板淡入，取代逐幀動畫。
- 原則：先用內建達到 80% 效果，行有餘力再寫 shader，**不可為特效犧牲穩定幀率**。

## AI 圖像生成 Prompt 原則

用於敵人立繪、icon、背景貼圖時：

1. **統一風格描述前綴**：固定一段風格詞，確保多張圖一致。
   - 範例前綴：`neon cyberpunk, dark black background, glowing cyan and magenta energy lines, geometric mechanical, data-interface aesthetic, high contrast, flat vector-ish, centered, transparent background`
2. **單一主體、留邊**：一張圖只一個敵人，置中、四周留空，方便去背與縮放。
3. **指定用途與尺寸**：如「敵人立繪，正方形，1024×1024，透明背景」。
4. **避免**：寫實光影、複雜場景、文字、浮水印、3D 渲染感（除非刻意）。
5. **可控變體**：先定一張 base，再用「same style, but a firewall guardian / a virus swarm / a core program boss」產出系列，維持一致性。
6. **產物入庫規則**：生成圖放專案 `assets/`（未來建立），檔名對應 `enemies.json` 的 `id`（如 `virus_01.png`），方便程式以 id 取圖。
7. **版權與可重現**：記錄使用的 prompt 與工具於 `CHANGELOG.md` 或 assets 旁的說明，方便重生成。

> 美術是「加分項」，不是 Demo 成敗關鍵。任何美術需求若拖慢可運行進度，先用純色 + Glow 占位，把資源留給流程穩定。
