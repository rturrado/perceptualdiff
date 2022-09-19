project(perceptualdiff)

cmake_policy(SET CMP0128 NEW)

cmake_minimum_required(VERSION 3.1...3.22)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(OpenMP)

set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR})

include(FetchContent)
FetchContent_Declare(FreeImage
    GIT_REPOSITORY https://github.com/rturrado/FreeImage.git
    GIT_TAG "662a30053ef0fb3e0a15e52967077eb7a84ec448"
)
FetchContent_MakeAvailable(FreeImage)
message(STATUS
    "[${PROJECT_NAME}] Target include directories:\n"
    "      FreeImage: ${FreeImage_SOURCE_DIR}/Source\n"
)

add_library(pdiff lpyramid.cpp rgba_image.cpp metric.cpp)
target_include_directories(pdiff SYSTEM PRIVATE ${FreeImage_SOURCE_DIR}/Source)
target_link_libraries(pdiff PRIVATE
    FreeImage
    OpenMP::OpenMP_CXX
)

if(NOT MSVC)
    target_compile_options(pdiff PRIVATE
        -Wall -Wextra -pedantic -Wcast-qual -Wpointer-arith -Winit-self
        -Wswitch-default -Wmissing-include-dirs -Wold-style-cast
        -Wnon-virtual-dtor -Wshadow -Wno-unknown-pragmas
    )
endif()

option(SANITIZERS "Enable sanitizers" FALSE)
if(SANITIZERS)
    target_compile_options(pdiff PRIVATE
        -fsanitize=address,undefined -fno-omit-frame-pointer
    )
    set(CMAKE_EXE_LINKER_FLAGS
        "${CMAKE_EXE_LINKER_FLAGS} -fsanitize=address,undefined"
    )
endif()

# Packing stuff.
set(CPACK_PACKAGE_VERSION_MAJOR "1")
set(CPACK_PACKAGE_VERSION_MINOR "2")
set(CPACK_PACKAGE_VERSION_PATCH "0")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "An image comparison utility.")
set(CPACK_PACKAGE_VENDOR "pdiff dev team")
set(CPACK_PACKAGE_DESCRIPTION_FILE ${CMAKE_CURRENT_SOURCE_DIR}/README.md)
set(CPACK_GENERATOR TGZ)
set(CPACK_SOURCE_PACKAGE_FILE_NAME
    "perceptualdiff-${CPACK_PACKAGE_VERSION_MAJOR}.${CPACK_PACKAGE_VERSION_MINOR}.${CPACK_PACKAGE_VERSION_PATCH}"
    CACHE INTERNAL "tarball basename"
)
set(CPACK_SOURCE_GENERATOR TGZ)
# The following components are regex's to match anywhere (unless anchored)
# in absolute path + filename to find files or directories to be excluded
# from source tarball.
set(CPACK_SOURCE_IGNORE_FILES
    "~$"
    "/\\\\.gitignore$"
    "/\\\\..*\\\\.swp$"
    "^${PROJECT_SOURCE_DIR}/\\\\.git/"
    "^${PROJECT_SOURCE_DIR}/CMakeFiles/"
    "^${PROJECT_SOURCE_DIR}/CMakeCache.txt"
    "^${PROJECT_SOURCE_DIR}/CPackSourceConfig.cmake"
    "^${PROJECT_SOURCE_DIR}/CPackConfig.cmake"
    "^${PROJECT_SOURCE_DIR}/CTestTestfile.cmake"
    "^${PROJECT_SOURCE_DIR}/Makefile"
    "^${PROJECT_SOURCE_DIR}/_CPack_Packages"
    "^${PROJECT_SOURCE_DIR}/cmake_install.cmake"
    "^${PROJECT_SOURCE_DIR}/install_manifest.txt"
    "^${PROJECT_SOURCE_DIR}/perceptualdiff"
    "^${PROJECT_SOURCE_DIR}/perceptualdiff-.*"
    "^${PROJECT_SOURCE_DIR}/Testing"
    "^${PROJECT_SOURCE_DIR}/coverage_output"
)
include(CPack)
