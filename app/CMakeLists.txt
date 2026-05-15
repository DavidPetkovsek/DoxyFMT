# doxyfmt: the user-facing binary. The only target we install.

add_executable(doxyfmt
  main.cpp
)

target_link_libraries(doxyfmt
  PRIVATE
    doxyfmt::core
    doxyfmt::warnings
    doxyfmt::sanitizers
)

set_target_properties(doxyfmt PROPERTIES
  OUTPUT_NAME doxyfmt
)
