#include "../../backends/imgui_impl_null.cpp"
#include "../../backends/imgui_impl_null.h"
#include "../libs/emscripten/emscripten_mainloop_stub.h"
#include "../stb/stb_image_write.h"
#include "imgui.h"
#include "imgui_freetype.h"
#include "imgui_impl_allegro5.h"
#include "imgui_impl_android.h"
#include "imgui_impl_dx10.h"
#include "imgui_impl_dx11.h"
#include "imgui_impl_dx12.h"
#include "imgui_impl_dx9.h"
#include "imgui_impl_glfw.h"
#include "imgui_impl_glut.h"
#include "imgui_impl_null.h"
#include "imgui_impl_opengl2.h"
#include "imgui_impl_opengl3.h"
#include "imgui_impl_opengl3_loader.h"
#include "imgui_impl_sdl2.h"
#include "imgui_impl_sdl3.h"
#include "imgui_impl_sdlgpu3.h"
#include "imgui_impl_sdlgpu3_shaders.h"
#include "imgui_impl_sdlrenderer2.h"
#include "imgui_impl_sdlrenderer3.h"
#include "imgui_impl_vulkan.h"
#include "imgui_impl_wgpu.h"
#include "imgui_impl_win32.h"
#include "imgui_internal.h"
#include "imgui_internal.h"     // ImMin,ImMax,ImFontAtlasBuild*,
#include "imgui_stdlib.h"
#include "imgui_user.inl"
#include "imstb_rectpack.h"
#include "imstb_textedit.h"
#include "imstb_truetype.h"
#include "misc/freetype/imgui_freetype.h"
#include "stb_sprintf.h"
#include <Carbon/Carbon.h>  // Use old API to avoid need for separate .mm file
#include <Cocoa/Cocoa.h>
#include <EGL/egl.h>
#include <GL/freeglut.h>
#include <GL/gl.h>
#include <GLES2/gl2.h>
#include <GLES2/gl2.h>          // Use GL ES 2
#include <GLES2/gl2ext.h>
#include <GLES3/gl3.h>
#include <GLES3/gl3.h>          // Use GL ES 3
#include <GLFW/emscripten_glfw3.h>
#include <GLFW/glfw3.h>
#include <GLFW/glfw3.h> // Will drag system OpenGL headers
#include <GLFW/glfw3native.h>
#include <GLUT/glut.h>
#include <OpenGL/gl.h>
#include <OpenGLES/ES2/gl.h>    // Use GL ES 2
#include <OpenGLES/ES3/gl.h>    // Use GL ES 3
#include <QuartzCore/CAMetalLayer.h>
#include <SDL.h>
#include <SDL3/SDL.h>
#include <SDL3/SDL_opengl.h>
#include <SDL3/SDL_opengles2.h>
#include <SDL3/SDL_vulkan.h>
#include <SDL_opengl.h>
#include <SDL_opengles2.h>
#include <SDL_syswm.h>
#include <SDL_vulkan.h>
#include <TargetConditionals.h>
#include <Windows.h>        // _wfopen, OpenClipboard
#include <allegro5/allegro.h>
#include <allegro5/allegro_primitives.h>
#include <allegro5/allegro_windows.h>
#include <android/asset_manager.h>
#include <android/input.h>
#include <android/keycodes.h>
#include <android/log.h>
#include <android/native_window.h>
#include <android_native_app_glue.h>
#include <assert.h>
#include <cstring>      // memcpy
#include <ctype.h>          // toupper
#include <d3d10.h>
#include <d3d10_1.h>
#include <d3d11.h>
#include <d3d12.h>
#include <d3d9.h>
#include <d3dcompiler.h>
#include <dwmapi.h>
#include <dxgi1_5.h>
#include <dxgidebug.h>
#include <emscripten.h>
#include <emscripten/em_js.h>
#include <emscripten/html5.h>
#include <emscripten/html5_webgpu.h>
#include <emscripten/version.h>     // __EMSCRIPTEN_major__ etc.
#include <ft2build.h>
#include <imm.h>
#include <inttypes.h>       // PRId64/PRIu64, not avail in some MinGW headers.
#include <limits.h>
#include <limits.h>         // INT_MIN, INT_MAX
#include <lunasvg.h>
#include <math.h>           // sqrtf, powf, cosf, sinf, floorf, ceilf
#include <plutosvg.h>
#include <shellapi.h>   // ShellExecuteA()
#include <stdint.h>
#include <stdint.h>         // intptr_t
#include <stdint.h>     // intptr_t
#include <stdint.h>     // uint64_t
#include <stdio.h>
#include <stdio.h>              // for snprintf()
#include <stdio.h>              // printf
#include <stdio.h>          // printf, fprintf
#include <stdio.h>          // vsnprintf, sscanf, printf
#include <stdio.h>      // vsnprintf, sscanf, printf
#include <stdlib.h>
#include <stdlib.h>         // NULL, malloc, free, atoi
#include <stdlib.h>         // abort
#include <string.h>
#include <string>
#include <sys/wait.h>
#include <tchar.h>
#include <time.h>
#include <unistd.h>
#include <unistd.h>             // for usleep()
#include <volk.h>
#include <webgpu/webgpu.h>
#include <webgpu/webgpu_cpp.h>
#include <windows.h>
#include <windows.h>        // SetProcessDPIAware()
#include <windowsx.h> // GET_X_LPARAM(), GET_Y_LPARAM()
#include <xinput.h>
#include FT_BBOX_H              // <freetype/ftbbox.h>
#include FT_FREETYPE_H          // <freetype/freetype.h>
#include FT_GLYPH_H             // <freetype/ftglyph.h>
#include FT_MODULE_H            // <freetype/ftmodapi.h>
#include FT_OTSVG_H             // <freetype/otsvg.h>
#include FT_SIZES_H             // <freetype/ftsizes.h>
#include FT_SYNTHESIS_H         // <freetype/ftsynth.h>
#include IMGUI_STB_RECT_PACK_FILENAME
#include IMGUI_STB_SPRINTF_FILENAME
#include IMGUI_STB_TRUETYPE_FILENAME
