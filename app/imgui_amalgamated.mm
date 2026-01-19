
// =============================================================================
// [USER CONFIGURATION CONTROL PANEL]
// =============================================================================
// 必要なバックエンドとサンプルを一つだけ有効化してください。
//
// --- BACKENDS ---
// #define IMGUI_BUILD_BACKEND_METAL
// #define IMGUI_BUILD_BACKEND_OSX
//
// --- EXAMPLES / MAIN FUNCTION ---
// #define IMGUI_BUILD_EXAMPLE_METAL
// =============================================================================

// =============================================================================
// [AMALGAMATION STEP 1: ABSOLUTE UNIFICATION - Objective-C++]
// =============================================================================

// @INCLUDES: システム標準ヘッダーとObjective-C++インポート


#import <Metal/Metal.h>
#import <Carbon/Carbon.h>
#import <Cocoa/Cocoa.h>
#import <GameController/GameController.h>
#import <Metal/Metal.h>
#import <QuartzCore/QuartzCore.h>
#import <time.h>
#include <SDL3/SDL.h>
#include <stdio.h>


// @MACROS_AND_SWITCHES: 全マクロ定義

#define APPLE_HAS_BUTTON_OPTIONS (__IPHONE_OS_VERSION_MIN_REQUIRED >= 130000 || __MAC_OS_X_VERSION_MIN_REQUIRED >= 101500 || __TV_OS_VERSION_MIN_REQUIRED >= 130000)
    #define IM_SATURATE(V)                        (V < 0.0f ? 0.0f : V > 1.0f ? 1.0f : V)
    #define MAP_ANALOG(KEY_NO, AXIS_NAME, V0, V1) { float vn = (float)(gp.AXIS_NAME.value - V0) / (float)(V1 - V0); vn = IM_SATURATE(vn); io.AddKeyAnalogEvent(KEY_NO, vn > 0.1f, vn); }
    #define MAP_BUTTON(KEY_NO, BUTTON_NAME)       { io.AddKeyEvent(KEY_NO, gp.BUTTON_NAME.isPressed); }
#define APPLE_HAS_CONTROLLER     (__IPHONE_OS_VERSION_MIN_REQUIRED >= 140000 || __MAC_OS_X_VERSION_MIN_REQUIRED >= 110000 || __TV_OS_VERSION_MIN_REQUIRED >= 140000)
#define APPLE_HAS_THUMBSTICKS    (__IPHONE_OS_VERSION_MIN_REQUIRED >= 120100 || __MAC_OS_X_VERSION_MIN_REQUIRED >= 101401 || __TV_OS_VERSION_MIN_REQUIRED >= 120100)


// @TYPES_AND_GLOBALS: 全ての enum, struct, class の定義本体 (Objective-C++の複雑さのため、今回は省略)



// @PROTOTYPES_AND_INLINES: 全関数の宣言、インライン関数、および遅延初期化関数
// --- DELAYED STATIC INITIALIZATION FUNCTIONS ---


// --- INLINE FUNCTIONS ---

static inline CFTimeInterval    GetMachAbsoluteTimeInSeconds()      { return (CFTimeInterval)(double)(clock_gettime_nsec_np(CLOCK_UPTIME_RAW) / 1e9); }

#ifdef IMGUI_IMPL_METAL_CPP

#pragma mark - Dear ImGui Metal C++ Backend API

bool ImGui_ImplMetal_Init(MTL::Device* device)
{
    return ImGui_ImplMetal_Init((__bridge id<MTLDevice>)(device));
}


static inline CFTimeInterval    GetMachAbsoluteTimeInSeconds()      { return (CFTimeInterval)(double)(clock_gettime_nsec_np(CLOCK_UPTIME_RAW) / 1e9); }

// Forward Declarations
static void ImGui_ImplOSX_AddTrackingArea(NSView* _Nonnull view);
static bool ImGui_ImplOSX_HandleEvent(NSEvent* event, NSView* view);

// Undocumented methods for creating cursors.
@interface NSCursor()
+ (id)_windowResizeNorthWestSouthEastCursor;
+ (id)_windowResizeNorthEastSouthWestCursor;
+ (id)_windowResizeNorthSouthCursor;
+ (id)_windowResizeEastWestCursor;
+ (id)busyButClickableCursor;
@end

/**
 KeyEventResponder implements the NSTextInputClient protocol as is required by the macOS text input manager.

 The macOS text input manager is invoked by calling the interpretKeyEvents method from the keyDown method.
 Keyboard events are then evaluated by the macOS input manager and valid text input is passed back via the
 insertText:replacementRange method.

 This is the same approach employed by other cross-platform libraries such as SDL2:
  https://github.com/spurious/SDL-mirror/blob/e17aacbd09e65a4fd1e166621e011e581fb017a8/src/video/cocoa/SDL_cocoakeyboard.m#L53
 and GLFW:
  https://github.com/glfw/glfw/blob/b55a517ae0c7b5127dffa79a64f5406021bf9076/src/cocoa_window.m#L722-L723
 */
@interface KeyEventResponder: NSView<NSTextInputClient>
@end

@implementation KeyEventResponder
{
    float _posX;
    float _posY;
    NSRect _imeRect;
}



// @IMPLEMENTATION: 通常関数のロジック本体


#if defined(IMGUI_BUILD_BACKEND_METAL)
// --- SANDBOX START: imgui_impl_metal.mm ---
#pragma pack(push)
#pragma warning(push)
// [SOURCE: imgui_impl_metal.mm]
// dear imgui: Renderer Backend for Metal
// This needs to be used along with a Platform Backend (e.g. OSX)

// Implemented features:
//  [X] Renderer: User texture binding. Use 'MTLTexture' as texture identifier. Read the FAQ about ImTextureID/ImTextureRef!
//  [X] Renderer: Large meshes support (64k+ vertices) even with 16-bit indices (ImGuiBackendFlags_RendererHasVtxOffset).
//  [X] Renderer: Texture updates support for dynamic font atlas (ImGuiBackendFlags_RendererHasTextures).

// You can use unmodified imgui_impl_* files in your project. See examples/ folder for examples of using this.
// Prefer including the entire imgui/ repository into your project (either as a copy or as a submodule), and only build the backends you need.
// Learn about Dear ImGui:
// - FAQ                  https://dearimgui.com/faq
// - Getting Started      https://dearimgui.com/getting-started
// - Documentation        https://dearimgui.com/docs (same as your local docs/ folder).
// - Introduction, links and more at the top of imgui.cpp

// CHANGELOG
// (minor and older changes stripped away, please see git history for details)
//  2025-09-18: Call platform_io.ClearRendererHandlers() on shutdown.
//  2025-06-11: Added support for ImGuiBackendFlags_RendererHasTextures, for dynamic font atlas. Removed ImGui_ImplMetal_CreateFontsTexture() and ImGui_ImplMetal_DestroyFontsTexture().
//  2025-02-03: Metal: Crash fix. (#8367)
//  2025-01-08: Metal: Fixed memory leaks when using metal-cpp (#8276, #8166) or when using multiple contexts (#7419).
//  2022-08-23: Metal: Update deprecated property 'sampleCount'->'rasterSampleCount'.
//  2022-07-05: Metal: Add dispatch synchronization.
//  2022-06-30: Metal: Use __bridge for ARC based systems.
//  2022-06-01: Metal: Fixed null dereference on exit inside command buffer completion handler.
//  2022-04-27: Misc: Store backend data in a per-context struct, allowing to use this backend with multiple contexts.
//  2022-01-03: Metal: Ignore ImDrawCmd where ElemCount == 0 (very rare but can technically be manufactured by user code).
//  2021-12-30: Metal: Added Metal C++ support. Enable with '#define IMGUI_IMPL_METAL_CPP' in your imconfig.h file.
//  2021-08-24: Metal: Fixed a crash when clipping rect larger than framebuffer is submitted. (#4464)
//  2021-05-19: Metal: Replaced direct access to ImDrawCmd::TextureId with a call to ImDrawCmd::GetTexID(). (will become a requirement)
//  2021-02-18: Metal: Change blending equation to preserve alpha in output buffer.
//  2021-01-25: Metal: Fixed texture storage mode when building on Mac Catalyst.
//  2019-05-29: Metal: Added support for large mesh (64K+ vertices), enable ImGuiBackendFlags_RendererHasVtxOffset flag.
//  2019-04-30: Metal: Added support for special ImDrawCallback_ResetRenderState callback to reset render state.
//  2019-02-11: Metal: Projecting clipping rectangles correctly using draw_data->FramebufferScale to allow multi-viewports for retina display.
//  2018-11-30: Misc: Setting up io.BackendRendererName so it can be displayed in the About Window.
//  2018-07-05: Metal: Added new Metal backend implementation.

#ifndef IMGUI_DISABLE




#pragma mark - Support classes

// A wrapper around a MTLBuffer object that knows the last time it was reused
@interface MetalBuffer : NSObject
@property (nonatomic, strong) id<MTLBuffer> buffer;
@property (nonatomic, assign) double        lastReuseTime;
- (instancetype)initWithBuffer:(id<MTLBuffer>)buffer;
@end

// An object that encapsulates the data necessary to uniquely identify a
// render pipeline state. These are used as cache keys.
@interface FramebufferDescriptor : NSObject<NSCopying>
@property (nonatomic, assign) unsigned long  sampleCount;
@property (nonatomic, assign) MTLPixelFormat colorPixelFormat;
@property (nonatomic, assign) MTLPixelFormat depthPixelFormat;
@property (nonatomic, assign) MTLPixelFormat stencilPixelFormat;
- (instancetype)initWithRenderPassDescriptor:(MTLRenderPassDescriptor*)renderPassDescriptor;
@end

@interface MetalTexture : NSObject
@property (nonatomic, strong) id<MTLTexture> metalTexture;
- (instancetype)initWithTexture:(id<MTLTexture>)metalTexture;
@end

// A singleton that stores long-lived objects that are needed by the Metal
// renderer backend. Stores the render pipeline state cache and the default
// font texture, and manages the reusable buffer cache.
@interface MetalContext : NSObject
@property (nonatomic, strong) id<MTLDevice>                 device;
@property (nonatomic, strong) id<MTLDepthStencilState>      depthStencilState;
@property (nonatomic, strong) FramebufferDescriptor*        framebufferDescriptor; // framebuffer descriptor for current frame; transient
@property (nonatomic, strong) NSMutableDictionary*          renderPipelineStateCache; // pipeline cache; keyed on framebuffer descriptors
@property (nonatomic, strong) NSMutableArray<MetalBuffer*>* bufferCache;
@property (nonatomic, assign) double                        lastBufferCachePurge;
- (MetalBuffer*)dequeueReusableBufferOfLength:(NSUInteger)length device:(id<MTLDevice>)device;
- (id<MTLRenderPipelineState>)renderPipelineStateForFramebufferDescriptor:(FramebufferDescriptor*)descriptor device:(id<MTLDevice>)device;
@end

struct ImGui_ImplMetal_Data
{
    MetalContext*               SharedMetalContext;

    ImGui_ImplMetal_Data()      { memset((void*)this, 0, sizeof(*this)); }
};

static ImGui_ImplMetal_Data*    ImGui_ImplMetal_GetBackendData()    { return ImGui::GetCurrentContext() ? (ImGui_ImplMetal_Data*)ImGui::GetIO().BackendRendererUserData : nullptr; }
static void                     ImGui_ImplMetal_DestroyBackendData(){ IM_DELETE(ImGui_ImplMetal_GetBackendData()); }

void ImGui_ImplMetal_NewFrame(MTL::RenderPassDescriptor* renderPassDescriptor)
{
    ImGui_ImplMetal_NewFrame((__bridge MTLRenderPassDescriptor*)(renderPassDescriptor));
}

void ImGui_ImplMetal_RenderDrawData(ImDrawData* draw_data,
                                    MTL::CommandBuffer* commandBuffer,
                                    MTL::RenderCommandEncoder* commandEncoder)
{
    ImGui_ImplMetal_RenderDrawData(draw_data,
                                   (__bridge id<MTLCommandBuffer>)(commandBuffer),
                                   (__bridge id<MTLRenderCommandEncoder>)(commandEncoder));

}

bool ImGui_ImplMetal_CreateDeviceObjects(MTL::Device* device)
{
    return ImGui_ImplMetal_CreateDeviceObjects((__bridge id<MTLDevice>)(device));
}

#endif // #ifdef IMGUI_IMPL_METAL_CPP

#pragma mark - Dear ImGui Metal Backend API

bool ImGui_ImplMetal_Init(id<MTLDevice> device)
{
    ImGuiIO& io = ImGui::GetIO();
    IMGUI_CHECKVERSION();
    IM_ASSERT(io.BackendRendererUserData == nullptr && "Already initialized a renderer backend!");

    ImGui_ImplMetal_Data* bd = IM_NEW(ImGui_ImplMetal_Data)();
    io.BackendRendererUserData = (void*)bd;
    io.BackendRendererName = "imgui_impl_metal";
    io.BackendFlags |= ImGuiBackendFlags_RendererHasVtxOffset;  // We can honor the ImDrawCmd::VtxOffset field, allowing for large meshes.
    io.BackendFlags |= ImGuiBackendFlags_RendererHasTextures;   // We can honor ImGuiPlatformIO::Textures[] requests during render.

    bd->SharedMetalContext = [[MetalContext alloc] init];
    bd->SharedMetalContext.device = device;

    return true;
}

void ImGui_ImplMetal_Shutdown()
{
    ImGui_ImplMetal_Data* bd = ImGui_ImplMetal_GetBackendData();
    IM_UNUSED(bd);
    IM_ASSERT(bd != nullptr && "No renderer backend to shutdown, or already shutdown?");
    ImGuiIO& io = ImGui::GetIO();
    ImGuiPlatformIO& platform_io = ImGui::GetPlatformIO();

    ImGui_ImplMetal_DestroyDeviceObjects();
    ImGui_ImplMetal_DestroyBackendData();

    io.BackendRendererName = nullptr;
    io.BackendRendererUserData = nullptr;
    io.BackendFlags &= ~(ImGuiBackendFlags_RendererHasVtxOffset | ImGuiBackendFlags_RendererHasTextures);
    platform_io.ClearRendererHandlers();
}

void ImGui_ImplMetal_NewFrame(MTLRenderPassDescriptor* renderPassDescriptor)
{
    ImGui_ImplMetal_Data* bd = ImGui_ImplMetal_GetBackendData();
    IM_ASSERT(bd != nil && "Context or backend not initialized! Did you call ImGui_ImplMetal_Init()?");
#ifdef IMGUI_IMPL_METAL_CPP
    bd->SharedMetalContext.framebufferDescriptor = [[[FramebufferDescriptor alloc] initWithRenderPassDescriptor:renderPassDescriptor]autorelease];
#else
    bd->SharedMetalContext.framebufferDescriptor = [[FramebufferDescriptor alloc] initWithRenderPassDescriptor:renderPassDescriptor];
#endif
    if (bd->SharedMetalContext.depthStencilState == nil)
        ImGui_ImplMetal_CreateDeviceObjects(bd->SharedMetalContext.device);
}

static void ImGui_ImplMetal_SetupRenderState(ImDrawData* draw_data, id<MTLCommandBuffer> commandBuffer,
    id<MTLRenderCommandEncoder> commandEncoder, id<MTLRenderPipelineState> renderPipelineState,
    MetalBuffer* vertexBuffer, size_t vertexBufferOffset)
{
    IM_UNUSED(commandBuffer);
    ImGui_ImplMetal_Data* bd = ImGui_ImplMetal_GetBackendData();
    [commandEncoder setCullMode:MTLCullModeNone];
    [commandEncoder setDepthStencilState:bd->SharedMetalContext.depthStencilState];

    // Setup viewport, orthographic projection matrix
    // Our visible imgui space lies from draw_data->DisplayPos (top left) to
    // draw_data->DisplayPos+data_data->DisplaySize (bottom right). DisplayMin is typically (0,0) for single viewport apps.
    MTLViewport viewport =
    {
        .originX = 0.0,
        .originY = 0.0,
        .width = (double)(draw_data->DisplaySize.x * draw_data->FramebufferScale.x),
        .height = (double)(draw_data->DisplaySize.y * draw_data->FramebufferScale.y),
        .znear = 0.0,
        .zfar = 1.0
    };
    [commandEncoder setViewport:viewport];

    float L = draw_data->DisplayPos.x;
    float R = draw_data->DisplayPos.x + draw_data->DisplaySize.x;
    float T = draw_data->DisplayPos.y;
    float B = draw_data->DisplayPos.y + draw_data->DisplaySize.y;
    float N = (float)viewport.znear;
    float F = (float)viewport.zfar;
    const float ortho_projection[4][4] =
    {
        { 2.0f/(R-L),   0.0f,           0.0f,   0.0f },
        { 0.0f,         2.0f/(T-B),     0.0f,   0.0f },
        { 0.0f,         0.0f,        1/(F-N),   0.0f },
        { (R+L)/(L-R),  (T+B)/(B-T), N/(F-N),   1.0f },
    };
    [commandEncoder setVertexBytes:&ortho_projection length:sizeof(ortho_projection) atIndex:1];

    [commandEncoder setRenderPipelineState:renderPipelineState];

    [commandEncoder setVertexBuffer:vertexBuffer.buffer offset:0 atIndex:0];
    [commandEncoder setVertexBufferOffset:vertexBufferOffset atIndex:0];
}

// Metal Render function.
void ImGui_ImplMetal_RenderDrawData(ImDrawData* draw_data, id<MTLCommandBuffer> commandBuffer, id<MTLRenderCommandEncoder> commandEncoder)
{
    ImGui_ImplMetal_Data* bd = ImGui_ImplMetal_GetBackendData();
    MetalContext* ctx = bd->SharedMetalContext;

    // Avoid rendering when minimized, scale coordinates for retina displays (screen coordinates != framebuffer coordinates)
    int fb_width = (int)(draw_data->DisplaySize.x * draw_data->FramebufferScale.x);
    int fb_height = (int)(draw_data->DisplaySize.y * draw_data->FramebufferScale.y);
    if (fb_width <= 0 || fb_height <= 0 || draw_data->CmdLists.Size == 0)
        return;

    // Catch up with texture updates. Most of the times, the list will have 1 element with an OK status, aka nothing to do.
    // (This almost always points to ImGui::GetPlatformIO().Textures[] but is part of ImDrawData to allow overriding or disabling texture updates).
    if (draw_data->Textures != nullptr)
        for (ImTextureData* tex : *draw_data->Textures)
            if (tex->Status != ImTextureStatus_OK)
                ImGui_ImplMetal_UpdateTexture(tex);

    // Try to retrieve a render pipeline state that is compatible with the framebuffer config for this frame
    // The hit rate for this cache should be very near 100%.
    id<MTLRenderPipelineState> renderPipelineState = ctx.renderPipelineStateCache[ctx.framebufferDescriptor];
    if (renderPipelineState == nil)
    {
        // No luck; make a new render pipeline state
        renderPipelineState = [ctx renderPipelineStateForFramebufferDescriptor:ctx.framebufferDescriptor device:commandBuffer.device];

        // Cache render pipeline state for later reuse
        ctx.renderPipelineStateCache[ctx.framebufferDescriptor] = renderPipelineState;
    }

    size_t vertexBufferLength = (size_t)draw_data->TotalVtxCount * sizeof(ImDrawVert);
    size_t indexBufferLength = (size_t)draw_data->TotalIdxCount * sizeof(ImDrawIdx);
    MetalBuffer* vertexBuffer = [ctx dequeueReusableBufferOfLength:vertexBufferLength device:commandBuffer.device];
    MetalBuffer* indexBuffer = [ctx dequeueReusableBufferOfLength:indexBufferLength device:commandBuffer.device];

    ImGui_ImplMetal_SetupRenderState(draw_data, commandBuffer, commandEncoder, renderPipelineState, vertexBuffer, 0);

    // Will project scissor/clipping rectangles into framebuffer space
    ImVec2 clip_off = draw_data->DisplayPos;         // (0,0) unless using multi-viewports
    ImVec2 clip_scale = draw_data->FramebufferScale; // (1,1) unless using retina display which are often (2,2)

    // Render command lists
    size_t vertexBufferOffset = 0;
    size_t indexBufferOffset = 0;
    for (const ImDrawList* draw_list : draw_data->CmdLists)
    {
        memcpy((char*)vertexBuffer.buffer.contents + vertexBufferOffset, draw_list->VtxBuffer.Data, (size_t)draw_list->VtxBuffer.Size * sizeof(ImDrawVert));
        memcpy((char*)indexBuffer.buffer.contents + indexBufferOffset, draw_list->IdxBuffer.Data, (size_t)draw_list->IdxBuffer.Size * sizeof(ImDrawIdx));

        for (int cmd_i = 0; cmd_i < draw_list->CmdBuffer.Size; cmd_i++)
        {
            const ImDrawCmd* pcmd = &draw_list->CmdBuffer[cmd_i];
            if (pcmd->UserCallback)
            {
                // User callback, registered via ImDrawList::AddCallback()
                // (ImDrawCallback_ResetRenderState is a special callback value used by the user to request the renderer to reset render state.)
                if (pcmd->UserCallback == ImDrawCallback_ResetRenderState)
                    ImGui_ImplMetal_SetupRenderState(draw_data, commandBuffer, commandEncoder, renderPipelineState, vertexBuffer, vertexBufferOffset);
                else
                    pcmd->UserCallback(draw_list, pcmd);
            }
            else
            {
                // Project scissor/clipping rectangles into framebuffer space
                ImVec2 clip_min((pcmd->ClipRect.x - clip_off.x) * clip_scale.x, (pcmd->ClipRect.y - clip_off.y) * clip_scale.y);
                ImVec2 clip_max((pcmd->ClipRect.z - clip_off.x) * clip_scale.x, (pcmd->ClipRect.w - clip_off.y) * clip_scale.y);

                // Clamp to viewport as setScissorRect() won't accept values that are off bounds
                if (clip_min.x < 0.0f) { clip_min.x = 0.0f; }
                if (clip_min.y < 0.0f) { clip_min.y = 0.0f; }
                if (clip_max.x > fb_width) { clip_max.x = (float)fb_width; }
                if (clip_max.y > fb_height) { clip_max.y = (float)fb_height; }
                if (clip_max.x <= clip_min.x || clip_max.y <= clip_min.y)
                    continue;
                if (pcmd->ElemCount == 0) // drawIndexedPrimitives() validation doesn't accept this
                    continue;

                // Apply scissor/clipping rectangle
                MTLScissorRect scissorRect =
                {
                    .x = NSUInteger(clip_min.x),
                    .y = NSUInteger(clip_min.y),
                    .width = NSUInteger(clip_max.x - clip_min.x),
                    .height = NSUInteger(clip_max.y - clip_min.y)
                };
                [commandEncoder setScissorRect:scissorRect];

                // Bind texture, Draw
                if (ImTextureID tex_id = pcmd->GetTexID())
                    [commandEncoder setFragmentTexture:(__bridge id<MTLTexture>)(void*)(intptr_t)(tex_id) atIndex:0];

                [commandEncoder setVertexBufferOffset:(vertexBufferOffset + pcmd->VtxOffset * sizeof(ImDrawVert)) atIndex:0];
                [commandEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                                           indexCount:pcmd->ElemCount
                                            indexType:sizeof(ImDrawIdx) == 2 ? MTLIndexTypeUInt16 : MTLIndexTypeUInt32
                                          indexBuffer:indexBuffer.buffer
                                    indexBufferOffset:indexBufferOffset + pcmd->IdxOffset * sizeof(ImDrawIdx)];
            }
        }

        vertexBufferOffset += (size_t)draw_list->VtxBuffer.Size * sizeof(ImDrawVert);
        indexBufferOffset += (size_t)draw_list->IdxBuffer.Size * sizeof(ImDrawIdx);
    }

    MetalContext* sharedMetalContext = bd->SharedMetalContext;
    [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer>)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            @synchronized(sharedMetalContext.bufferCache)
            {
                [sharedMetalContext.bufferCache addObject:vertexBuffer];
                [sharedMetalContext.bufferCache addObject:indexBuffer];
            }
        });
    }];
}

static void ImGui_ImplMetal_DestroyTexture(ImTextureData* tex)
{
    if (MetalTexture* backend_tex = (__bridge_transfer MetalTexture*)(tex->BackendUserData))
    {
        IM_ASSERT(backend_tex.metalTexture == (__bridge id<MTLTexture>)(void*)(intptr_t)tex->TexID);
        backend_tex.metalTexture = nil;

        // Clear identifiers and mark as destroyed (in order to allow e.g. calling InvalidateDeviceObjects while running)
        tex->SetTexID(ImTextureID_Invalid);
        tex->BackendUserData = nullptr;
    }
    tex->SetStatus(ImTextureStatus_Destroyed);
}

void ImGui_ImplMetal_UpdateTexture(ImTextureData* tex)
{
    ImGui_ImplMetal_Data* bd = ImGui_ImplMetal_GetBackendData();
    if (tex->Status == ImTextureStatus_WantCreate)
    {
        // Create and upload new texture to graphics system
        //IMGUI_DEBUG_LOG("UpdateTexture #%03d: WantCreate %dx%d\n", tex->UniqueID, tex->Width, tex->Height);
        IM_ASSERT(tex->TexID == ImTextureID_Invalid && tex->BackendUserData == nullptr);
        IM_ASSERT(tex->Format == ImTextureFormat_RGBA32);

        // We are retrieving and uploading the font atlas as a 4-channels RGBA texture here.
        // In theory we could call GetTexDataAsAlpha8() and upload a 1-channel texture to save on memory access bandwidth.
        // However, using a shader designed for 1-channel texture would make it less obvious to use the ImTextureID facility to render users own textures.
        // You can make that change in your implementation.
        MTLTextureDescriptor* textureDescriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm
                                                                                                     width:(NSUInteger)tex->Width
                                                                                                    height:(NSUInteger)tex->Height
                                                                                                 mipmapped:NO];
        textureDescriptor.usage = MTLTextureUsageShaderRead;
    #if TARGET_OS_OSX || TARGET_OS_MACCATALYST
        textureDescriptor.storageMode = MTLStorageModeManaged;
    #else
        textureDescriptor.storageMode = MTLStorageModeShared;
    #endif
        id <MTLTexture> texture = [bd->SharedMetalContext.device newTextureWithDescriptor:textureDescriptor];
        [texture replaceRegion:MTLRegionMake2D(0, 0, (NSUInteger)tex->Width, (NSUInteger)tex->Height) mipmapLevel:0 withBytes:tex->Pixels bytesPerRow:(NSUInteger)tex->Width * 4];
        MetalTexture* backend_tex = [[MetalTexture alloc] initWithTexture:texture];

        // Store identifiers
        tex->SetTexID((ImTextureID)(intptr_t)texture);
        tex->SetStatus(ImTextureStatus_OK);
        tex->BackendUserData = (__bridge_retained void*)(backend_tex);
    }
    else if (tex->Status == ImTextureStatus_WantUpdates)
    {
        // Update selected blocks. We only ever write to textures regions which have never been used before!
        // This backend choose to use tex->Updates[] but you can use tex->UpdateRect to upload a single region.
        MetalTexture* backend_tex = (__bridge MetalTexture*)(tex->BackendUserData);
        for (ImTextureRect& r : tex->Updates)
        {
            [backend_tex.metalTexture replaceRegion:MTLRegionMake2D((NSUInteger)r.x, (NSUInteger)r.y, (NSUInteger)r.w, (NSUInteger)r.h)
                                        mipmapLevel:0
                                          withBytes:tex->GetPixelsAt(r.x, r.y)
                                        bytesPerRow:(NSUInteger)tex->Width * 4];
        }
        tex->SetStatus(ImTextureStatus_OK);
    }
    else if (tex->Status == ImTextureStatus_WantDestroy && tex->UnusedFrames > 0)
    {
        ImGui_ImplMetal_DestroyTexture(tex);
    }
}

bool ImGui_ImplMetal_CreateDeviceObjects(id<MTLDevice> device)
{
    ImGui_ImplMetal_Data* bd = ImGui_ImplMetal_GetBackendData();
    MTLDepthStencilDescriptor* depthStencilDescriptor = [[MTLDepthStencilDescriptor alloc] init];
    depthStencilDescriptor.depthWriteEnabled = NO;
    depthStencilDescriptor.depthCompareFunction = MTLCompareFunctionAlways;
    bd->SharedMetalContext.depthStencilState = [device newDepthStencilStateWithDescriptor:depthStencilDescriptor];
#ifdef IMGUI_IMPL_METAL_CPP
    [depthStencilDescriptor release];
#endif

    return true;
}

void ImGui_ImplMetal_DestroyDeviceObjects()
{
    ImGui_ImplMetal_Data* bd = ImGui_ImplMetal_GetBackendData();

    // Destroy all textures
    for (ImTextureData* tex : ImGui::GetPlatformIO().Textures)
        if (tex->RefCount == 1)
            ImGui_ImplMetal_DestroyTexture(tex);

    [bd->SharedMetalContext.renderPipelineStateCache removeAllObjects];
}

#pragma mark - MetalBuffer implementation

@implementation MetalBuffer
- (instancetype)initWithBuffer:(id<MTLBuffer>)buffer
{
    if ((self = [super init]))
    {
        _buffer = buffer;
        _lastReuseTime = GetMachAbsoluteTimeInSeconds();
    }
    return self;
}
@end

#pragma mark - FramebufferDescriptor implementation

@implementation FramebufferDescriptor
- (instancetype)initWithRenderPassDescriptor:(MTLRenderPassDescriptor*)renderPassDescriptor
{
    if ((self = [super init]))
    {
        _sampleCount = renderPassDescriptor.colorAttachments[0].texture.sampleCount;
        _colorPixelFormat = renderPassDescriptor.colorAttachments[0].texture.pixelFormat;
        _depthPixelFormat = renderPassDescriptor.depthAttachment.texture.pixelFormat;
        _stencilPixelFormat = renderPassDescriptor.stencilAttachment.texture.pixelFormat;
    }
    return self;
}

- (nonnull id)copyWithZone:(nullable NSZone*)zone
{
    FramebufferDescriptor* copy = [[FramebufferDescriptor allocWithZone:zone] init];
    copy.sampleCount = self.sampleCount;
    copy.colorPixelFormat = self.colorPixelFormat;
    copy.depthPixelFormat = self.depthPixelFormat;
    copy.stencilPixelFormat = self.stencilPixelFormat;
    return copy;
}

- (NSUInteger)hash
{
    NSUInteger sc = _sampleCount & 0x3;
    NSUInteger cf = _colorPixelFormat & 0x3FF;
    NSUInteger df = _depthPixelFormat & 0x3FF;
    NSUInteger sf = _stencilPixelFormat & 0x3FF;
    NSUInteger hash = (sf << 22) | (df << 12) | (cf << 2) | sc;
    return hash;
}

- (BOOL)isEqual:(id)object
{
    FramebufferDescriptor* other = object;
    if (![other isKindOfClass:[FramebufferDescriptor class]])
        return NO;
    return other.sampleCount == self.sampleCount      &&
    other.colorPixelFormat   == self.colorPixelFormat &&
    other.depthPixelFormat   == self.depthPixelFormat &&
    other.stencilPixelFormat == self.stencilPixelFormat;
}

@end

#pragma mark - MetalTexture implementation

@implementation MetalTexture
- (instancetype)initWithTexture:(id<MTLTexture>)metalTexture
{
    if ((self = [super init]))
        self.metalTexture = metalTexture;
    return self;
}

@end

#pragma mark - MetalContext implementation

@implementation MetalContext
- (instancetype)init
{
    if ((self = [super init]))
    {
        self.renderPipelineStateCache = [NSMutableDictionary dictionary];
        self.bufferCache = [NSMutableArray array];
        _lastBufferCachePurge = GetMachAbsoluteTimeInSeconds();
    }
    return self;
}

- (MetalBuffer*)dequeueReusableBufferOfLength:(NSUInteger)length device:(id<MTLDevice>)device
{
    uint64_t now = GetMachAbsoluteTimeInSeconds();

    @synchronized(self.bufferCache)
    {
        // Purge old buffers that haven't been useful for a while
        if (now - self.lastBufferCachePurge > 1.0)
        {
            NSMutableArray* survivors = [NSMutableArray array];
            for (MetalBuffer* candidate in self.bufferCache)
                if (candidate.lastReuseTime > self.lastBufferCachePurge)
                    [survivors addObject:candidate];
            self.bufferCache = [survivors mutableCopy];
            self.lastBufferCachePurge = now;
        }

        // See if we have a buffer we can reuse
        MetalBuffer* bestCandidate = nil;
        for (MetalBuffer* candidate in self.bufferCache)
            if (candidate.buffer.length >= length && (bestCandidate == nil || bestCandidate.lastReuseTime > candidate.lastReuseTime))
                bestCandidate = candidate;

        if (bestCandidate != nil)
        {
            [self.bufferCache removeObject:bestCandidate];
            bestCandidate.lastReuseTime = now;
            return bestCandidate;
        }
    }

    // No luck; make a new buffer
    id<MTLBuffer> backing = [device newBufferWithLength:length options:MTLResourceStorageModeShared];
    return [[MetalBuffer alloc] initWithBuffer:backing];
}

// Bilinear sampling is required by default. Set 'io.Fonts->Flags |= ImFontAtlasFlags_NoBakedLines' or 'style.AntiAliasedLinesUseTex = false' to allow point/nearest sampling.
- (id<MTLRenderPipelineState>)renderPipelineStateForFramebufferDescriptor:(FramebufferDescriptor*)descriptor device:(id<MTLDevice>)device
{
    NSError* error = nil;

    NSString* shaderSource = @""
    "#include <metal_stdlib>\n"
    "using namespace metal;\n"
    "\n"
    "struct Uniforms {\n"
    "    float4x4 projectionMatrix;\n"
    "};\n"
    "\n"
    "struct VertexIn {\n"
    "    float2 position  [[attribute(0)]];\n"
    "    float2 texCoords [[attribute(1)]];\n"
    "    uchar4 color     [[attribute(2)]];\n"
    "};\n"
    "\n"
    "struct VertexOut {\n"
    "    float4 position [[position]];\n"
    "    float2 texCoords;\n"
    "    float4 color;\n"
    "};\n"
    "\n"
    "vertex VertexOut vertex_main(VertexIn in                 [[stage_in]],\n"
    "                             constant Uniforms &uniforms [[buffer(1)]]) {\n"
    "    VertexOut out;\n"
    "    out.position = uniforms.projectionMatrix * float4(in.position, 0, 1);\n"
    "    out.texCoords = in.texCoords;\n"
    "    out.color = float4(in.color) / float4(255.0);\n"
    "    return out;\n"
    "}\n"
    "\n"
    "fragment half4 fragment_main(VertexOut in [[stage_in]],\n"
    "                             texture2d<half, access::sample> texture [[texture(0)]]) {\n"
    "    constexpr sampler linearSampler(coord::normalized, min_filter::linear, mag_filter::linear, mip_filter::linear);\n"
    "    half4 texColor = texture.sample(linearSampler, in.texCoords);\n"
    "    return half4(in.color) * texColor;\n"
    "}\n";

    id<MTLLibrary> library = [device newLibraryWithSource:shaderSource options:nil error:&error];
    if (library == nil)
    {
        NSLog(@"Error: failed to create Metal library: %@", error);
        return nil;
    }

    id<MTLFunction> vertexFunction = [library newFunctionWithName:@"vertex_main"];
    id<MTLFunction> fragmentFunction = [library newFunctionWithName:@"fragment_main"];

    if (vertexFunction == nil || fragmentFunction == nil)
    {
        NSLog(@"Error: failed to find Metal shader functions in library: %@", error);
        return nil;
    }

    MTLVertexDescriptor* vertexDescriptor = [MTLVertexDescriptor vertexDescriptor];
    vertexDescriptor.attributes[0].offset = offsetof(ImDrawVert, pos);
    vertexDescriptor.attributes[0].format = MTLVertexFormatFloat2; // position
    vertexDescriptor.attributes[0].bufferIndex = 0;
    vertexDescriptor.attributes[1].offset = offsetof(ImDrawVert, uv);
    vertexDescriptor.attributes[1].format = MTLVertexFormatFloat2; // texCoords
    vertexDescriptor.attributes[1].bufferIndex = 0;
    vertexDescriptor.attributes[2].offset = offsetof(ImDrawVert, col);
    vertexDescriptor.attributes[2].format = MTLVertexFormatUChar4; // color
    vertexDescriptor.attributes[2].bufferIndex = 0;
    vertexDescriptor.layouts[0].stepRate = 1;
    vertexDescriptor.layouts[0].stepFunction = MTLVertexStepFunctionPerVertex;
    vertexDescriptor.layouts[0].stride = sizeof(ImDrawVert);

    MTLRenderPipelineDescriptor* pipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineDescriptor.vertexFunction = vertexFunction;
    pipelineDescriptor.fragmentFunction = fragmentFunction;
    pipelineDescriptor.vertexDescriptor = vertexDescriptor;
    pipelineDescriptor.rasterSampleCount = self.framebufferDescriptor.sampleCount;
    pipelineDescriptor.colorAttachments[0].pixelFormat = self.framebufferDescriptor.colorPixelFormat;
    pipelineDescriptor.colorAttachments[0].blendingEnabled = YES;
    pipelineDescriptor.colorAttachments[0].rgbBlendOperation = MTLBlendOperationAdd;
    pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = MTLBlendFactorSourceAlpha;
    pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
    pipelineDescriptor.colorAttachments[0].alphaBlendOperation = MTLBlendOperationAdd;
    pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = MTLBlendFactorOne;
    pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
    pipelineDescriptor.depthAttachmentPixelFormat = self.framebufferDescriptor.depthPixelFormat;
    pipelineDescriptor.stencilAttachmentPixelFormat = self.framebufferDescriptor.stencilPixelFormat;

    id<MTLRenderPipelineState> renderPipelineState = [device newRenderPipelineStateWithDescriptor:pipelineDescriptor error:&error];
    if (error != nil)
        NSLog(@"Error: failed to create Metal pipeline state: %@", error);

    return renderPipelineState;
}

@end

//-----------------------------------------------------------------------------

#endif // #ifndef IMGUI_DISABLE

#pragma warning(pop)
#pragma pack(pop)
// --- SANDBOX END: imgui_impl_metal.mm ---

#endif // defined(IMGUI_BUILD_BACKEND_METAL)


#if defined(IMGUI_BUILD_BACKEND_OSX)
// --- SANDBOX START: imgui_impl_osx.mm ---
#pragma pack(push)
#pragma warning(push)
// [SOURCE: imgui_impl_osx.mm]
// dear imgui: Platform Backend for OSX / Cocoa
// This needs to be used along with a Renderer (e.g. OpenGL2, OpenGL3, Vulkan, Metal..)
// - Not well tested. If you want a portable application, prefer using the GLFW or SDL platform Backends on Mac.
// - Requires linking with the GameController framework ("-framework GameController").

// Implemented features:
//  [X] Platform: Clipboard support is part of core Dear ImGui (no specific code in this backend).
//  [X] Platform: Mouse support. Can discriminate Mouse/Pen.
//  [X] Platform: Keyboard support. Since 1.87 we are using the io.AddKeyEvent() function. Pass ImGuiKey values to all key functions e.g. ImGui::IsKeyPressed(ImGuiKey_Space). [Legacy kVK_* values are obsolete since 1.87 and not supported since 1.91.5]
//  [X] Platform: Gamepad support.
//  [X] Platform: Mouse cursor shape and visibility (ImGuiBackendFlags_HasMouseCursors). Disable with 'io.ConfigFlags |= ImGuiConfigFlags_NoMouseCursorChange'.
//  [X] Platform: IME support.

// You can use unmodified imgui_impl_* files in your project. See examples/ folder for examples of using this.
// Prefer including the entire imgui/ repository into your project (either as a copy or as a submodule), and only build the backends you need.
// Learn about Dear ImGui:
// - FAQ                  https://dearimgui.com/faq
// - Getting Started      https://dearimgui.com/getting-started
// - Documentation        https://dearimgui.com/docs (same as your local docs/ folder).
// - Introduction, links and more at the top of imgui.cpp

#import "imgui.h"
#ifndef IMGUI_DISABLE
#import "imgui_impl_osx.h"





// CHANGELOG
// (minor and older changes stripped away, please see git history for details)
//  2025-09-18: Call platform_io.ClearPlatformHandlers() on shutdown.
//  2025-06-27: Added ImGuiMouseCursor_Wait and ImGuiMouseCursor_Progress mouse cursor support.
//  2025-06-12: ImGui_ImplOSX_HandleEvent() only process event for window containing our view. (#8644)
//  2025-03-21: Fill gamepad inputs and set ImGuiBackendFlags_HasGamepad regardless of ImGuiConfigFlags_NavEnableGamepad being set.
//  2025-01-20: Removed notification observer when shutting down. (#8331)
//  2024-08-22: moved some OS/backend related function pointers from ImGuiIO to ImGuiPlatformIO:
//               - io.GetClipboardTextFn    -> platform_io.Platform_GetClipboardTextFn
//               - io.SetClipboardTextFn    -> platform_io.Platform_SetClipboardTextFn
//               - io.PlatformSetImeDataFn  -> platform_io.Platform_SetImeDataFn
//  2024-07-02: Update for io.SetPlatformImeDataFn() -> io.PlatformSetImeDataFn() renaming in main library.
//  2023-10-05: Inputs: Added support for extra ImGuiKey values: F13 to F20 function keys. Stopped mapping F13 into PrintScreen.
//  2023-04-09: Inputs: Added support for io.AddMouseSourceEvent() to discriminate ImGuiMouseSource_Mouse/ImGuiMouseSource_Pen.
//  2023-02-01: Fixed scroll wheel scaling for devices emitting events with hasPreciseScrollingDeltas==false (e.g. non-Apple mice).
//  2022-11-02: Fixed mouse coordinates before clicking the host window.
//  2022-10-06: Fixed mouse inputs on flipped views.
//  2022-09-26: Inputs: Renamed ImGuiKey_ModXXX introduced in 1.87 to ImGuiMod_XXX (old names still supported).
//  2022-05-03: Inputs: Removed ImGui_ImplOSX_HandleEvent() from backend API in favor of backend automatically handling event capture.
//  2022-04-27: Misc: Store backend data in a per-context struct, allowing to use this backend with multiple contexts.
//  2022-03-22: Inputs: Monitor NSKeyUp events to catch missing keyUp for key when user press Cmd + key
//  2022-02-07: Inputs: Forward keyDown/keyUp events to OS when unused by dear imgui.
//  2022-01-31: Fixed building with old Xcode versions that are missing gamepad features.
//  2022-01-26: Inputs: replaced short-lived io.AddKeyModsEvent() (added two weeks ago) with io.AddKeyEvent() using ImGuiKey_ModXXX flags. Sorry for the confusion.
//  2021-01-20: Inputs: calling new io.AddKeyAnalogEvent() for gamepad support, instead of writing directly to io.NavInputs[].
//  2022-01-17: Inputs: calling new io.AddMousePosEvent(), io.AddMouseButtonEvent(), io.AddMouseWheelEvent() API (1.87+).
//  2022-01-12: Inputs: Added basic Platform IME support, hooking the io.SetPlatformImeDataFn() function.
//  2022-01-10: Inputs: calling new io.AddKeyEvent(), io.AddKeyModsEvent() + io.SetKeyEventNativeData() API (1.87+). Support for full ImGuiKey range.
//  2021-12-13: *BREAKING CHANGE* Add NSView parameter to ImGui_ImplOSX_Init(). Generally fix keyboard support. Using kVK_* codes for keyboard keys.
//  2021-12-13: Add game controller support.
//  2021-09-21: Use mach_absolute_time as CFAbsoluteTimeGetCurrent can jump backwards.
//  2021-08-17: Calling io.AddFocusEvent() on NSApplicationDidBecomeActiveNotification/NSApplicationDidResignActiveNotification events.
//  2021-06-23: Inputs: Added a fix for shortcuts using CTRL key instead of CMD key.
//  2021-04-19: Inputs: Added a fix for keys remaining stuck in pressed state when CMD-tabbing into different application.
//  2021-01-27: Inputs: Added a fix for mouse position not being reported when mouse buttons other than left one are down.
//  2020-10-28: Inputs: Added a fix for handling keypad-enter key.
//  2020-05-25: Inputs: Added a fix for missing trackpad clicks when done with "soft tap".
//  2019-12-05: Inputs: Added support for ImGuiMouseCursor_NotAllowed mouse cursor.
//  2019-10-11: Inputs:  Fix using Backspace key.
//  2019-07-21: Re-added clipboard handlers as they are not enabled by default in core imgui.cpp (reverted 2019-05-18 change).
//  2019-05-28: Inputs: Added mouse cursor shape and visibility support.
//  2019-05-18: Misc: Removed clipboard handlers as they are now supported by core imgui.cpp.
//  2019-05-11: Inputs: Don't filter character values before calling AddInputCharacter() apart from 0xF700..0xFFFF range.
//  2018-11-30: Misc: Setting up io.BackendPlatformName so it can be displayed in the About Window.
//  2018-07-07: Initial version.




@class ImGuiObserver;
@class KeyEventResponder;

// Data
struct ImGui_ImplOSX_Data
{
    CFTimeInterval              Time;
    NSCursor*                   MouseCursors[ImGuiMouseCursor_COUNT];
    bool                        MouseCursorHidden;
    ImGuiObserver*              Observer;
    KeyEventResponder*          KeyEventResponder;
    NSTextInputContext*         InputContext;
    id                          Monitor;
    NSWindow*                   Window;

    ImGui_ImplOSX_Data()        { memset((void*)this, 0, sizeof(*this)); }
};

static ImGui_ImplOSX_Data*      ImGui_ImplOSX_GetBackendData()      { return (ImGui_ImplOSX_Data*)ImGui::GetIO().BackendPlatformUserData; }
static void                     ImGui_ImplOSX_DestroyBackendData()  { IM_DELETE(ImGui_ImplOSX_GetBackendData()); }

#pragma mark - Public

- (void)setImePosX:(float)posX imePosY:(float)posY
{
    _posX = posX;
    _posY = posY;
}

- (void)updateImePosWithView:(NSView *)view
{
    NSWindow* window = view.window;
    if (!window)
        return;
    {
        NSRect contentRect = [window contentRectForFrameRect:window.frame];
        NSRect rect = NSMakeRect(_posX, contentRect.size.height - _posY, 0, 0);
        _imeRect = [window convertRectToScreen:rect];
    }
}

- (void)viewDidMoveToWindow
{
    // Ensure self is a first responder to receive the input events.
    [self.window makeFirstResponder:self];
}

- (void)keyDown:(NSEvent*)event
{
    if (!ImGui_ImplOSX_HandleEvent(event, self))
        [super keyDown:event];

    // Call to the macOS input manager system.
    [self interpretKeyEvents:@[event]];
}

- (void)keyUp:(NSEvent*)event
{
    if (!ImGui_ImplOSX_HandleEvent(event, self))
        [super keyUp:event];
}

- (void)insertText:(id)aString replacementRange:(NSRange)replacementRange
{
    ImGuiIO& io = ImGui::GetIO();

    NSString* characters;
    if ([aString isKindOfClass:[NSAttributedString class]])
        characters = [aString string];
    else
        characters = (NSString*)aString;

    io.AddInputCharactersUTF8(characters.UTF8String);
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)doCommandBySelector:(SEL)myselector
{
}

- (nullable NSAttributedString*)attributedSubstringForProposedRange:(NSRange)range actualRange:(nullable NSRangePointer)actualRange
{
    return nil;
}

- (NSUInteger)characterIndexForPoint:(NSPoint)point
{
    return 0;
}

- (NSRect)firstRectForCharacterRange:(NSRange)range actualRange:(nullable NSRangePointer)actualRange
{
    return _imeRect;
}

- (BOOL)hasMarkedText
{
    return NO;
}

- (NSRange)markedRange
{
    return NSMakeRange(NSNotFound, 0);
}

- (NSRange)selectedRange
{
    return NSMakeRange(NSNotFound, 0);
}

- (void)setMarkedText:(nonnull id)string selectedRange:(NSRange)selectedRange replacementRange:(NSRange)replacementRange
{
}

- (void)unmarkText
{
}

- (nonnull NSArray<NSAttributedStringKey>*)validAttributesForMarkedText
{
    return @[];
}

@end

@interface ImGuiObserver : NSObject

- (void)onApplicationBecomeActive:(NSNotification*)aNotification;
- (void)onApplicationBecomeInactive:(NSNotification*)aNotification;

@end

@implementation ImGuiObserver

- (void)onApplicationBecomeActive:(NSNotification*)aNotification
{
    ImGuiIO& io = ImGui::GetIO();
    io.AddFocusEvent(true);
}

- (void)onApplicationBecomeInactive:(NSNotification*)aNotification
{
    ImGuiIO& io = ImGui::GetIO();
    io.AddFocusEvent(false);
}

@end

// Functions

// Not static to allow third-party code to use that if they want to (but undocumented)
ImGuiKey ImGui_ImplOSX_KeyCodeToImGuiKey(int key_code);
ImGuiKey ImGui_ImplOSX_KeyCodeToImGuiKey(int key_code)
{
    switch (key_code)
    {
        case kVK_ANSI_A: return ImGuiKey_A;
        case kVK_ANSI_S: return ImGuiKey_S;
        case kVK_ANSI_D: return ImGuiKey_D;
        case kVK_ANSI_F: return ImGuiKey_F;
        case kVK_ANSI_H: return ImGuiKey_H;
        case kVK_ANSI_G: return ImGuiKey_G;
        case kVK_ANSI_Z: return ImGuiKey_Z;
        case kVK_ANSI_X: return ImGuiKey_X;
        case kVK_ANSI_C: return ImGuiKey_C;
        case kVK_ANSI_V: return ImGuiKey_V;
        case kVK_ANSI_B: return ImGuiKey_B;
        case kVK_ANSI_Q: return ImGuiKey_Q;
        case kVK_ANSI_W: return ImGuiKey_W;
        case kVK_ANSI_E: return ImGuiKey_E;
        case kVK_ANSI_R: return ImGuiKey_R;
        case kVK_ANSI_Y: return ImGuiKey_Y;
        case kVK_ANSI_T: return ImGuiKey_T;
        case kVK_ANSI_1: return ImGuiKey_1;
        case kVK_ANSI_2: return ImGuiKey_2;
        case kVK_ANSI_3: return ImGuiKey_3;
        case kVK_ANSI_4: return ImGuiKey_4;
        case kVK_ANSI_6: return ImGuiKey_6;
        case kVK_ANSI_5: return ImGuiKey_5;
        case kVK_ANSI_Equal: return ImGuiKey_Equal;
        case kVK_ANSI_9: return ImGuiKey_9;
        case kVK_ANSI_7: return ImGuiKey_7;
        case kVK_ANSI_Minus: return ImGuiKey_Minus;
        case kVK_ANSI_8: return ImGuiKey_8;
        case kVK_ANSI_0: return ImGuiKey_0;
        case kVK_ANSI_RightBracket: return ImGuiKey_RightBracket;
        case kVK_ANSI_O: return ImGuiKey_O;
        case kVK_ANSI_U: return ImGuiKey_U;
        case kVK_ANSI_LeftBracket: return ImGuiKey_LeftBracket;
        case kVK_ANSI_I: return ImGuiKey_I;
        case kVK_ANSI_P: return ImGuiKey_P;
        case kVK_ANSI_L: return ImGuiKey_L;
        case kVK_ANSI_J: return ImGuiKey_J;
        case kVK_ANSI_Quote: return ImGuiKey_Apostrophe;
        case kVK_ANSI_K: return ImGuiKey_K;
        case kVK_ANSI_Semicolon: return ImGuiKey_Semicolon;
        case kVK_ANSI_Backslash: return ImGuiKey_Backslash;
        case kVK_ANSI_Comma: return ImGuiKey_Comma;
        case kVK_ANSI_Slash: return ImGuiKey_Slash;
        case kVK_ANSI_N: return ImGuiKey_N;
        case kVK_ANSI_M: return ImGuiKey_M;
        case kVK_ANSI_Period: return ImGuiKey_Period;
        case kVK_ANSI_Grave: return ImGuiKey_GraveAccent;
        case kVK_ANSI_KeypadDecimal: return ImGuiKey_KeypadDecimal;
        case kVK_ANSI_KeypadMultiply: return ImGuiKey_KeypadMultiply;
        case kVK_ANSI_KeypadPlus: return ImGuiKey_KeypadAdd;
        case kVK_ANSI_KeypadClear: return ImGuiKey_NumLock;
        case kVK_ANSI_KeypadDivide: return ImGuiKey_KeypadDivide;
        case kVK_ANSI_KeypadEnter: return ImGuiKey_KeypadEnter;
        case kVK_ANSI_KeypadMinus: return ImGuiKey_KeypadSubtract;
        case kVK_ANSI_KeypadEquals: return ImGuiKey_KeypadEqual;
        case kVK_ANSI_Keypad0: return ImGuiKey_Keypad0;
        case kVK_ANSI_Keypad1: return ImGuiKey_Keypad1;
        case kVK_ANSI_Keypad2: return ImGuiKey_Keypad2;
        case kVK_ANSI_Keypad3: return ImGuiKey_Keypad3;
        case kVK_ANSI_Keypad4: return ImGuiKey_Keypad4;
        case kVK_ANSI_Keypad5: return ImGuiKey_Keypad5;
        case kVK_ANSI_Keypad6: return ImGuiKey_Keypad6;
        case kVK_ANSI_Keypad7: return ImGuiKey_Keypad7;
        case kVK_ANSI_Keypad8: return ImGuiKey_Keypad8;
        case kVK_ANSI_Keypad9: return ImGuiKey_Keypad9;
        case kVK_Return: return ImGuiKey_Enter;
        case kVK_Tab: return ImGuiKey_Tab;
        case kVK_Space: return ImGuiKey_Space;
        case kVK_Delete: return ImGuiKey_Backspace;
        case kVK_Escape: return ImGuiKey_Escape;
        case kVK_CapsLock: return ImGuiKey_CapsLock;
        case kVK_Control: return ImGuiKey_LeftCtrl;
        case kVK_Shift: return ImGuiKey_LeftShift;
        case kVK_Option: return ImGuiKey_LeftAlt;
        case kVK_Command: return ImGuiKey_LeftSuper;
        case kVK_RightControl: return ImGuiKey_RightCtrl;
        case kVK_RightShift: return ImGuiKey_RightShift;
        case kVK_RightOption: return ImGuiKey_RightAlt;
        case kVK_RightCommand: return ImGuiKey_RightSuper;
//      case kVK_Function: return ImGuiKey_;
//      case kVK_VolumeUp: return ImGuiKey_;
//      case kVK_VolumeDown: return ImGuiKey_;
//      case kVK_Mute: return ImGuiKey_;
        case kVK_F1: return ImGuiKey_F1;
        case kVK_F2: return ImGuiKey_F2;
        case kVK_F3: return ImGuiKey_F3;
        case kVK_F4: return ImGuiKey_F4;
        case kVK_F5: return ImGuiKey_F5;
        case kVK_F6: return ImGuiKey_F6;
        case kVK_F7: return ImGuiKey_F7;
        case kVK_F8: return ImGuiKey_F8;
        case kVK_F9: return ImGuiKey_F9;
        case kVK_F10: return ImGuiKey_F10;
        case kVK_F11: return ImGuiKey_F11;
        case kVK_F12: return ImGuiKey_F12;
        case kVK_F13: return ImGuiKey_F13;
        case kVK_F14: return ImGuiKey_F14;
        case kVK_F15: return ImGuiKey_F15;
        case kVK_F16: return ImGuiKey_F16;
        case kVK_F17: return ImGuiKey_F17;
        case kVK_F18: return ImGuiKey_F18;
        case kVK_F19: return ImGuiKey_F19;
        case kVK_F20: return ImGuiKey_F20;
        case 0x6E: return ImGuiKey_Menu;
        case kVK_Help: return ImGuiKey_Insert;
        case kVK_Home: return ImGuiKey_Home;
        case kVK_PageUp: return ImGuiKey_PageUp;
        case kVK_ForwardDelete: return ImGuiKey_Delete;
        case kVK_End: return ImGuiKey_End;
        case kVK_PageDown: return ImGuiKey_PageDown;
        case kVK_LeftArrow: return ImGuiKey_LeftArrow;
        case kVK_RightArrow: return ImGuiKey_RightArrow;
        case kVK_DownArrow: return ImGuiKey_DownArrow;
        case kVK_UpArrow: return ImGuiKey_UpArrow;
        default: return ImGuiKey_None;
    }
}

#ifdef IMGUI_IMPL_METAL_CPP_EXTENSIONS

IMGUI_IMPL_API bool ImGui_ImplOSX_Init(void* _Nonnull view) {
    return ImGui_ImplOSX_Init((__bridge NSView*)(view));
}

IMGUI_IMPL_API void ImGui_ImplOSX_NewFrame(void* _Nullable view) {
    return ImGui_ImplOSX_NewFrame((__bridge NSView*)(view));
}

#endif


bool ImGui_ImplOSX_Init(NSView* view)
{
    ImGuiIO& io = ImGui::GetIO();
    ImGuiPlatformIO& platform_io = ImGui::GetPlatformIO();
    IMGUI_CHECKVERSION();
    IM_ASSERT(io.BackendPlatformUserData == nullptr && "Already initialized a platform backend!");

    // Setup backend capabilities flags
    ImGui_ImplOSX_Data* bd = IM_NEW(ImGui_ImplOSX_Data)();
    io.BackendPlatformUserData = (void*)bd;
    io.BackendPlatformName = "imgui_impl_osx";
    io.BackendFlags |= ImGuiBackendFlags_HasMouseCursors;           // We can honor GetMouseCursor() values (optional)
    //io.BackendFlags |= ImGuiBackendFlags_HasSetMousePos;          // We can honor io.WantSetMousePos requests (optional, rarely used)

    bd->Observer = [ImGuiObserver new];
    bd->Window = view.window ?: NSApp.orderedWindows.firstObject;
    ImGuiViewport* main_viewport = ImGui::GetMainViewport();
    main_viewport->PlatformHandle = main_viewport->PlatformHandleRaw = (__bridge_retained void*)bd->Window;

    // Load cursors. Some of them are undocumented.
    bd->MouseCursorHidden = false;
    bd->MouseCursors[ImGuiMouseCursor_Arrow] = [NSCursor arrowCursor];
    bd->MouseCursors[ImGuiMouseCursor_TextInput] = [NSCursor IBeamCursor];
    bd->MouseCursors[ImGuiMouseCursor_ResizeAll] = [NSCursor closedHandCursor];
    bd->MouseCursors[ImGuiMouseCursor_ResizeNS] = [NSCursor respondsToSelector:@selector(_windowResizeNorthSouthCursor)] ? [NSCursor _windowResizeNorthSouthCursor] : [NSCursor resizeUpDownCursor];
    bd->MouseCursors[ImGuiMouseCursor_ResizeEW] = [NSCursor respondsToSelector:@selector(_windowResizeEastWestCursor)] ? [NSCursor _windowResizeEastWestCursor] : [NSCursor resizeLeftRightCursor];
    bd->MouseCursors[ImGuiMouseCursor_ResizeNESW] = [NSCursor respondsToSelector:@selector(_windowResizeNorthEastSouthWestCursor)] ? [NSCursor _windowResizeNorthEastSouthWestCursor] : [NSCursor closedHandCursor];
    bd->MouseCursors[ImGuiMouseCursor_ResizeNWSE] = [NSCursor respondsToSelector:@selector(_windowResizeNorthWestSouthEastCursor)] ? [NSCursor _windowResizeNorthWestSouthEastCursor] : [NSCursor closedHandCursor];
    bd->MouseCursors[ImGuiMouseCursor_Hand] = [NSCursor pointingHandCursor];
    bd->MouseCursors[ImGuiMouseCursor_Wait] = bd->MouseCursors[ImGuiMouseCursor_Progress] = [NSCursor respondsToSelector:@selector(busyButClickableCursor)] ? [NSCursor busyButClickableCursor] : [NSCursor arrowCursor];
    bd->MouseCursors[ImGuiMouseCursor_NotAllowed] = [NSCursor operationNotAllowedCursor];

    // Note that imgui.cpp also include default OSX clipboard handlers which can be enabled
    // by adding '#define IMGUI_ENABLE_OSX_DEFAULT_CLIPBOARD_FUNCTIONS' in imconfig.h and adding '-framework ApplicationServices' to your linker command-line.
    // Since we are already in ObjC land here, it is easy for us to add a clipboard handler using the NSPasteboard api.
    platform_io.Platform_SetClipboardTextFn = [](ImGuiContext*, const char* str) -> void
    {
        NSPasteboard* pasteboard = [NSPasteboard generalPasteboard];
        [pasteboard declareTypes:[NSArray arrayWithObject:NSPasteboardTypeString] owner:nil];
        [pasteboard setString:[NSString stringWithUTF8String:str] forType:NSPasteboardTypeString];
    };

    platform_io.Platform_GetClipboardTextFn = [](ImGuiContext*) -> const char*
    {
        NSPasteboard* pasteboard = [NSPasteboard generalPasteboard];
        NSString* available = [pasteboard availableTypeFromArray: [NSArray arrayWithObject:NSPasteboardTypeString]];
        if (![available isEqualToString:NSPasteboardTypeString])
            return nullptr;

        NSString* string = [pasteboard stringForType:NSPasteboardTypeString];
        if (string == nil)
            return nullptr;

        const char* string_c = (const char*)[string UTF8String];
        size_t string_len = strlen(string_c);
        static ImVector<char> s_clipboard;
        s_clipboard.resize((int)string_len + 1);
        strcpy(s_clipboard.Data, string_c);
        return s_clipboard.Data;
    };

    [[NSNotificationCenter defaultCenter] addObserver:bd->Observer
                                             selector:@selector(onApplicationBecomeActive:)
                                                 name:NSApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:bd->Observer
                                             selector:@selector(onApplicationBecomeInactive:)
                                                 name:NSApplicationDidResignActiveNotification
                                               object:nil];

    // Add the NSTextInputClient to the view hierarchy,
    // to receive keyboard events and translate them to input text.
    bd->KeyEventResponder = [[KeyEventResponder alloc] initWithFrame:NSZeroRect];
    bd->InputContext = [[NSTextInputContext alloc] initWithClient:bd->KeyEventResponder];
    [view addSubview:bd->KeyEventResponder];
    ImGui_ImplOSX_AddTrackingArea(view);

    platform_io.Platform_SetImeDataFn = [](ImGuiContext*, ImGuiViewport*, ImGuiPlatformImeData* data) -> void
    {
        ImGui_ImplOSX_Data* bd = ImGui_ImplOSX_GetBackendData();
        if (data->WantVisible)
        {
            [bd->InputContext activate];
        }
        else
        {
            [bd->InputContext discardMarkedText];
            [bd->InputContext invalidateCharacterCoordinates];
            [bd->InputContext deactivate];
        }
        [bd->KeyEventResponder setImePosX:data->InputPos.x imePosY:data->InputPos.y + data->InputLineHeight];
    };

    return true;
}

void ImGui_ImplOSX_Shutdown()
{
    ImGui_ImplOSX_Data* bd = ImGui_ImplOSX_GetBackendData();
    IM_ASSERT(bd != nullptr && "No platform backend to shutdown, or already shutdown?");

    [[NSNotificationCenter defaultCenter] removeObserver:bd->Observer];
    bd->Observer = nullptr;
    if (bd->Monitor != nullptr)
    {
        [NSEvent removeMonitor:bd->Monitor];
        bd->Monitor = nullptr;
    }

    ImGui_ImplOSX_DestroyBackendData();

    ImGuiIO& io = ImGui::GetIO();
    ImGuiPlatformIO& platform_io = ImGui::GetPlatformIO();

    io.BackendPlatformName = nullptr;
    io.BackendPlatformUserData = nullptr;
    io.BackendFlags &= ~(ImGuiBackendFlags_HasMouseCursors | ImGuiBackendFlags_HasGamepad);
    platform_io.ClearPlatformHandlers();
}

static void ImGui_ImplOSX_UpdateMouseCursor()
{
    ImGui_ImplOSX_Data* bd = ImGui_ImplOSX_GetBackendData();
    ImGuiIO& io = ImGui::GetIO();
    if (io.ConfigFlags & ImGuiConfigFlags_NoMouseCursorChange)
        return;

    ImGuiMouseCursor imgui_cursor = ImGui::GetMouseCursor();
    if (io.MouseDrawCursor || imgui_cursor == ImGuiMouseCursor_None)
    {
        // Hide OS mouse cursor if imgui is drawing it or if it wants no cursor
        if (!bd->MouseCursorHidden)
        {
            bd->MouseCursorHidden = true;
            [NSCursor hide];
        }
    }
    else
    {
        NSCursor* desired = bd->MouseCursors[imgui_cursor] ?: bd->MouseCursors[ImGuiMouseCursor_Arrow];
        // -[NSCursor set] generates measurable overhead if called unconditionally.
        if (desired != NSCursor.currentCursor)
        {
            [desired set];
        }
        if (bd->MouseCursorHidden)
        {
            bd->MouseCursorHidden = false;
            [NSCursor unhide];
        }
    }
}

static void ImGui_ImplOSX_UpdateGamepads()
{
    ImGuiIO& io = ImGui::GetIO();

#if APPLE_HAS_CONTROLLER
    GCController* controller = GCController.current;
#else
    GCController* controller = GCController.controllers.firstObject;
#endif
    if (controller == nil || controller.extendedGamepad == nil)
    {
        io.BackendFlags &= ~ImGuiBackendFlags_HasGamepad;
        return;
    }

    GCExtendedGamepad* gp = controller.extendedGamepad;

    // Update gamepad inputs



    const float thumb_dead_zone = 0.0f;

#if APPLE_HAS_BUTTON_OPTIONS
    MAP_BUTTON(ImGuiKey_GamepadBack,            buttonOptions);
#endif
    MAP_BUTTON(ImGuiKey_GamepadFaceLeft,        buttonX);              // Xbox X, PS Square
    MAP_BUTTON(ImGuiKey_GamepadFaceRight,       buttonB);              // Xbox B, PS Circle
    MAP_BUTTON(ImGuiKey_GamepadFaceUp,          buttonY);              // Xbox Y, PS Triangle
    MAP_BUTTON(ImGuiKey_GamepadFaceDown,        buttonA);              // Xbox A, PS Cross
    MAP_BUTTON(ImGuiKey_GamepadDpadLeft,        dpad.left);
    MAP_BUTTON(ImGuiKey_GamepadDpadRight,       dpad.right);
    MAP_BUTTON(ImGuiKey_GamepadDpadUp,          dpad.up);
    MAP_BUTTON(ImGuiKey_GamepadDpadDown,        dpad.down);
    MAP_ANALOG(ImGuiKey_GamepadL1,              leftShoulder, 0.0f, 1.0f);
    MAP_ANALOG(ImGuiKey_GamepadR1,              rightShoulder, 0.0f, 1.0f);
    MAP_ANALOG(ImGuiKey_GamepadL2,              leftTrigger,  0.0f, 1.0f);
    MAP_ANALOG(ImGuiKey_GamepadR2,              rightTrigger, 0.0f, 1.0f);
#if APPLE_HAS_THUMBSTICKS
    MAP_BUTTON(ImGuiKey_GamepadL3,              leftThumbstickButton);
    MAP_BUTTON(ImGuiKey_GamepadR3,              rightThumbstickButton);
#endif
    MAP_ANALOG(ImGuiKey_GamepadLStickLeft,      leftThumbstick.xAxis,  -thumb_dead_zone, -1.0f);
    MAP_ANALOG(ImGuiKey_GamepadLStickRight,     leftThumbstick.xAxis,  +thumb_dead_zone, +1.0f);
    MAP_ANALOG(ImGuiKey_GamepadLStickUp,        leftThumbstick.yAxis,  +thumb_dead_zone, +1.0f);
    MAP_ANALOG(ImGuiKey_GamepadLStickDown,      leftThumbstick.yAxis,  -thumb_dead_zone, -1.0f);
    MAP_ANALOG(ImGuiKey_GamepadRStickLeft,      rightThumbstick.xAxis, -thumb_dead_zone, -1.0f);
    MAP_ANALOG(ImGuiKey_GamepadRStickRight,     rightThumbstick.xAxis, +thumb_dead_zone, +1.0f);
    MAP_ANALOG(ImGuiKey_GamepadRStickUp,        rightThumbstick.yAxis, +thumb_dead_zone, +1.0f);
    MAP_ANALOG(ImGuiKey_GamepadRStickDown,      rightThumbstick.yAxis, -thumb_dead_zone, -1.0f);
    #undef MAP_BUTTON
    #undef MAP_ANALOG

    io.BackendFlags |= ImGuiBackendFlags_HasGamepad;
}

static void ImGui_ImplOSX_UpdateImePosWithView(NSView* view)
{
    ImGui_ImplOSX_Data* bd = ImGui_ImplOSX_GetBackendData();
    ImGuiIO& io = ImGui::GetIO();
    if (io.WantTextInput)
        [bd->KeyEventResponder updateImePosWithView:view];
}

void ImGui_ImplOSX_NewFrame(NSView* view)
{
    ImGui_ImplOSX_Data* bd = ImGui_ImplOSX_GetBackendData();
    IM_ASSERT(bd != nullptr && "Context or backend not initialized! Did you call ImGui_ImplOSX_Init()?");
    ImGuiIO& io = ImGui::GetIO();

    // Setup display size
    if (view)
    {
        const float fb_scale = (float)[view.window backingScaleFactor];
        io.DisplaySize = ImVec2((float)view.bounds.size.width, (float)view.bounds.size.height);
        io.DisplayFramebufferScale = ImVec2(fb_scale, fb_scale);
    }

    // Setup time step
    if (bd->Time == 0.0)
        bd->Time = GetMachAbsoluteTimeInSeconds();

    double current_time = GetMachAbsoluteTimeInSeconds();
    io.DeltaTime = (float)(current_time - bd->Time);
    bd->Time = current_time;

    ImGui_ImplOSX_UpdateMouseCursor();
    ImGui_ImplOSX_UpdateGamepads();
    ImGui_ImplOSX_UpdateImePosWithView(view);
}

// Must only be called for a mouse event, otherwise an exception occurs
// (Note that NSEventTypeScrollWheel is considered "other input". Oddly enough an exception does not occur with it, but the value will sometimes be wrong!)
static ImGuiMouseSource GetMouseSource(NSEvent* event)
{
    switch (event.subtype)
    {
        case NSEventSubtypeTabletPoint:
            return ImGuiMouseSource_Pen;
        // macOS considers input from relative touch devices (like the trackpad or Apple Magic Mouse) to be touch input.
        // This doesn't really make sense for Dear ImGui, which expects absolute touch devices only.
        // There does not seem to be a simple way to disambiguate things here so we consider NSEventSubtypeTouch events to always come from mice.
        // See https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/EventOverview/HandlingTouchEvents/HandlingTouchEvents.html#//apple_ref/doc/uid/10000060i-CH13-SW24
        //case NSEventSubtypeTouch:
        //    return ImGuiMouseSource_TouchScreen;
        case NSEventSubtypeMouseEvent:
        default:
            return ImGuiMouseSource_Mouse;
    }
}

static bool ImGui_ImplOSX_HandleEvent(NSEvent* event, NSView* view)
{
    // Only process events from the window containing ImGui view
    if (event.window != view.window)
        return false;
    ImGuiIO& io = ImGui::GetIO();

    if (event.type == NSEventTypeLeftMouseDown || event.type == NSEventTypeRightMouseDown || event.type == NSEventTypeOtherMouseDown)
    {
        int button = (int)[event buttonNumber];
        if (button >= 0 && button < ImGuiMouseButton_COUNT)
        {
            io.AddMouseSourceEvent(GetMouseSource(event));
            io.AddMouseButtonEvent(button, true);
        }
        return io.WantCaptureMouse;
    }

    if (event.type == NSEventTypeLeftMouseUp || event.type == NSEventTypeRightMouseUp || event.type == NSEventTypeOtherMouseUp)
    {
        int button = (int)[event buttonNumber];
        if (button >= 0 && button < ImGuiMouseButton_COUNT)
        {
            io.AddMouseSourceEvent(GetMouseSource(event));
            io.AddMouseButtonEvent(button, false);
        }
        return io.WantCaptureMouse;
    }

    if (event.type == NSEventTypeMouseMoved || event.type == NSEventTypeLeftMouseDragged || event.type == NSEventTypeRightMouseDragged || event.type == NSEventTypeOtherMouseDragged)
    {
        NSPoint mousePoint = event.locationInWindow;
        if (event.window == nil)
            mousePoint = [[view window] convertPointFromScreen:mousePoint];
        mousePoint = [view convertPoint:mousePoint fromView:nil];
        if ([view isFlipped])
            mousePoint = NSMakePoint(mousePoint.x, mousePoint.y);
        else
            mousePoint = NSMakePoint(mousePoint.x, view.bounds.size.height - mousePoint.y);
        io.AddMouseSourceEvent(GetMouseSource(event));
        io.AddMousePosEvent((float)mousePoint.x, (float)mousePoint.y);
        return io.WantCaptureMouse;
    }

    if (event.type == NSEventTypeScrollWheel)
    {
        // Ignore canceled events.
        //
        // From macOS 12.1, scrolling with two fingers and then decelerating
        // by tapping two fingers results in two events appearing:
        //
        // 1. A scroll wheel NSEvent, with a phase == NSEventPhaseMayBegin, when the user taps
        // two fingers to decelerate or stop the scroll events.
        //
        // 2. A scroll wheel NSEvent, with a phase == NSEventPhaseCancelled, when the user releases the
        // two-finger tap. It is this event that sometimes contains large values for scrollingDeltaX and
        // scrollingDeltaY. When these are added to the current x and y positions of the scrolling view,
        // it appears to jump up or down. It can be observed in Preview, various JetBrains IDEs and here.
        if (event.phase == NSEventPhaseCancelled)
            return false;

        double wheel_dx = 0.0;
        double wheel_dy = 0.0;

        #if MAC_OS_X_VERSION_MAX_ALLOWED >= 1070
        if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6)
        {
            wheel_dx = [event scrollingDeltaX];
            wheel_dy = [event scrollingDeltaY];
            if ([event hasPreciseScrollingDeltas])
            {
                wheel_dx *= 0.01;
                wheel_dy *= 0.01;
            }
        }
        else
        #endif // MAC_OS_X_VERSION_MAX_ALLOWED
        {
            wheel_dx = [event deltaX] * 0.1;
            wheel_dy = [event deltaY] * 0.1;
        }
        if (wheel_dx != 0.0 || wheel_dy != 0.0)
            io.AddMouseWheelEvent((float)wheel_dx, (float)wheel_dy);

        return io.WantCaptureMouse;
    }

    if (event.type == NSEventTypeKeyDown || event.type == NSEventTypeKeyUp)
    {
        if ([event isARepeat])
            return io.WantCaptureKeyboard;

        int key_code = (int)[event keyCode];
        ImGuiKey key = ImGui_ImplOSX_KeyCodeToImGuiKey(key_code);
        io.AddKeyEvent(key, event.type == NSEventTypeKeyDown);
        io.SetKeyEventNativeData(key, key_code, -1); // To support legacy indexing (<1.87 user code)

        return io.WantCaptureKeyboard;
    }

    if (event.type == NSEventTypeFlagsChanged)
    {
        unsigned short key_code = [event keyCode];
        NSEventModifierFlags modifier_flags = [event modifierFlags];

        io.AddKeyEvent(ImGuiMod_Shift, (modifier_flags & NSEventModifierFlagShift)   != 0);
        io.AddKeyEvent(ImGuiMod_Ctrl,  (modifier_flags & NSEventModifierFlagControl) != 0);
        io.AddKeyEvent(ImGuiMod_Alt,   (modifier_flags & NSEventModifierFlagOption)  != 0);
        io.AddKeyEvent(ImGuiMod_Super, (modifier_flags & NSEventModifierFlagCommand) != 0);

        ImGuiKey key = ImGui_ImplOSX_KeyCodeToImGuiKey(key_code);
        if (key != ImGuiKey_None)
        {
            // macOS does not generate down/up event for modifiers. We're trying
            // to use hardware dependent masks to extract that information.
            // 'imgui_mask' is left as a fallback.
            NSEventModifierFlags mask = 0;
            switch (key)
            {
                case ImGuiKey_LeftCtrl:   mask = 0x0001; break;
                case ImGuiKey_RightCtrl:  mask = 0x2000; break;
                case ImGuiKey_LeftShift:  mask = 0x0002; break;
                case ImGuiKey_RightShift: mask = 0x0004; break;
                case ImGuiKey_LeftSuper:  mask = 0x0008; break;
                case ImGuiKey_RightSuper: mask = 0x0010; break;
                case ImGuiKey_LeftAlt:    mask = 0x0020; break;
                case ImGuiKey_RightAlt:   mask = 0x0040; break;
                default:
                    return io.WantCaptureKeyboard;
            }
            io.AddKeyEvent(key, (modifier_flags & mask) != 0);
            io.SetKeyEventNativeData(key, key_code, -1); // To support legacy indexing (<1.87 user code)
        }

        return io.WantCaptureKeyboard;
    }

    return false;
}

static void ImGui_ImplOSX_AddTrackingArea(NSView* _Nonnull view)
{
    // If we want to receive key events, we either need to be in the responder chain of the key view,
    // or else we can install a local monitor. The consequence of this heavy-handed approach is that
    // we receive events for all controls, not just Dear ImGui widgets. If we had native controls in our
    // window, we'd want to be much more careful than just ingesting the complete event stream.
    // To match the behavior of other backends, we pass every event down to the OS.
    ImGui_ImplOSX_Data* bd = ImGui_ImplOSX_GetBackendData();
    if (bd->Monitor)
        return;
    NSEventMask eventMask = 0;
    eventMask |= NSEventMaskMouseMoved | NSEventMaskScrollWheel;
    eventMask |= NSEventMaskLeftMouseDown | NSEventMaskLeftMouseUp | NSEventMaskLeftMouseDragged;
    eventMask |= NSEventMaskRightMouseDown | NSEventMaskRightMouseUp | NSEventMaskRightMouseDragged;
    eventMask |= NSEventMaskOtherMouseDown | NSEventMaskOtherMouseUp | NSEventMaskOtherMouseDragged;
    eventMask |= NSEventMaskKeyDown | NSEventMaskKeyUp | NSEventMaskFlagsChanged;
    bd->Monitor = [NSEvent addLocalMonitorForEventsMatchingMask:eventMask
                                                        handler:^NSEvent* _Nullable(NSEvent* event)
    {
        ImGui_ImplOSX_HandleEvent(event, view);
        return event;
    }];
}

//-----------------------------------------------------------------------------

#endif // #ifndef IMGUI_DISABLE

#pragma warning(pop)
#pragma pack(pop)
// --- SANDBOX END: imgui_impl_osx.mm ---

#endif // defined(IMGUI_BUILD_BACKEND_OSX)


#if defined(IMGUI_BUILD_EXAMPLE_METAL)
// --- SANDBOX START: main.mm ---
#pragma pack(push)
#pragma warning(push)
// [SOURCE: main.mm]
// Dear ImGui: standalone example application for SDL3 + Metal
// (SDL is a cross-platform general purpose library for handling windows, inputs, OpenGL/Vulkan/Metal graphics context creation, etc.)

// Learn about Dear ImGui:
// - FAQ                  https://dearimgui.com/faq
// - Getting Started      https://dearimgui.com/getting-started
// - Documentation        https://dearimgui.com/docs (same as your local docs/ folder).
// - Introduction, links and more at the top of imgui.cpp



          // printf, fprintf



// Main code
int main(int, char**)
{
    // Setup SDL
    // [If using SDL_MAIN_USE_CALLBACKS: all code below until the main loop starts would likely be your SDL_AppInit() function]
    if (!SDL_Init(SDL_INIT_VIDEO | SDL_INIT_GAMEPAD))
    {
        printf("Error: SDL_Init(): %s\n", SDL_GetError());
        return 1;
    }

    // Create SDL window graphics context
    float main_scale = SDL_GetDisplayContentScale(SDL_GetPrimaryDisplay());
    SDL_WindowFlags window_flags = SDL_WINDOW_METAL | SDL_WINDOW_RESIZABLE | SDL_WINDOW_HIDDEN | SDL_WINDOW_HIGH_PIXEL_DENSITY;
    SDL_Window* window = SDL_CreateWindow("Dear ImGui SDL3+Metal example", (int)(1280 * main_scale), (int)(800 * main_scale), window_flags);
    if (window == nullptr)
    {
        printf("Error: SDL_CreateWindow(): %s\n", SDL_GetError());
        return 1;
    }
    SDL_SetWindowPosition(window, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED);
    SDL_ShowWindow(window);

    // Create Metal device _before_ creating the view/layer
    id<MTLDevice> metalDevice = MTLCreateSystemDefaultDevice();
    if (!metalDevice)
    {
        printf("Error: failed to create Metal device.\n");
        SDL_DestroyWindow(window);
        SDL_Quit();
        return 1;
    }
    SDL_MetalView view = SDL_Metal_CreateView(window);
    CAMetalLayer* layer = (__bridge CAMetalLayer*)SDL_Metal_GetLayer(view);
    layer.device = metalDevice;
    layer.pixelFormat = MTLPixelFormatBGRA8Unorm;

    id<MTLCommandQueue> commandQueue = [layer.device newCommandQueue];
    MTLRenderPassDescriptor* renderPassDescriptor = [MTLRenderPassDescriptor new];

    // Setup Dear ImGui context
    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO(); (void)io;
    io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;     // Enable Keyboard Controls
    io.ConfigFlags |= ImGuiConfigFlags_NavEnableGamepad;      // Enable Gamepad Controls

    // Setup Dear ImGui style
    ImGui::StyleColorsDark();
    //ImGui::StyleColorsLight();

    // Setup scaling
    ImGuiStyle& style = ImGui::GetStyle();
    style.ScaleAllSizes(main_scale);        // Bake a fixed style scale. (until we have a solution for dynamic style scaling, changing this requires resetting Style + calling this again)
    style.FontScaleDpi = main_scale;        // Set initial font scale. (using io.ConfigDpiScaleFonts=true makes this unnecessary. We leave both here for documentation purpose)

    // Setup Platform/Renderer backends
    ImGui_ImplMetal_Init(layer.device);
    ImGui_ImplSDL3_InitForMetal(window);

    // Load Fonts
    // - If fonts are not explicitly loaded, Dear ImGui will call AddFontDefault() to select an embedded font: either AddFontDefaultVector() or AddFontDefaultBitmap().
    //   This selection is based on (style.FontSizeBase * style.FontScaleMain * style.FontScaleDpi) reaching a small threshold.
    // - You can load multiple fonts and use ImGui::PushFont()/PopFont() to select them.
    // - If a file cannot be loaded, AddFont functions will return a nullptr. Please handle those errors in your code (e.g. use an assertion, display an error and quit).
    // - Read 'docs/FONTS.md' for more instructions and details.
    // - Use '#define IMGUI_ENABLE_FREETYPE' in your imconfig file to use FreeType for higher quality font rendering.
    // - Remember that in C/C++ if you want to include a backslash \ in a string literal you need to write a double backslash \\ !
    //style.FontSizeBase = 20.0f;
    //io.Fonts->AddFontDefaultVector();
    //io.Fonts->AddFontDefaultBitmap();
    //io.Fonts->AddFontFromFileTTF("c:\\Windows\\Fonts\\segoeui.ttf");
    //io.Fonts->AddFontFromFileTTF("../../misc/fonts/DroidSans.ttf");
    //io.Fonts->AddFontFromFileTTF("../../misc/fonts/Roboto-Medium.ttf");
    //io.Fonts->AddFontFromFileTTF("../../misc/fonts/Cousine-Regular.ttf");
    //ImFont* font = io.Fonts->AddFontFromFileTTF("c:\\Windows\\Fonts\\ArialUni.ttf");
    //IM_ASSERT(font != nullptr);

    // Our state
    bool show_demo_window = true;
    bool show_another_window = false;
    float clear_color[4] = { 0.45f, 0.55f, 0.60f, 1.00f };

    // Main loop
    bool done = false;
    while (!done)
    {
        @autoreleasepool
        {
            // Poll and handle events (inputs, window resize, etc.)
            // You can read the io.WantCaptureMouse, io.WantCaptureKeyboard flags to tell if dear imgui wants to use your inputs.
            // - When io.WantCaptureMouse is true, do not dispatch mouse input data to your main application, or clear/overwrite your copy of the mouse data.
            // - When io.WantCaptureKeyboard is true, do not dispatch keyboard input data to your main application, or clear/overwrite your copy of the keyboard data.
            // Generally you may always pass all inputs to dear imgui, and hide them from your application based on those two flags.
            // [If using SDL_MAIN_USE_CALLBACKS: call ImGui_ImplSDL3_ProcessEvent() from your SDL_AppEvent() function]
            SDL_Event event;
            while (SDL_PollEvent(&event))
            {
                ImGui_ImplSDL3_ProcessEvent(&event);
                if (event.type == SDL_EVENT_QUIT)
                    done = true;
                if (event.type == SDL_EVENT_WINDOW_CLOSE_REQUESTED && event.window.windowID == SDL_GetWindowID(window))
                    done = true;
            }

            // [If using SDL_MAIN_USE_CALLBACKS: all code below would likely be your SDL_AppIterate() function]
            if (SDL_GetWindowFlags(window) & SDL_WINDOW_MINIMIZED)
            {
                SDL_Delay(10);
                continue;
            }

            int width, height;
            SDL_GetWindowSizeInPixels(window, &width, &height);

            layer.drawableSize = CGSizeMake(width, height);
            id<CAMetalDrawable> drawable = [layer nextDrawable];

            id<MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];
            renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(clear_color[0] * clear_color[3], clear_color[1] * clear_color[3], clear_color[2] * clear_color[3], clear_color[3]);
            renderPassDescriptor.colorAttachments[0].texture = drawable.texture;
            renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
            renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
            id <MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
            [renderEncoder pushDebugGroup:@"ImGui demo"];

            // Start the Dear ImGui frame
            ImGui_ImplMetal_NewFrame(renderPassDescriptor);
            ImGui_ImplSDL3_NewFrame();
            ImGui::NewFrame();

            // 1. Show the big demo window (Most of the sample code is in ImGui::ShowDemoWindow()! You can browse its code to learn more about Dear ImGui!).
            if (show_demo_window)
                ImGui::ShowDemoWindow(&show_demo_window);

            // 2. Show a simple window that we create ourselves. We use a Begin/End pair to create a named window.
            {
                static float f = 0.0f;
                static int counter = 0;

                ImGui::Begin("Hello, world!");                          // Create a window called "Hello, world!" and append into it.

                ImGui::Text("This is some useful text.");               // Display some text (you can use a format strings too)
                ImGui::Checkbox("Demo Window", &show_demo_window);      // Edit bools storing our window open/close state
                ImGui::Checkbox("Another Window", &show_another_window);

                ImGui::SliderFloat("float", &f, 0.0f, 1.0f);            // Edit 1 float using a slider from 0.0f to 1.0f
                ImGui::ColorEdit3("clear color", (float*)&clear_color); // Edit 3 floats representing a color

                if (ImGui::Button("Button"))                            // Buttons return true when clicked (most widgets return true when edited/activated)
                    counter++;
                ImGui::SameLine();
                ImGui::Text("counter = %d", counter);

                ImGui::Text("Application average %.3f ms/frame (%.1f FPS)", 1000.0f / io.Framerate, io.Framerate);
                ImGui::End();
            }

            // 3. Show another simple window.
            if (show_another_window)
            {
                ImGui::Begin("Another Window", &show_another_window);   // Pass a pointer to our bool variable (the window will have a closing button that will clear the bool when clicked)
                ImGui::Text("Hello from another window!");
                if (ImGui::Button("Close Me"))
                    show_another_window = false;
                ImGui::End();
            }

            // Rendering
            ImGui::Render();
            ImDrawData* draw_data = ImGui::GetDrawData();
            ImGui_ImplMetal_RenderDrawData(draw_data, commandBuffer, renderEncoder);

            [renderEncoder popDebugGroup];
            [renderEncoder endEncoding];

            [commandBuffer presentDrawable:drawable];
            [commandBuffer commit];
        }
    }

    // Cleanup
    // [If using SDL_MAIN_USE_CALLBACKS: all code below would likely be your SDL_AppQuit() function]
    ImGui_ImplMetal_Shutdown();
    ImGui_ImplSDL3_Shutdown();
    ImGui::DestroyContext();

    SDL_DestroyWindow(window);
    SDL_Quit();

    return 0;
}

#pragma warning(pop)
#pragma pack(pop)
// --- SANDBOX END: main.mm ---

#endif // defined(IMGUI_BUILD_EXAMPLE_METAL)

