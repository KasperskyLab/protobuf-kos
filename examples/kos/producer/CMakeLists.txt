# © 2024 AO Kaspersky Lab
# Licensed under the 3-Clause BSD License

project(producer)

# Set the linker and compiler flags.
project_header_default("STANDARD_GNU_11:YES" "EXTRA_STRICT_WARNINGS:YES")

add_nk_edl(PRODUCER_EDL
  "${RESOURCES}/edl/Producer.edl"
  NK_MODULE example 
  LANG "CXX"
)
bind_nk_targets(PRODUCER_EDL CONSUMER_IDL)
add_executable(Producer
  ${PROTOBUF_GENERATED_FILES}
  src/main.cpp
)
bind_nk_targets(Producer PRODUCER_EDL)
add_dependencies(Producer PROTOBUF_GENERATE)
target_compile_features(Producer PRIVATE cxx_std_17)
target_compile_options(Producer PRIVATE -fexceptions -Wno-conversion -Wno-sign-conversion -Wno-undef)
target_link_libraries(Producer
  PRIVATE
    protobuf::libprotobuf
    ${vfs_CLIENT_LIB}
)

# We do not need default VFS program here, which comes from ${vfs_PRODUCER_LIB}.
set_target_properties(Producer PROPERTIES ${vfs_ENTITY}_REPLACEMENT "")
