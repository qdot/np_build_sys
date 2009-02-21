######################################################################################
# Parse Arguments Macro (for named argument building)
######################################################################################

#taken from http://www.cmake.org/Wiki/CMakeMacroParseArguments

MACRO(PARSE_ARGUMENTS prefix arg_names option_names)
  SET(DEFAULT_ARGS)
  FOREACH(arg_name ${arg_names})    
    SET(${prefix}_${arg_name})
  ENDFOREACH(arg_name)
  FOREACH(option ${option_names})
    SET(${prefix}_${option} FALSE)
  ENDFOREACH(option)

  SET(current_arg_name DEFAULT_ARGS)
  SET(current_arg_list)
  FOREACH(arg ${ARGN})            
    SET(larg_names ${arg_names})    
    LIST(FIND larg_names "${arg}" is_arg_name)                   
    IF (is_arg_name GREATER -1)
      SET(${prefix}_${current_arg_name} ${current_arg_list})
      SET(current_arg_name ${arg})
      SET(current_arg_list)
    ELSE (is_arg_name GREATER -1)
      SET(loption_names ${option_names})    
      LIST(FIND loption_names "${arg}" is_option)            
      IF (is_option GREATER -1)
	     SET(${prefix}_${arg} TRUE)
      ELSE (is_option GREATER -1)
	     SET(current_arg_list ${current_arg_list} ${arg})
      ENDIF (is_option GREATER -1)
    ENDIF (is_arg_name GREATER -1)
  ENDFOREACH(arg)
  SET(${prefix}_${current_arg_name} ${current_arg_list})
ENDMACRO(PARSE_ARGUMENTS)
MACRO(PARSE_ARGUMENTS prefix arg_names option_names)
  SET(DEFAULT_ARGS)
  FOREACH(arg_name ${arg_names})    
    SET(${prefix}_${arg_name})
  ENDFOREACH(arg_name)
  FOREACH(option ${option_names})
    SET(${prefix}_${option} FALSE)
  ENDFOREACH(option)

  SET(current_arg_name DEFAULT_ARGS)
  SET(current_arg_list)
  FOREACH(arg ${ARGN})            
    SET(larg_names ${arg_names})    
    LIST(FIND larg_names "${arg}" is_arg_name)                   
    IF (is_arg_name GREATER -1)
      SET(${prefix}_${current_arg_name} ${current_arg_list})
      SET(current_arg_name ${arg})
      SET(current_arg_list)
    ELSE (is_arg_name GREATER -1)
      SET(loption_names ${option_names})    
      LIST(FIND loption_names "${arg}" is_option)            
      IF (is_option GREATER -1)
	     SET(${prefix}_${arg} TRUE)
      ELSE (is_option GREATER -1)
	     SET(current_arg_list ${current_arg_list} ${arg})
      ENDIF (is_option GREATER -1)
    ENDIF (is_arg_name GREATER -1)
  ENDFOREACH(arg)
  SET(${prefix}_${current_arg_name} ${current_arg_list})
ENDMACRO(PARSE_ARGUMENTS)

######################################################################################
# Compile flag array building macro
######################################################################################

#taken from http://www.cmake.org/pipermail/cmake/2006-February/008334.html

MACRO(SET_COMPILE_FLAGS TARGET)
  SET(FLAGS)
  FOREACH(flag ${ARGN})
    SET(FLAGS "${FLAGS} ${flag}")
  ENDFOREACH(flag)
  SET_TARGET_PROPERTIES(${TARGET} PROPERTIES COMPILE_FLAGS "${FLAGS}")
ENDMACRO(SET_COMPILE_FLAGS)

######################################################################################
# Generalized library building function for libraries
######################################################################################

FUNCTION(NP_BUILD_LIB)
  PARSE_ARGUMENTS(NP_LIB
	"NAME;SOURCES;CXX_FLAGS;LINK_LIBS;LINK_FLAGS;DEPENDS"
	""
	${ARGN}
	)

  FOREACH(LIB_TYPE ${NP_LIB_TYPES})
    SET(CURRENT_LIB ${NP_LIB_NAME}_${LIB_TYPE})
    ADD_LIBRARY (${CURRENT_LIB} ${LIB_TYPE} ${NP_LIB_SOURCES})
	LIST(APPEND LIB_DEPEND_LIST ${CURRENT_LIB})
    SET_TARGET_PROPERTIES (${CURRENT_LIB} PROPERTIES OUTPUT_NAME ${NP_LIB_NAME})
    SET_TARGET_PROPERTIES (${CURRENT_LIB} PROPERTIES CLEAN_DIRECT_OUTPUT 1)

    #optional arguments
	IF(NP_LIB_LINK_LIBS)
      FOREACH(LINK_LIB ${NP_LIB_LINK_LIBS})
		TARGET_LINK_LIBRARIES(${CURRENT_LIB} ${LINK_LIB})
      ENDFOREACH(LINK_LIB ${NP_LIB_LINK_LIBS})
	ENDIF(NP_LIB_LINK_LIBS)

    #cpp defines
    IF(NP_LIB_CXX_FLAGS)
      SET_COMPILE_FLAGS(${CURRENT_LIB} ${NP_LIB_CXX_FLAGS})
    ENDIF(NP_LIB_CXX_FLAGS)

    IF(NP_LIB_LINK_FLAGS)
      SET_TARGET_PROPERTIES(${CURRENT_LIB} PROPERTIES LINK_FLAGS ${NP_LIB_LINK_FLAGS})
    ENDIF(NP_LIB_LINK_FLAGS)

    #installation for non-windows platforms
    IF(NOT WIN32)
      INSTALL(TARGETS ${CURRENT_LIB} LIBRARY DESTINATION ${LIBRARY_INSTALL_DIR} ARCHIVE DESTINATION ${LIBRARY_INSTALL_DIR})
    ENDIF(NOT WIN32)

    #rewrite of install_name_dir in apple binaries
    IF(APPLE)
      SET_TARGET_PROPERTIES(${CURRENT_LIB} PROPERTIES INSTALL_NAME_DIR ${LIBRARY_INSTALL_DIR})
    ENDIF(APPLE)

	IF(NP_LIB_DEPENDS)
	  ADD_DEPENDENCIES(${CURRENT_LIB} ${NP_LIB_DEPENDS})
	ENDIF(NP_LIB_DEPENDS)
  ENDFOREACH(LIB_TYPE)
  SET(DEPEND_NAME "${NP_LIB_NAME}_DEPEND")
  ADD_CUSTOM_TARGET(${DEPEND_NAME} DEPENDS ${LIB_DEPEND_LIST})
  
ENDFUNCTION(NP_BUILD_LIB)

######################################################################################
# Generalized executable building function
######################################################################################

FUNCTION(NP_BUILD_EXE)
  PARSE_ARGUMENTS(NP_EXE
	"NAME;SOURCES;CXX_FLAGS;LINK_LIBS;LINK_FLAGS;DEPENDS;SHOULD_INSTALL"
	""
	${ARGN}
	)
  
  ADD_EXECUTABLE(${NP_EXE_NAME} ${NP_EXE_SOURCES})
  SET_TARGET_PROPERTIES (${NP_EXE_NAME} PROPERTIES OUTPUT_NAME ${NP_EXE_NAME})

  IF(NP_EXE_CXX_FLAGS)
    SET_COMPILE_FLAGS(${NP_EXE_NAME} ${NP_EXE_CXX_FLAGS})
  ENDIF(NP_EXE_CXX_FLAGS)

  IF(NP_EXE_LINK_FLAGS)
    SET_TARGET_PROPERTIES(${NP_EXE_NAME} PROPERTIES LINK_FLAGS ${NP_EXE_LINK_FLAGS})
  ENDIF(NP_EXE_LINK_FLAGS)
  
  IF(NP_EXE_LINK_LIBS)
	TARGET_LINK_LIBRARIES(${NP_EXE_NAME} ${NP_EXE_LINK_LIBS})
  ENDIF(NP_EXE_LINK_LIBS)

  IF(NOT WIN32 AND SHOULD_INSTALL)
    INSTALL(TARGETS ${NP_EXE_NAME} RUNTIME DESTINATION ${RUNTIME_INSTALL_DIR})
  ENDIF(NOT WIN32 AND SHOULD_INSTALL)

  IF(NP_EXE_DEPENDS)
	ADD_DEPENDENCIES(${NP_EXE_NAME} ${NP_EXE_DEPENDS})
  ENDIF(NP_EXE_DEPENDS)
ENDFUNCTION(NP_BUILD_EXE)

######################################################################################
# Fast Math Option
######################################################################################

MACRO(OPTION_LOG4CXX DEFAULT)
  OPTION(USE_LOG4CXX "Use log4cxx output if library is available" ${DEFAULT})

  IF(USE_LOG4CXX)
	FIND_PACKAGE(Log4Cxx REQUIRED)	
	MESSAGE(STATUS "Turning on log4cxx logging capabilities for ${CMAKE_PROJECT_NAME}")
  ELSE(USE_LOG4CXX)
	MESSAGE(STATUS "NOT Turning on log4cxx logging capabilities for ${CMAKE_PROJECT_NAME}")
  ENDIF(USE_LOG4CXX)
ENDMACRO(OPTION_LOG4CXX)

######################################################################################
# Fast Math Option
######################################################################################

MACRO(OPTION_FAST_MATH DEFAULT)
  OPTION(FAST_MATH "Use -ffast-math for GCC 4.0" ${DEFAULT})

  IF(FAST_MATH)
	SET(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -ffast-math")
	SET(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} -ffast-math")   
	SET(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -ffast-math")   
	MESSAGE(STATUS "Turning on -ffast-math for ${CMAKE_PROJECT_NAME}")
  ELSE(FAST_MATH)
	MESSAGE(STATUS "NOT Turning on -ffast-math for ${CMAKE_PROJECT_NAME}")
  ENDIF(FAST_MATH)
ENDMACRO(OPTION_FAST_MATH)

######################################################################################
# Library Build Type Options
######################################################################################

MACRO(OPTION_LIBRARY_BUILD_STATIC DEFAULT)
  OPTION(BUILD_STATIC "Build static libraries" ${DEFAULT})

  IF(BUILD_STATIC)
	LIST(APPEND NP_LIB_TYPES STATIC)
	MESSAGE(STATUS "Building Static Libraries for ${CMAKE_PROJECT_NAME}")
  ELSE(BUILD_STATIC)
  	MESSAGE(STATUS "NOT Building Static Libraries for ${CMAKE_PROJECT_NAME}")
  ENDIF(BUILD_STATIC)
ENDMACRO(OPTION_LIBRARY_BUILD_STATIC)

MACRO(OPTION_LIBRARY_BUILD_SHARED DEFAULT)
  OPTION(BUILD_SHARED "Build shared libraries" ${DEFAULT})

  IF(BUILD_SHARED)
	LIST(APPEND NP_LIB_TYPES SHARED)
	MESSAGE(STATUS "Building Shared Libraries for ${CMAKE_PROJECT_NAME}")
  ELSE(BUILD_SHARED)
  	MESSAGE(STATUS "NOT Building Shared Libraries for ${CMAKE_PROJECT_NAME}")
  ENDIF(BUILD_SHARED)
ENDMACRO(OPTION_LIBRARY_BUILD_SHARED)

######################################################################################
# RPATH Relink Options
######################################################################################

MACRO(OPTION_BUILD_RPATH DEFAULT)
  OPTION(SET_BUILD_RPATH "Set the build RPATH to local directories, relink to install directories at install time" ${DEFAULT})

  IF(SET_BUILD_RPATH)
  	MESSAGE(STATUS "Setting build RPATH for ${CMAKE_PROJECT_NAME}")
	# use, i.e. don't skip the full RPATH for the build tree
	SET(CMAKE_SKIP_BUILD_RPATH  FALSE)
  
	# when building, don't use the install RPATH already
	# (but later on when installing)
	SET(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE) 
  
	# the RPATH to be used when installing
	SET(CMAKE_INSTALL_RPATH "${LIBRARY_INSTALL_DIR}")
  
	# add the automatically determined parts of the RPATH
	# which point to directories outside the build tree to the install RPATH
	SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
  ELSE(SET_BUILD_RPATH)
    MESSAGE(STATUS "NOT Setting build RPATH for ${CMAKE_PROJECT_NAME}")
  ENDIF(SET_BUILD_RPATH)
ENDMACRO(OPTION_BUILD_RPATH)

######################################################################################
# Turn on GProf based profiling 
######################################################################################

MACRO(OPTION_GPROF DEFAULT)
  OPTION(ENABLE_GPROF "Compile using -g -pg for gprof output" ${DEFAULT})
  IF(ENABLE_GPROF)
	MESSAGE(STATUS "Using gprof output for ${CMAKE_PROJECT_NAME}")
	SET(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -g -pg")
	SET(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -g -pg") 
	SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -g -pg")
	SET(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -g -pg")
  ELSE(ENABLE_GPROF)
	MESSAGE(STATUS "NOT using gprof output for ${CMAKE_PROJECT_NAME}")
  ENDIF(ENABLE_GPROF)
ENDMACRO(OPTION_GPROF)

######################################################################################
# Platform specific optimizations
######################################################################################

MACRO(OPTION_ARCH_OPTS DEFAULT)
  OPTION(ARCH_OPTS "Find and use architecture optimizations" ${DEFAULT})
  IF(ARCH_OPTS)
 	EXECUTE_PROCESS(COMMAND "${NP_MODULE_DIR}/scripts/gcccpuopt.sh" RESULT_VARIABLE CPU_RESULT OUTPUT_VARIABLE CPU_OPT ERROR_VARIABLE CPU_ERR OUTPUT_STRIP_TRAILING_WHITESPACE ERROR_STRIP_TRAILING_WHITESPACE)
	MESSAGE(STATUS "Using Processor optimizations for ${CMAKE_PROJECT_NAME}: ${CPU_OPT}")
	SET(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} ${CPU_OPT}")
	SET(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} ${CPU_OPT}")
  ELSE(ARCH_OPTS)
	MESSAGE(STATUS "NOT Using Processor optimizations for ${CMAKE_PROJECT_NAME}")
  ENDIF(ARCH_OPTS)
ENDMACRO(OPTION_ARCH_OPTS)

######################################################################################
# Create software version code file
######################################################################################

MACRO(OPTION_CREATE_VERSION_FILE DEFAULT OUTPUT_PATH)
  OPTION(CREATE_VERSION_FILE "Creates a version.cc file using the setlocalversion script" ${DEFAULT})
  IF(CREATE_VERSION_FILE)
 	EXECUTE_PROCESS(COMMAND "${NP_MODULE_DIR}/scripts/setlocalversion.sh" OUTPUT_FILE ${OUTPUT_PATH})
	MESSAGE(STATUS "Generating git information for ${CMAKE_PROJECT_NAME}")	
  ELSE(CREATE_VERSION_FILE)
	MESSAGE(STATUS "NOT generating git information for ${CMAKE_PROJECT_NAME}")	
  ENDIF(CREATE_VERSION_FILE)
ENDMACRO(OPTION_CREATE_VERSION_FILE)

######################################################################################
# Make sure we aren't trying to do an in-source build
######################################################################################

#taken from http://www.mail-archive.com/cmake@cmake.org/msg14236.html

MACRO(MACRO_ENSURE_OUT_OF_SOURCE_BUILD)
    STRING(COMPARE EQUAL "${${PROJECT_NAME}_SOURCE_DIR}" "${${PROJECT_NAME}_BINARY_DIR}" insource)
    GET_FILENAME_COMPONENT(PARENTDIR ${${PROJECT_NAME}_SOURCE_DIR} PATH)
    STRING(COMPARE EQUAL "${${PROJECT_NAME}_SOURCE_DIR}" "${PARENTDIR}" insourcesubdir)
    IF(insource OR insourcesubdir)
        MESSAGE(FATAL_ERROR 
		  "${PROJECT_NAME} requires an out of source build (make a build dir and call cmake from that.):\n"
		  "mkdir build_[platform_name]; cd build_[platform_name]; cmake ..;\n"
		  "If you get this error from a sub-directory, make sure there is not a CMakeCache.txt in your project root directory."
		  )
    ENDIF(insource OR insourcesubdir)
ENDMACRO(MACRO_ENSURE_OUT_OF_SOURCE_BUILD)

######################################################################################
# CPack Source Distro Setup
######################################################################################

MACRO(NP_CPACK_INFO)
  PARSE_ARGUMENTS(NP_CPACK
	"NAME;MAJOR_VERSION;MINOR_VERSION;BUILD_VERSION;VENDOR;DESCRIPTION"
	""
	${ARGN}
	)
  
  # CPack version numbers for release tarball name.
  SET(CPACK_PACKAGE_VERSION_MAJOR ${NP_CPACK_MAJOR_VERSION})
  SET(CPACK_PACKAGE_VERSION_MINOR ${NP_CPACK_MINOR_VERSION})
  SET(CPACK_PACKAGE_VERSION_PATCH ${NP_CPACK_BUILD_VERSION})
  
  SET(CPACK_PACKAGE_DESCRIPTION_SUMMARY ${NP_CPACK_DESCRIPTION})
  SET(CPACK_PACKAGE_VENDOR ${NP_CPACK_VENDOR})
  #We'll always have a description file handy as README
  SET(CPACK_PACKAGE_DESCRIPTION_FILE ${CMAKE_CURRENT_SOURCE_DIR}/README.txt)
  SET(CPACK_GENERATOR TGZ)
  SET(NP_CPACK_VERSION ${NP_CPACK_MAJOR_VERSION}.${NP_CPACK_MINOR_VERSION}.${NP_CPACK_BUILD_VERSION})
  SET(NP_CPACK_NAME ${NP_CPACK_NAME})

  NP_CPACK_SOURCE_DISTRO()
ENDMACRO(NP_CPACK_INFO)

MACRO(NP_CPACK_SOURCE_DISTRO)
  set(
	CPACK_SOURCE_PACKAGE_FILE_NAME "${NP_CPACK_NAME}-${NP_CPACK_VERSION}-src"
	CACHE INTERNAL "${NP_CPACK_NAME} Source Distribution"
	)
  set(CPACK_SOURCE_GENERATOR "TGZ;ZIP")
  set(CPACK_SOURCE_IGNORE_FILES
	"~$"
	"^${PROJECT_SOURCE_DIR}/boneyard/"
	"^${PROJECT_SOURCE_DIR}/.git.*"
	"^${PROJECT_SOURCE_DIR}/build.*"
	)
ENDMACRO(NP_CPACK_SOURCE_DISTRO)

######################################################################################
# Initialize Build Function
######################################################################################

MACRO(INITIALIZE_BUILD)

  #Add the find subdirectory, so we can keep our repository nice and tidy
  LIST(APPEND CMAKE_MODULE_PATH ${NP_MODULE_DIR}/find)

  MACRO_ENSURE_OUT_OF_SOURCE_BUILD()

  IF(NOT CMAKE_BUILD_TYPE)
	SET(CMAKE_BUILD_TYPE Release)
	#  SET(CMAKE_BUILD_TYPE RelWithDebInfo)
	#  SET(CMAKE_BUILD_TYPE Debug)
	MESSAGE(STATUS "No build type specified, using default: ${CMAKE_BUILD_TYPE}")
  ENDIF(NOT CMAKE_BUILD_TYPE)

  SET(PROJECT_DIR ${CMAKE_CURRENT_SOURCE_DIR})
  SET(EXECUTABLE_OUTPUT_PATH ${CMAKE_CURRENT_BINARY_DIR}/bin)
  SET(LIBRARY_OUTPUT_PATH ${CMAKE_CURRENT_BINARY_DIR}/lib)

  IF(CMAKE_PREFIX_PATH)
	SET(CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH}:../library/usr_${FIVETEN_BUILD_PLATFORM}")
  ELSE(CMAKE_PREFIX_PATH)
	SET(CMAKE_PREFIX_PATH "${PROJECT_DIR}/../library/usr_${FIVETEN_BUILD_PLATFORM}")
  ENDIF(CMAKE_PREFIX_PATH)

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