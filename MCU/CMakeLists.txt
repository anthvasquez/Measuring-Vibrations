cmake_minimum_required(VERSION 3.5)
project(MeasuringVibrations CXX)

# additional non-gui modules
set(LIB_SOURCE UARTDriver.hpp UARTDriver.cpp)

# add source for any additional gui modules here
set(UI_SOURCE QTGUI.hpp QTGUI.cpp)

# add source for simmips program here
set(MV_SOURCE MeasuringVibrations.cpp)

# You should not need to edit below this line
#-----------------------------------------------------------------------
#-----------------------------------------------------------------------

# try to prevent accidental in-source builds, these cause lots of problems
if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
  message(FATAL_ERROR "In-source builds not allowed. Remove any files created thus far and use a different directory for the build.")
endif()

# require a C++11 compiler for all targets
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -pthread -lwiringPi")

# configure Qt
set(CMAKE_AUTOMOC ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)
find_package(Qt5 COMPONENTS Widgets Charts Core Test REQUIRED)

# optional strict mode
if(UNIX AND STRICT)
  message("-- Enabling strict compilation mode")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall")
endif()

add_executable(measuring_vibrations ${MV_SOURCE} ${UI_SOURCE} ${LIB_SOURCE})
if(UNIX AND NOT APPLE AND CMAKE_COMPILER_IS_GNUCXX)
	target_link_libraries(measuring_vibrations Qt5::Core Qt5::Charts Qt5::Widgets pthread)
endif()

