# © 2024 AO Kaspersky Lab
# Licensed under the 3-Clause BSD License

project(consumer)

# Set compilation flags.
project_header_default("STANDARD_GNU_11:YES" "EXTRA_STRICT_WARNINGS:YES")

add_nk_edl(CONSUMER_EDL
  "${RESOURCES}/edl/Consumer.edl"
  NK_MODULE example 
  LANG "CXX"
)
bind_nk_targets(CONSUMER_EDL CONSUMER_IDL)
add_executable(Consumer
  ${PROTOBUF_GENERATED_FILES}
  src/main.cpp
)
bind_nk_targets(Consumer CONSUMER_EDL)
add_dependencies(Consumer PROTOBUF_GENERATE)
target_compile_features(Consumer PRIVATE cxx_std_17)
target_compile_options(Consumer PRIVATE -fexceptions -Wno-conversion -Wno-sign-conversion -Wno-undef)
target_link_libraries(Consumer PRIVATE protobuf::libprotobuf)
