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
	"NAME;SOURCES;CXX_FLAGS;LINK_LIBS;LINK_FLAGS;DEPENDS;SHOULD_INSTALL;VERSION"
	""
	${ARGN}
	)

  FOREACH(LIB_TYPE ${NP_LIB_TYPES})
    SET(CURRENT_LIB ${NP_LIB_NAME}_${LIB_TYPE})
    ADD_LIBRARY (${CURRENT_LIB} ${LIB_TYPE} ${NP_LIB_SOURCES})
	LIST(APPEND LIB_DEPEND_LIST ${CURRENT_LIB})
	STRING(REGEX MATCH "[0-9]+" NP_LIB_SO_VERSION ${NP_LIB_VERSION})

    SET_TARGET_PROPERTIES (${CURRENT_LIB} PROPERTIES OUTPUT_NAME           ${NP_LIB_NAME})
    SET_TARGET_PROPERTIES (${CURRENT_LIB} PROPERTIES CLEAN_DIRECT_OUTPUT   1)
	SET_TARGET_PROPERTIES (${CURRENT_LIB} PROPERTIES SOVERSION             ${NP_LIB_SO_VERSION})
	SET_TARGET_PROPERTIES (${CURRENT_LIB} PROPERTIES VERSION               ${NP_LIB_VERSION})

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
	IF(NP_LIB_SHOULD_INSTALL)
      INSTALL(TARGETS ${CURRENT_LIB} LIBRARY DESTINATION ${LIBRARY_INSTALL_DIR} ARCHIVE DESTINATION ${LIBRARY_INSTALL_DIR})
    ENDIF(NP_LIB_SHOULD_INSTALL)

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

  IF(NP_EXE_SHOULD_INSTALL)
    INSTALL(TARGETS ${NP_EXE_NAME} RUNTIME DESTINATION ${RUNTIME_INSTALL_DIR})
  ENDIF(NP_EXE_SHOULD_INSTALL)

  IF(NP_EXE_DEPENDS)
	ADD_DEPENDENCIES(${NP_EXE_NAME} ${NP_EXE_DEPENDS})
  ENDIF(NP_EXE_DEPENDS)
ENDFUNCTION(NP_BUILD_EXE)

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

