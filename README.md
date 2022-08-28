# perceptualdiff
Fork of [myint/perceptualdiff](https://github.com/myint/perceptualdiff), a program that compares two images using a perceptually based image metric.

This fork:
- Added mlomb/FreeImage through FetchContent.
- Removed creation of PerceptualDiff executable.
- Removed install command.
- Fixed cmake_minimum_required deprecation warning when adding perceptualdiff to another project.
- Added check for CMake policy CMP0128.
