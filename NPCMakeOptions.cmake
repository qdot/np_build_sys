######################################################################################
# Fast Math Option
######################################################################################

MACRO(OPTION_LOG4CXX DEFAULT LIBRARY_LIST)
  OPTION(USE_LOG4CXX "Use log4cxx output if library is available" ${DEFAULT})

  IF(USE_LOG4CXX)
	FIND_PACKAGE(Log4Cxx REQUIRED)	
	INCLUDE_DIRECTORIES(${LOG4CXX_INCLUDE_DIRS})
	LIST(APPEND ${LIBRARY_LIST} ${LOG4CXX_LIBRARIES})
	
	SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DENABLE_LOGGING")
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
	SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -ffast-math")
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
	SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g -pg")
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
	SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CPU_OPT}")
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
# Look for accelerate, if found, add proper includes
######################################################################################

MACRO(OPTION_ACCELERATE_FRAMEWORK DEFAULT)
  IF(APPLE)
	OPTION(ACCELERATE_FRAMEWORK "Use Accelerate Framework for Math (Adds -D_ACCELERATE_ for compiling and Accelerate Framework linking)" ${DEFAULT})
	IF(ACCELERATE_FRAMEWORK)
	  FIND_LIBRARY(ACCELERATE_LIBRARY Accelerate REQUIRED)
	  SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D_ACCELERATE_")
	  MESSAGE(STATUS "Turning on Accelerate Framework for ${CMAKE_PROJECT_NAME}")
	ELSE(ACCELERATE_FRAMEWORK)
	  MESSAGE(STATUS "NOT turning on Accelerate Framework for ${CMAKE_PROJECT_NAME}")
	ENDIF(ACCELERATE_FRAMEWORK)
  ELSE(APPLE)
	MESSAGE(STATUS "Accelerate Framework NOT AVAILABLE - Not compiling for OS X")
  ENDIF(APPLE)
ENDMACRO(OPTION_ACCELERATE_FRAMEWORK)

######################################################################################
# Force 32-bit, regardless of the platform we're on
######################################################################################

MACRO(OPTION_FORCE_32_BIT DEFAULT)
  IF(CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64")
	IF(CMAKE_COMPILER_IS_GNUCXX)
	  OPTION(FORCE_32_BIT "Force compiler to use -m32 when compiling" ${DEFAULT})
	  IF(FORCE_32_BIT)
		MESSAGE(STATUS "Forcing 32-bit on 64-bit platform (using -m32)")
		SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -m32")
	  ELSE(FORCE_32_BIT)
		MESSAGE(STATUS "Not forcing 32-bit on 64-bit platform")
	  ENDIF(FORCE_32_BIT)
	ELSE(CMAKE_COMPILER_IS_GNUCXX)
	  MESSAGE(STATUS "Force 32 bit NOT AVAILABLE - Not using gnu compiler")
	ENDIF(CMAKE_COMPILER_IS_GNUCXX)
  ELSE({CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64")
	MESSAGE(STATUS "Force 32 bit NOT AVAILABLE - Already on a 32 bit platform")
  ENDIF(CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64")
ENDMACRO(OPTION_FORCE_32_BIT)
