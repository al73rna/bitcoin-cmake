
# Save current directory path of this CMakeLists.txt into CONTRIB_SOURCE_DIR 
# and overwrite CMAKE_*_SOURCE_DIR with the path to the actual source. This 
# may be taken out if CMakeLists.txt files are moved out of contrib and into 
# the source directories.
set(CONTRIB_SOURCE_DIR ${CMAKE_SOURCE_DIR})
string(REGEX REPLACE "/contrib/cmake" "" CMAKE_SOURCE_DIR ${CMAKE_SOURCE_DIR})
set(CONTRIB_CURRENT_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR})
string(REGEX REPLACE "/contrib/cmake" "" CMAKE_CURRENT_SOURCE_DIR
       ${CMAKE_CURRENT_SOURCE_DIR})

cmake_minimum_required(VERSION 2.8)
project(bitcoin)

set(MAJOR_VERSION 0)
set(MINOR_VERSION 9)
set(RELEASE_VERSION 99)
set(BUILD_VERSION 0)

set(COPYRIGHT_YEAR "2013")


#-----------------------------------------------------------------------------
# Third party libraries

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CONTRIB_SOURCE_DIR}/modules)
INCLUDE(UsePkgConfig)

find_package(Threads REQUIRED) # alert.cpp requires pthreads directly? lclclclclclclclclclclclclclclcl
find_package(BDB REQUIRED)
find_package(OpenSSL REQUIRED)
find_package(Boost 1.45.0 COMPONENTS system filesystem thread program_options REQUIRED)
set(Boost_USE_STATIC_LIBS OFF) 
set(Boost_USE_MULTITHREADED ON)  
set(Boost_USE_STATIC_RUNTIME OFF)

# bitcoin-qt dependencies (4.4.3 arbitrarily set via docs):
find_package(Qt4 4.4.3 COMPONENTS QtCore QtGui QtNetwork QtDbus)
find_package(Protobuf)
find_package(QRencode)

if(QT_FOUND AND PROTOBUF_FOUND)
    set(HAVE_BITCOINQT_DEPS TRUE)
else()
    set(HAVE_BITCOINQT_DEPS FALSE)
endif()

find_package(Miniupnpc)

#-----------------------------------------------------------------------------
# Options for building

option(BUILD_VERBOSE       "Verbose build output." ON)
option(ENABLE_TESTS        "Compile and enable unit tests." FALSE)
option(ENABLE_WALLET       "Enable wallet feature,)" ON)
option(GLIBC_BACK_COMPAT   "Enable backwards compatibility with glibc and libstdc++" OFF)
option(BUILD_QT            "Enable bitcoin-qt GUI" ${HAVE_BITCOINQT_DEPS})
option(USE_UPNP            "Whether UPnP support should be available or not." ${MINIUPNP_FOUND})
option(USE_UPNP_DEFAULT    "UPnP is enabled on startup" ${MINIUPNP_FOUND})

if(BUILD_VERBOSE)
  set(CMAKE_VERBOSE_MAKEFILE true)
endif()



set(CLIENT_VERSION_IS_RELEASE OFF CACHE BOOL "Set ON to consider this build to be of release quality.  This disables warning messages that say this build is still in development.")
if(CLIENT_VERSION_IS_RELEASE)
    # I don't want to modify source files to make this cleaner, so I'm
    # explicitly defining to zero or one.
    # See 'src/bitcoin-config.h.in' for usage.
    set(CLIENT_VERSION_IS_RELEASE_SETTING 1)
else()
    set(CLIENT_VERSION_IS_RELEASE_SETTING 0)
endif()






set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# Remove -DNDEBUG from release builds because src/main.cpp:30
# requires assertions to always be enabled.
string(REGEX REPLACE "-DNDEBUG" "" CMAKE_CXX_FLAGS_MINSIZEREL ${CMAKE_CXX_FLAGS_MINSIZEREL})
string(REGEX REPLACE "-DNDEBUG" "" CMAKE_CXX_FLAGS_RELEASE ${CMAKE_CXX_FLAGS_RELEASE})
string(REGEX REPLACE "-DNDEBUG" "" CMAKE_CXX_FLAGS_RELWITHDEBINFO ${CMAKE_CXX_FLAGS_RELWITHDEBINFO})
string(REGEX REPLACE "-DNDEBUG" "" CMAKE_C_FLAGS_MINSIZEREL ${CMAKE_C_FLAGS_MINSIZEREL})
string(REGEX REPLACE "-DNDEBUG" "" CMAKE_C_FLAGS_RELEASE ${CMAKE_C_FLAGS_RELEASE})
string(REGEX REPLACE "-DNDEBUG" "" CMAKE_C_FLAGS_RELWITHDEBINFO ${CMAKE_C_FLAGS_RELWITHDEBINFO})




#-----------------------------------------------------------------------------
# Source Definitions

set(CLIENT_VERSION_MAJOR ${MAJOR_VERSION})
set(CLIENT_VERSION_MINOR ${MINOR_VERSION})
set(CLIENT_VERSION_RELEASE ${RELEASE_VERSION})
set(CLIENT_VERSION_REVISION ${RELEASE_VERSION})
set(CLIENT_VERSION_BUILD ${BUILD_VERSION})

set(PACKAGE bitcoin)
set(VERSION ${MAJOR_VERSION}.${MINOR_VERSION}.${RELEASE_VERSION}.${BUILD_VERSION})
set(host ${CMAKE_SYSTEM} ${CMAKE_SYSTEM_PROCESSOR})
set(COPYRIGHT "Copyright (c) 2009-${COPYRIGHT_YEAR} Bitcoin Developers.  All Rights Reserved.")
set(prefix ${CMAKE_INSTALL_PREFIX})

# This is probably a hack to get PRId64 defines from <inttypes.h> which 
# doesn't seem to define them without manual intervention.
add_definitions( "-D__STDC_FORMAT_MACROS" )


if(BUILD_QT AND NOT HAVE_BITCOINQT_DEPS)
    message(FATAL_ERROR "BUILD_QT was requested but there are unmet dependencies:")
    if(NOT QT_FOUND)
        message(FATAL_ERROR " * Qt libraries unsatisfied (QtCore QtGui QtNetwork).")
    endif()
    if(NOT PROTOBUF_FOUND)
        message(FATAL_ERROR " * Protobuf library not found.")
    endif()
endif()

if(BUILD_QT AND NOT ENABLE_WALLET)
    message(STATUS "BUILD_QT requires ENABLE_WALLET. Enabling wallet implicitly.")
    set(ENABLE_WALLET ON)
endif()

if(USE_UPNP AND NOT MINIUPNP_FOUND)
    message(FATAL_ERROR "UPNP Requested but miniupnpc library not found.")
endif()
if(USE_UPNP_DEFAULT AND NOT USE_UPNP)
    message(STATUS "Implicitly disabling USE_UPNP_DEFAULT due to USE_UPNP not being enabled.")
    set(USE_UPNP_DEFAULT OFF)
endif()
if(USE_UPNP_DEFAULT)
    set(UPNP_SETTING "1") # turn on UPNP by default on bitcoin startup
else()
    set(UPNP_SETTING "0")
endif()

# Check if struct sockaddr_in6 contains sin6
include(CheckStructHasMember)
CHECK_STRUCT_HAS_MEMBER("struct sockaddr_in6" sin6_addr netinet/in.h HAVE_IPV6)

option(ENABLE_IPV6 "Enable use of IPv6. (default is yes if supported)" ${HAVE_IPV6})
if(ENABLE_IPV6 AND NOT HAVE_IPV6)
    message(FATAL_ERROR "USE_IPV6 requested but unable to find development support.")
endif()
if(ENABLE_IPV6)
    set(USE_IPV6 1)
else()
    set(USE_IPV6 0)
endif()

if(BUILD_QT AND QRENCODE_FOUND)
    set(QRENCODE_DEPS_FOUND TRUE)
else()
    set(QRENCODE_DEPS_FOUND FALSE)
endif()
option(USE_QRCODE "Enable QR code support (default is yes if qt is enabled and libqrencode is found)" ${QRENCODE_DEPS_FOUND})
if(USE_QRCODE AND NOT QRENCODE_DEPS_FOUND)
    message(FATAL_ERROR "USE_QRCODE requested but unable to find qt or libqrencode dependencies.")
endif()

option(USE_DBUS "Enable DBus support (default is yes if qt is enabled and QtDbus is found)" ${QT_QTDBUS_FOUND})
if(USE_DBUS)
    if(NOT BUILD_QT)
        message(FATAL_ERROR "USE_DBUS requires BUILD_QT to be set.")
    endif()
    if(NOT QT_QTDBUS_FOUND)
        message(FATAL_ERROR "USE_DBUS requested but QtDbus not found.")
    endif()
endif()

# missing AX_CHECK_LINK_FLAG() from autoconf.. so workaround:
include(CheckCCompilerFlag)

if(MINGW)
    # Allow windows builds to handle addresses larger than 2GB.
    set(CMAKE_REQUIRED_FLAGS "-Wl,--large-address-aware")
    CHECK_C_COMPILER_FLAG("" LINK_LARGE_ADDRESS_AWARE)
    if(LINK_LARGE_ADDRESS_AWARE)
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,--large-address-aware")
    endif()
endif()

if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
    # This flag screws up non-darwin gcc even when the check fails. special-case it.
    set(CMAKE_REQUIRED_FLAGS "-Wl,-dead_strip")
    CHECK_C_COMPILER_FLAG("" LINK_DEAD_STRIP)
    if(LINK_DEAD_STRIP)
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,-dead_strip")
    endif()
endif()

if(UNIX)
    option(ENABLE_HARDENING "Attempt to harden the resulting executables (default is yes)" ON)
    set(HARDENED_CXXFLAGS "-Wstack-protector -fPIE" CACHE STRING "")
    set(HARDENED_CPPFLAGS "-U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=2" CACHE STRING "")
    set(HARDENED_LDFLAGS "-Wl,-z,relro" CACHE STRING "")
    set(HARDENED_LDFLAGS "${HARDENED_LDFLAGS} -Wl,-z,now" CACHE STRING "")

    set(CMAKE_REQUIRED_FLAGS "-Wl,--dynamicbase")
    CHECK_C_COMPILER_FLAG("" LINK_DYNAMIC_BASE)
    if(LINK_DYNAMIC_BASE)
        set(HARDENED_LDFLAGS "${HARDENED_LDFLAGS} -Wl,--dynamicbase" CACHE STRING "")
    endif()

    set(CMAKE_REQUIRED_FLAGS "-Wl,--nxcompat")
    CHECK_C_COMPILER_FLAG("" LINK_NX_COMPAT)
    if(LINK_NX_COMPAT)
        set(HARDENED_LDFLAGS "${HARDENED_LDFLAGS} -Wl,--nxcompat" CACHE STRING "")
    endif()

    if(NOT MINGW)
        # -fstack-protector-all can produce broken binaries with mingw
	set(HARDENED_CXXFLAGS "${HARDENED_CXXFLAGS} -fno-stack-protector" CACHE STRING "")
	set(HARDENED_CXXFLAGS "${HARDENED_CXXFLAGS} -fstack-protector-all" CACHE STRING "")
        #  -pie will link successfully with MinGW, but it's unsupported 
	#  and leads to undeterministic binaries
	set(HARDENED_LDFLAGS "${HARDENED_LDFLAGS} -pie" CACHE STRING "")
    endif()
    MARK_AS_ADVANCED(HARDENED_CXXFLAGS HARDENED_CPPFLAGS HARDENED_LDFLAGS)

    if(ENABLE_HARDENING)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${HARDENED_CXXFLAGS} ${HARDENED_CPPFLAGS}")
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${HARDENED_LDFLAGS}")
    endif()
endif()


#-----------------------------------------------------------------------------
# Build Unit tests

if(ENABLE_TESTS)
    enable_testing()
    find_package(Boost 1.45.0 COMPONENTS unit_test_framework)
    message(STATUS "Tests temporarily disabled to avoid conversion of .json data files.")
    SET(ENABLE_TESTS FALSE)
endif()


#-----------------------------------------------------------------------------
# Build source

add_subdirectory(${CONTRIB_CURRENT_SOURCE_DIR}/src
                 ${CMAKE_CURRENT_BINARY_DIR}/src)


#-----------------------------------------------------------------------------
# Build Documentation

find_package(Doxygen)
if(DOXYGEN_FOUND)
    configure_file(${CONTRIB_CURRENT_SOURCE_DIR}/doc/Doxyfile.in.cmake
	           ${CMAKE_CURRENT_BINARY_DIR}/doc/Doxyfile @ONLY)
    add_custom_target(doc ${DOXYGEN_EXECUTABLE}
                      ${CMAKE_CURRENT_BINARY_DIR}/doc/Doxyfile
		      WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
		      COMMENT "Bitcoin API documentation via Doxygen" VERBATIM)
endif()


#-----------------------------------------------------------------------------
# TODO: add rest of options for things in configure.ac
#
#AC_ARG_WITH([comparison-tool],
#    AS_HELP_STRING([--with-comparison-tool],[path to java comparison tool (requires --enable-tests)]),
#    [use_comparison_tool=$withval],
#    [use_comparison_tool=no])
#
#AC_ARG_ENABLE([comparison-tool-reorg-tests], #    AS_HELP_STRING([--enable-comparison-tool-reorg-tests],[enable expensive reorg tests in the comparison tool (default no)]),
#    [use_comparison_tool_reorg_tests=$enableval],
#    [use_comparison_tool_reorg_tests=no])
#
#AC_ARG_ENABLE([ccache],
#  [AS_HELP_STRING([--enable-ccache],
#  [enable building with ccache (default is yes if ccache is found)])],
#  [use_ccache=$enableval],
#  [use_ccache=auto])

#AC_ARG_ENABLE([lcov],
#  [AS_HELP_STRING([--enable-lcov],
#  [enable lcov testing (default is no)])],
#  [use_lcov=yes],
#  [use_lcov=no])

#dnl these are only used when qt is enabled
#if test x$use_qt = xyes; then
#
#  if test x$use_tests$have_qt_test = xyesyes; then
#    BUILD_TEST_QT="test"
#  fi
#fi

# TODO: FDELT_TYPE propagated to bitcoin-config.h.cmake:
#
#if test x$use_glibc_compat != xno; then
#
#  #__fdelt_chk's params and return type have changed from long unsigned int to long int.
#  # See which one is present here.
#  AC_MSG_CHECKING(__fdelt_chk type)
#  AC_TRY_COMPILE([#define __USE_FORTIFY_LEVEL 2
#                  #include <sys/select.h>
#     extern "C" long unsigned int __fdelt_warn(long unsigned int);],[],
#    [ fdelt_type="long unsigned int"],
#    [ fdelt_type="long int"])
#  AC_MSG_RESULT($fdelt_type)
#  AC_DEFINE_UNQUOTED(FDELT_TYPE, $fdelt_type,[parameter and return value type for __fdelt_chk])
#
#fi
