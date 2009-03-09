######################################################################################
# Add subdirectories
######################################################################################

SET(FIVETEN_SCRIPT_DIR ${NP_CMAKE_DIR}/scripts)
LIST(APPEND CMAKE_MODULE_PATH ${NP_CMAKE_DIR}/find)

INCLUDE(${NP_CMAKE_DIR}/NPCMakeOptions.cmake)
INCLUDE(${NP_CMAKE_DIR}/NPCMakeFunctions.cmake)

######################################################################################
# Initialize Build Function
######################################################################################

MACRO(INITIALIZE_BUILD)

  #Add the find subdirectory, so we can keep our repository nice and tidy
  LIST(APPEND CMAKE_MODULE_PATH ${NP_MODULE_DIR}/find)

  MACRO_ENSURE_OUT_OF_SOURCE_BUILD()

  IF(NOT CMAKE_BUILD_TYPE)
	SET(CMAKE_BUILD_TYPE Release)
	MESSAGE(STATUS "No build type specified, using default: ${CMAKE_BUILD_TYPE}")
  ELSE(NOT CMAKE_BUILD_TYPE)
	MESSAGE(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
  ENDIF(NOT CMAKE_BUILD_TYPE)

  SET(PROJECT_DIR ${CMAKE_CURRENT_SOURCE_DIR})
  SET(EXECUTABLE_OUTPUT_PATH ${CMAKE_CURRENT_BINARY_DIR}/bin)
  SET(LIBRARY_OUTPUT_PATH ${CMAKE_CURRENT_BINARY_DIR}/lib)

  LIST(APPEND CMAKE_PREFIX_PATH "${PROJECT_DIR}/../library/usr_${NP_BUILD_PLATFORM}")
  LIST(INSERT CMAKE_FIND_ROOT_PATH 0 "${PROJECT_DIR}/../library/usr_${NP_BUILD_PLATFORM}")
  
  MESSAGE(STATUS "PREFIX: ${CMAKE_PREFIX_PATH}")

  IF(UNIX)
	IF(NOT PREFIX_DIR)
      SET(PREFIX_DIR /usr/local)
	ENDIF(NOT PREFIX_DIR)
	IF(NOT INCLUDE_INSTALL_DIR)
      SET(INCLUDE_INSTALL_DIR ${PREFIX_DIR}/include)
	ENDIF(NOT INCLUDE_INSTALL_DIR)
	IF(NOT LIBRARY_INSTALL_DIR)
      SET(LIBRARY_INSTALL_DIR ${PREFIX_DIR}/lib)
	ENDIF(NOT LIBRARY_INSTALL_DIR)
	IF(NOT RUNTIME_INSTALL_DIR)
      SET(RUNTIME_INSTALL_DIR ${PREFIX_DIR}/bin)
	ENDIF(NOT RUNTIME_INSTALL_DIR)
  ENDIF(UNIX)

  #Always assume we want to build threadsafe mingw binaries
  IF(MINGW)
	SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mthreads")
	SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mthreads")
	SET(CMAKE_LINK_FLAGS "${CMAKE_LINK_FLAGS} -mthreads")
  ENDIF(MINGW)

  MESSAGE(STATUS "Install Directory Prefix: ${PREFIX_DIR}")
  MESSAGE(STATUS "Include Install Directory: ${INCLUDE_INSTALL_DIR}")
  MESSAGE(STATUS "Library Install Directory: ${LIBRARY_INSTALL_DIR}")
  MESSAGE(STATUS "Runtime Install Directory: ${RUNTIME_INSTALL_DIR}")

ENDMACRO(INITIALIZE_BUILD)