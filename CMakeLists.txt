cmake_minimum_required(VERSION 3.22)
project(loader)

set(CMAKE_CXX_STANDARD 20)

option(STATIC_LIB "is LIB static" OFF)
add_library(mylib SHARED lib.cpp)
target_compile_definitions(mylib PRIVATE STATIC_LIB="${STATIC_LIB}")
if (STATIC_LIB)
    target_compile_options(mylib PRIVATE -static-libgcc -static-libstdc++)
endif ()

add_executable(loader main.cpp)
add_dependencies(loader mylib)
target_link_libraries(loader PRIVATE ${CMAKE_DL_LIBS})
target_compile_definitions(loader PRIVATE MYSODIR="${CMAKE_CURRENT_BINARY_DIR}")

option(STATIC_APP "is APP static" OFF)
target_compile_definitions(loader PRIVATE STATIC_APP="${STATIC_APP}")
if (STATIC_APP)
    target_compile_options(loader PRIVATE -static-libgcc -static-libstdc++)
endif ()





