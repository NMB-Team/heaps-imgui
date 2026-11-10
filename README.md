# heaps-imgui

Build debug panels, editors, and in-game tools with Dear ImGui in Haxe. **heaps-imgui** binds [Dear ImGui v1.93.0-docking](https://github.com/ocornut/imgui/releases/tag/v1.93.0-docking) to HashLink and provides a renderer and input integration for Heaps.

[Quick start](#quick-start) · [Build from source](#build-from-source) · [Heaps integration](#heaps-integration) · [Troubleshooting](#troubleshooting)

## Quick start

You’ll need Haxe, HashLink, and a working Heaps project with a HashLink backend such as hlsdl or Limen.

1. Clone and register the Haxe library.

   ```sh
   git clone https://github.com/NMB-Team/heaps-imgui.git
   haxelib dev heaps-imgui heaps-imgui
   ```

2. Download the Windows or Linux archive from [Releases](../../releases), or [build the native module](#build-from-source). Use an archive that matches your platform, CPU architecture, and HashLink runtime. Copy **`imgui.hdll`** into the directory you launch the app from, or put it in your HashLink native library search path.
3. Add the library to your project’s HXML. Keep the Heaps and backend settings you already use.

   ```hxml
   -lib heaps-imgui
   ```

### Your first window

Use `ImGuiApp` in place of `hxd.App` to have Heaps handle ImGui input, frame setup, and rendering. Declare widgets each frame in `update()` and store application state on the app.

```haxe
import imgui.ImGui;
import imgui.ImGuiApp;

class Main extends ImGuiApp {
    var clicks = 0;

    static function main() {
        new Main();
    }

    override function update(dt:Float) {
        super.update(dt);

        if (ImGui.begin("Hello, ImGui")) {
            if (ImGui.button("Click me"))
                clicks++;

            ImGui.text('Clicks: ${clicks}');
        }

        ImGui.end();
    }
}
```

Call `ImGui.end()` after every `ImGui.begin()`, even when `begin()` returns `false`. Use `ImGui.showDemoWindow()` inside `update()` to explore widgets and settings.

To run this repository’s [sample](src/Main.hx), install Heaps and hlsdl, place `imgui.hdll` in the checkout root, and run:

```sh
haxe compile.hxml
hl imgui.hl
```

## Build from source

Install Git, CMake, a C/C++ toolchain with C++23 support, and HashLink with its development headers and library. Run these commands from the checkout root:

```sh
git submodule update --init --recursive
cmake -S extension -B extension/build -DCMAKE_BUILD_TYPE=Release
cmake --build extension/build --config Release
```

CMake copies the resulting `imgui.hdll` to the checkout root. The binary is also in the build directory, under `Release/` with multi-configuration generators such as Visual Studio.

If CMake cannot find HashLink, add `-DHASHLINK_ROOT=/path/to/hashlink` to the configure command. Point it at the installation containing `hl.h` and the HashLink library.

| CMake option | Default | Purpose |
| --- | --- | --- |
| `NODE_EDITOR` | `ON` | Build the node editor used by `imgui.NodeEditor` |
| `MARKDOWN` | `ON` | Build Markdown rendering used by `imgui.Markdown` |

Set an option at configure time, for example `-DNODE_EDITOR=OFF`. Enable each native add-on your Haxe code calls. When distributing your app, bundle the matching `imgui.hdll` and your Heaps backend’s native dependencies.

## Heaps integration

- **Existing render loop** — Use [`ImGuiDrawable`](imgui/ImGuiDrawable.hx) and manage frame timing yourself. The [manual integration example](src/Main.hx) shows the frame and input setup.
- **Textures and tiles** — Pass an `h3d.mat.Texture` to `ImGui.image()` or an `h2d.Tile` to `ImGui.imageTile()`.
- **Fonts** — After initializing Heaps resources, load a typed font resource with `ImGui.fonts.setDefault(hxd.Res.fonts.inter, 18)`, assuming your project contains that font. The API works with packed resources and also accepts raw bytes through `setDefaultBytes()`. The Heaps renderer manages the font textures.
- **Notifications** — Call `ImGui.notifications.success("Project saved")` to show a toast. Use the same notification `key` to replace an existing toast, or customize placement and timing through `ImGui.notifications.style`.
- **Platform viewports** — Build with `-D multidriver` to enable separate platform windows in `ImGuiApp` on compatible Heaps backends. Native Wayland can limit window positioning. If detached windows fail on Linux, try an X11 session or XWayland with an SDL backend.

### Editable values

Widgets like `inputText()` take a reference so they can update your value. Pass a local variable or a writable field.

```haxe
ImGui.inputText("Name", name);
```

For a getter/setter property, copy its value into a local and write it back when the widget reports a change. The [reference macros](imgui/ImGuiMacro.hx) provide `wref`, `wrefv`, and `wrefc` for this pattern.

Format strings in Haxe before passing them to widgets. For example, use `ImGui.text('FPS: $fps')` for a value you already computed.

## Troubleshooting

| Symptom | What to check |
| --- | --- |
| Haxe cannot find `heaps-imgui` | Run `haxelib path heaps-imgui` and confirm it points to the intended checkout. |
| HashLink cannot load `imgui.hdll` | Check the app’s working directory, the native library search path, and whether the HDLL matches the runtime and architecture. |
| HashLink reports a missing native function | Use the Haxe bindings and `imgui.hdll` from the same revision. Check whether the function needs an add-on enabled in CMake. |
| A build still refers to `hlimgui` | Update the dependency to `-lib heaps-imgui` and replace explicit `-D hlimgui` flags with `-D heaps-imgui`. The old define is accepted with a deprecation warning when the library is loaded. In Haxe code, use `#if heaps_imgui`. |

## Further reading

- [Dear ImGui FAQ](https://github.com/ocornut/imgui/blob/docking/docs/FAQ.md) for widget behavior, IDs, and input handling.

## Credits and license

Based on [haddock7’s HashLink binding](https://github.com/haddock7/hlimgui) which drew on [Aidan63’s Haxe/C++ bindings](https://github.com/Aidan63/linc_imgui). See the [binding license](LICENSE) and the [Dear ImGui license](LICENSE_IMGUI).
