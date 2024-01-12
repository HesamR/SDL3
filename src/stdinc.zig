const internal = @import("internal.zig");
const Error = internal.Error;

pub const FunctionPointer = *const fn () callconv(.C) void;

pub const MallocFn = *const fn (usize) callconv(.C) ?*anyopaque;
pub const CallocFn = *const fn (usize, usize) callconv(.C) ?*anyopaque;
pub const ReallocFn = *const fn (?*anyopaque, usize) callconv(.C) ?*anyopaque;
pub const FreeFn = *const fn (?*anyopaque) callconv(.C) void;

/// Get the original set of SDL memory functions
///
/// \param malloc_func filled with malloc function
/// \param calloc_func filled with calloc function
/// \param realloc_func filled with realloc function
/// \param free_func filled with free function
///
pub fn getOriginalMemoryFunctions(malloc_func: *MallocFn, calloc_func: *CallocFn, realloc_func: *ReallocFn, free_func: *FreeFn) void {
    SDL_GetOriginalMemoryFunctions(malloc_func, calloc_func, realloc_func, free_func);
}

/// Get the current set of SDL memory functions
///
/// \param malloc_func filled with malloc function
/// \param calloc_func filled with calloc function
/// \param realloc_func filled with realloc function
/// \param free_func filled with free function
///
pub fn getMemoryFunctions(malloc_func: *MallocFn, calloc_func: *CallocFn, realloc_func: *ReallocFn, free_func: *FreeFn) void {
    SDL_GetMemoryFunctions(malloc_func, calloc_func, realloc_func, free_func);
}

/// Replace SDL's memory allocation functions with a custom set
///
/// \param malloc_func custom malloc function
/// \param calloc_func custom calloc function
/// \param realloc_func custom realloc function
/// \param free_func custom free function
/// \returns 0 on success or a negative error code on failure; call
///          SDL_GetError() for more information.
///
pub fn setMemoryFunctions(malloc_func: MallocFn, calloc_func: CallocFn, realloc_func: ReallocFn, free_func: FreeFn) Error!void {
    try internal.checkResult(SDL_SetMemoryFunctions(malloc_func, calloc_func, realloc_func, free_func));
}

/// Get the number of outstanding (unfreed) allocations
///
/// \returns the number of allocations
///
pub fn getNumAllocations() c_int {
    return getNumAllocations();
}

pub fn free(mem: *anyopaque) void {
    SDL_free(mem);
}

extern fn SDL_GetOriginalMemoryFunctions(malloc_func: *MallocFn, calloc_func: *CallocFn, realloc_func: *ReallocFn, free_func: *FreeFn) void;
extern fn SDL_GetMemoryFunctions(malloc_func: *MallocFn, calloc_func: *CallocFn, realloc_func: *ReallocFn, free_func: *FreeFn) void;
extern fn SDL_SetMemoryFunctions(malloc_func: MallocFn, calloc_func: CallocFn, realloc_func: ReallocFn, free_func: FreeFn) c_int;
extern fn SDL_GetNumAllocations() c_int;
extern fn SDL_free(mem: *anyopaque) void;

// extern fn SDL_malloc(size: usize) ?*anyopaque;
// extern fn SDL_calloc(nmemb: usize, size: usize) ?*anyopaque;
// extern fn SDL_realloc(mem: ?*anyopaque, size: usize) ?*anyopaque;
// extern fn SDL_aligned_alloc(alignment: usize, size: usize) ?*anyopaque;
// extern fn SDL_aligned_free(mem: ?*anyopaque) void;
