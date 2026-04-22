# Sketchy 2.5D Diorama — Pipeline Cheat Sheet
**Blender → Painted textures → Godot**

---

## 0. Pick these five things before you touch anything

Lock these in a `style_bible.md` in your repo and never break them:

| Decision | My recommendation for your scene | Why |
|---|---|---|
| **Texel density** | 64–128 px per Blender meter | Sets stroke weight consistency across the whole game |
| **Line weight** | ~2 px at your chosen density | Every asset must match. Measure your brush once, write it down. |
| **Palette size** | ~24–32 colors total for the game | Forces cohesion — like a watercolor set |
| **Line color** | Dark brown (#2a1a0f) not black | Black lines fight with sprite outlines and feel flat |
| **Up-axis in Blender** | Z-up, export with "+Y up" for Godot | Default glTF convention |

---

## 1. Blender — modeling rules

- **Low poly, silhouette-first.** Cups: 8 sides. Pot body: 12 sides. Shelves: cubes. Stove base: cube.
- **Snap to a grid.** Increment 0.125m or 0.0625m. Set in `N panel → View → Grid`. Turn on grid snap (`Shift+Tab`).
- **One mesh = one material = one texture** when practical. Atlas small props together.
- **Apply all transforms before exporting** (`Ctrl+A → All Transforms`). Scale issues wreck Godot imports.
- **Shade Flat for hard surfaces**, Shade Auto-Smooth (~30°) for organic. Sketchy style does NOT want smooth normals everywhere.
- **No N-gons on deforming meshes.** Triangulate before export (`Ctrl+T`) to match what Godot will see.

---

## 2. UV unwrapping

1. Mark seams where edges are hidden (bottom of cup, back of shelf).
2. `U → Unwrap`, then `UV Editor → UV → Pack Islands` (margin 0.01).
3. **Check texel density** with the "Texel Density Checker" addon (free). Aim for your target, e.g. 128 px/m.
4. Export UV layout: `UV Editor → UV → Export UV Layout` as PNG, 1024×1024 or 2048×2048.

**Power-of-two textures only** (512, 1024, 2048). Godot will complain otherwise and mipmaps break.

---

## 3. Bake AO before painting (the secret sauce)

This is the single biggest quality jump for hand-painted assets.

1. In Blender, new image texture, 1024×1024, **black** background.
2. Render Properties → set to **Cycles** temporarily.
3. Add the new image to your material, select it (don't connect — just make it active).
4. `Render Properties → Bake → Bake Type: Ambient Occlusion`, samples 32, click Bake.
5. Save the AO map. This becomes a **multiply layer** under your painting.

Your crevices now have free shadow. Paint on top of it.

---

## 4. Painting — Blender Texture Paint mode

Since you want sketchy/drawn-directly, skip Aseprite. Workflow:

### Setup
- Switch workspace to **Texture Paint**.
- Left viewport: 3D paint view. Right: Image Editor showing the texture.
- Load your AO bake as a layer below your paint layer (via Image Editor → Image → New, or use a compositor-style setup with a Mix node).

### Brush kit
Build these 4 brushes once and reuse forever:

| Brush | Settings | Use |
|---|---|---|
| **Line** | Radius 4px, Strength 1.0, hard falloff, pressure OFF for radius | Outlines, hatching |
| **Fill** | Radius 40px, Strength 1.0, hard falloff | Base color blocks |
| **Rough** | Radius 8px, Strength 0.6, texture = noise or paper | Grunge, weathering |
| **Highlight** | Radius 6px, Strength 0.8, soft falloff | Rim light on edges |

### Painting order (per asset)
1. **Fill** flat base color on everything.
2. **Shadow pass** — pick a color 2 shades darker, paint into recesses (AO bake guides you).
3. **Midtone hatching** — cross-hatch shadows with the Line brush. 2–4 strokes per shadow area is enough.
4. **Highlight pass** — rim light on top edges where your key light hits (see §6 for light direction).
5. **Outline pass** — Line brush along silhouette edges in 3D view, following the form. Don't outline everything — only where shapes meet or where silhouette needs definition.
6. **Grunge pass** — Rough brush, sparingly. Adds life.

### Pro tips
- **Paint in the 3D view**, not the UV editor. You won't see seams.
- **Enable `Cavity` in the paint tool settings** for form-aware brushes.
- **Use `F` to resize brush, `Shift+F` for strength.**
- **Sample colors with `S`** to stay on palette.
- **`Ctrl+click` with the Line brush** draws a straight line between two points. Huge for crisp outlines.

---

## 5. Character sprites (2D) — keeping them consistent with 3D

Since your characters are sketchy 2D like the orc:

- **Resolution**: if your textures are ~128 px/m and characters in-game are ~1.7m tall, sprites should be around **220–256 px tall**. Bigger = chunky mismatch, smaller = washed out.
- **Same line weight** (~2px) and **same line color** as your 3D textures.
- **Billboard** them in Godot with a `Sprite3D` node, `billboard = enabled`, `pixel_size = 0.01` (tune to match scale).
- **Bake a drop shadow** into the ground with a decal or a separate flat quad — billboards don't cast great shadows on their own.

---

## 6. Blender → Godot export

### Export settings (glTF 2.0)
- Format: **glTF Binary (.glb)**
- Include: **Selected Objects** (be deliberate)
- Transform: **+Y Up** ✅
- Geometry: Apply Modifiers ✅, UVs ✅, Normals ✅, Tangents ✅ (only if you use normal maps — probably skip)
- Material: **Export**
- Animation: only if the asset has any

### Folder convention
```
project/
├─ assets/
│  ├─ models/        *.glb
│  ├─ textures/      *.png (the painted maps)
│  └─ sprites/       *.png (2D characters)
├─ materials/        *.tres (Godot materials)
└─ scenes/           *.tscn
```

---

## 7. Godot — the settings that sell the style

### Texture import (per PNG, in the Import dock)
- **Filter**: Nearest (if you want crisp pixel-y painted look) OR Linear (if your strokes are already anti-aliased and you want smooth scaling). For sketchy painted, **Linear is usually better** — crisp only if you're pixel-precise.
- **Mipmaps**: ON for 3D textures (prevents shimmering at distance), OFF for UI/sprites.
- **Compress Mode**: Lossless (during dev), VRAM Compressed (for ship).

### StandardMaterial3D settings
```
Albedo → your painted texture
Metallic → 0
Roughness → 1.0 (matte, no specular highlights fighting your painted ones)
Specular → 0 or very low
Shading Mode → Per-Pixel
Cull Mode → Back
```
Turn **off** any normal map, AO map, or ORM workflow — your painted texture already contains the lighting information you want.

### For sprite characters (Sprite3D)
```
Pixel Size: 0.01  (scale to taste)
Billboard: Enabled (or Y-Billboard if you want them to stay upright as camera tilts)
Transparent: On
Alpha Cut: Alpha Scissor (crisp edges, no fringing)
Texture Filter: Nearest (hard edges) or Linear (smooth)
Double Sided: On (so they don't vanish from behind)
```

---

## 8. Lighting & camera (this is 40% of the look)

### Camera
- **Perspective** camera, FOV **35–50°** (narrower than default — flattens the scene toward that diorama feel)
- **Angle**: pitched down **~30–45°** from horizontal
- **Position**: back and up, looking into the scene — think dollhouse viewer
- Enable **fog** lightly, warm tint, short range — gives atmospheric depth at almost no cost

### Lights
- **Key light**: DirectionalLight3D, warm (`#ffd9a8`), energy 1.2, angled down and slightly from the side so shadows fall into the scene
- **Fill**: cool ambient via WorldEnvironment, low intensity (`#3a4a66`, energy 0.3)
- **Rim / accent** (optional): a second DirectionalLight from opposite side, very low energy, cool color — edge-lights characters
- **Practical lights**: for your brewing scene specifically, an **OmniLight3D** inside the stove base, orange, low range — coals glow. Huge payoff.
- **Shadows ON** for the key light only. Keep softness low for a drawn feel.

### Environment / WorldEnvironment settings
- **Tonemap**: Filmic or AgX, exposure 1.0
- **Glow (Bloom)**: enabled, intensity 0.3–0.5, threshold 1.0 — subtle
- **DOF Far Blur**: enabled, distance tuned so the background softens slightly while the focal plane (characters) stays sharp. This is the **tilt-shift trick** and sells the diorama.
- **Adjustments**: slight saturation bump (1.1), slight contrast bump (1.05)
- **SSAO**: off — your painted AO already handles this, and SSAO fights hand-painted shadows

---

## 9. Scene-specific fixes for your brewing shot

Looking at your screenshot, in priority order:

1. **Texture the wood counter.** Flat untextured wood is the #1 thing killing the diorama feel. Paint plank seams, grain, a knot or two.
2. **Paint the cups.** Drop to 8 sides, fill mid-green, shadow the bottom interior, highlight the rim, one vertical hatch line on the near-facing side.
3. **Add a practical light in the stove.** Orange point light, range ~1m. Instant atmosphere.
4. **Bake AO on everything** before painting. Free depth.
5. **Tilt camera down more** (~35° from horizontal) and narrow the FOV to ~40°.
6. **Enable subtle DOF** in WorldEnvironment focused on the character plane.
7. **Character sprite filtering**: the orc looks soft — check it's not accidentally linear-filtering a crisp drawing.

---

## 10. Quick workflow checklist (per asset)

```
☐ Model low-poly, snap to grid
☐ Apply transforms
☐ UV unwrap, pack, check texel density matches bible
☐ Bake AO (1024² black, Cycles, 32 samples)
☐ Paint: fill → shadow → hatch → highlight → outline → grunge
☐ Save texture as PNG in /assets/textures/
☐ Export as .glb to /assets/models/
☐ Import in Godot, set material (no metallic, roughness 1, no SSAO)
☐ Drop in scene, verify under scene lighting
☐ Check from game camera angle specifically — not just perspective view
```

---

## 11. References to bookmark

- Acquire's HD-2D dev interviews on the Unreal Engine blog (the Octopath II one is especially good on camera technique)
- *Don't Starve* art breakdowns — closest style match to sketchy 2D + 3D
- Blender's "Grease Pencil" if you ever want to draw lines directly in 3D space (advanced, but worth knowing)
- Godot docs: `StandardMaterial3D`, `Sprite3D`, `WorldEnvironment`
