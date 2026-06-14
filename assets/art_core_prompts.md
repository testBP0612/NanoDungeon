# ART CORE Prompts

Generated for `Codex/12_ART_CORE.md` with `generate2dsprite` / built-in image generation on 2026-06-14.

Style anchor:
`neon cyberpunk game asset, pure transparent background, glowing cyan and magenta energy lines, geometric mechanical, data-interface aesthetic, high contrast, flat vector-like, crisp clean edges, centered, single subject, no text, no watermark`

Assets:
- `assets/enemies/core_program.png`: large symmetric dungeon-core entity, multiple glowing concentric rings, warning red and magenta, authoritative, imposing.
- `assets/enemies/virus_scout.png`: small agile reconnaissance virus drone, simple geometric body, glowing magenta core with cyan circuit accents.
- `assets/enemies/virus_crawler.png`: segmented self-replicating crawling virus, aggressive, pink/magenta luminous core segments.
- `assets/enemies/firewall_sentinel.png`: blocky armored firewall guardian, shield grid, orange-red firewall glow with cyan circuitry.
- `assets/enemies/virus_swarm.png`: many tiny micro-virus units forming one coherent swarm silhouette.
- `assets/pegs/peg_base.png`: neutral white/grey glowing circular energy node token for runtime tinting.
- `assets/balls/ball_base.png`: neutral white glowing energy pulse orb for runtime tinting.
- `assets/bg/menu_bg.png`: dark cyber space backdrop, subtle circuit grid, low brightness, clear central title area.
- `assets/bg/battle_bg.png`: very dark cyber backdrop, faint data grid, minimal and low contrast.
- `assets/ui/bar_frame.png`: thin neon rectangular HUD frame, hollow center, cyan border.
- `assets/ui/logo.png`: cyber pinball dungeon emblem/sigil only; title text remains engine-rendered.

Postprocess:
- Image outputs that baked a checkerboard into RGB were converted to RGBA by deterministic edge flood-fill cleanup.
- Enemy, peg, ball, and logo assets were resized to 1024 x 1024. Backgrounds were resized to 1024 x 1024 and kept opaque.
