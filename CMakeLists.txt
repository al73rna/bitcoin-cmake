cmake_minimum_required(VERSION 2.8) # Needed for file(COPY ...)

project(bitcoin)

enable_testing()

set(MAJOR_VERSION 0)
set(MINOR_VERSION 9)
set(RELEASE_VERSION 99)
set(BUILD_VERSION 0)

# Repeat for bitcoin-config.h
set(CLIENT_VERSION_MAJOR ${MAJOR_VERSION})
set(CLIENT_VERSION_MINOR ${MINOR_VERSION})
set(CLIENT_VERSION_RELEASE ${RELEASE_VERSION})
set(CLIENT_VERSION_REVISION ${RELEASE_VERSION}) # src/version.h expects this.
set(CLIENT_VERSION_BUILD ${BUILD_VERSION})

set(CLIENT_VERSION_IS_RELEASE OFF CACHE BOOL "Set ON to consider this build to be of release quality.  This disables warning messages that say this build is still in development.")
if(CLIENT_VERSION_IS_RELEASE)
    # I don't want to modify source files to make this cleaner, so I'm
    # explicitly defining to zero or one.
    # See 'src/bitcoin-config.h.in' for usage.
    set(CLIENT_VERSION_IS_RELEASE_SETTING 1)
else()
    set(CLIENT_VERSION_IS_RELEASE_SETTING 0)
endif()

set(PACKAGE bitcoin)
set(VERSION ${MAJOR_VERSION}.${MINOR_VERSION}.${RELEASE_VERSION}.${BUILD_VERSION})
set(host ${CMAKE_SYSTEM} ${CMAKE_SYSTEM_PROCESSOR})
set(COPYRIGHT_YEAR "2013")
set(COPYRIGHT "Copyright (c) 2009-${COPYRIGHT_YEAR} Bitcoin Developers.  All Rights Reserved.")
set(prefix ${CMAKE_INSTALL_PREFIX})

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/")
INCLUDE(UsePkgConfig)

# This is probably a hack to get PRId64 defines from <inttypes.h> which 
# doesn't seem to define them without manual intervention.
add_definitions( "-D__STDC_FORMAT_MACROS" )

# alert.cpp requires pthreads directly?
find_package(Threads REQUIRED)
find_package(BDB REQUIRED)

find_package(Boost 1.45.0 COMPONENTS system filesystem thread program_options
	                             unit_test_framework)
if(NOT Boost_FOUND)
    message(FATAL_ERROR "Could not locate Boost.")
endif()
set(Boost_USE_STATIC_LIBS OFF) 
set(Boost_USE_MULTITHREADED ON)  
set(Boost_USE_STATIC_RUNTIME OFF)

find_package(OpenSSL)
if(NOT OPENSSL_FOUND)
    message(FATAL_ERROR "Could not locate OpenSSL.")
endif()

# bitcoin-qt dependencies (4.4.3 arbitrarily set via docs):
find_package(Qt4 4.4.3 COMPONENTS QtCore QtGui QtNetwork)
find_package(Protobuf)

if(QT_FOUND AND PROTOBUF_FOUND)
    set(HAVE_BITCOINQT_DEPS TRUE)
else()
    set(HAVE_BITCOINQT_DEPS FALSE)
endif()

option(BUILD_QT "Enable bitcoin-qt GUI (default is yes if deps are satisfied)" ${HAVE_BITCOINQT_DEPS})
if(BUILD_QT AND NOT HAVE_BITCOINQT_DEPS)
    message(FATAL_ERROR "BUILD_QT was requested but there are unmet dependencies:")
    if(NOT QT_FOUND)
        message(FATAL_ERROR " * Qt libraries unsatisfied (QtCore QtGui QtNetwork).")
    endif()
    if(NOT PROTOBUF_FOUND)
        message(FATAL_ERROR " * Protobuf library not found.")
    endif()
endif()

find_package(Miniupnpc)
option(USE_UPNP "Whether UPnP support should be available or not." ${MINIUPNP_FOUND})
option(USE_UPNP_DEFAULT "Whether UPnP is enabled on startup (default is yes if libminiupnpc is found)" ${MINIUPNP_FOUND})
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

find_package(QRencode)
if(BUILD_QT AND QRENCODE_FOUND)
    set(QRENCODE_DEPS_FOUND TRUE)
else()
    set(QRENCODE_DEPS_FOUND FALSE)
endif()
option(USE_QRCODE "Enable QR code support (default is yes if qt is enabled and libqrencode is found)" ${QRENCODE_DEPS_FOUND})
if(USE_QRCODE AND NOT QRENCODE_DEPS_FOUND)
    message(FATAL_ERROR "USE_QRCODE requested but unable to find qt or libqrencode dependencies.")
endif()


#AC_ARG_WITH([qrencode],
#  [AS_HELP_STRING([--with-qrencode],
#  [enable QR code support (default is yes if qt is enabled and libqrencode is found)])],
#  [use_qr=$withval],
#  [use_qr=auto])
#PKG_CHECK_MODULES([QR], [libqrencode], [have_qrencode=yes],	[have_qrencode=no])

# 
# TODO: add cache options for things in configure.ac
#

#
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
#
#AC_ARG_WITH([qtdbus],
#  [AS_HELP_STRING([--with-qtdbus],
#  [enable DBus support (default is yes if qt is enabled and QtDBus is found)])],
#  [use_dbus=$withval],
#  [use_dbus=auto])
#
#AC_ARG_ENABLE([hardening],
#  [AS_HELP_STRING([--enable-hardening],
#  [attempt to harden the resulting executables (default is yes)])],
#  [use_hardening=$enableval],
#  [use_hardening=yes])

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

########################3

# large-address-aware
#  LDFLAGS += -Wl,--large-address-aware

# hardening:
#  HARDENED_CXXFLAGS += -Wstack-protector -fPIE
#  HARDENED_CPPFLAGS += -D_FORTIFY_SOURCE=2
#  HARDENED_LDFLAGS += -Wl,--dynamicbase -Wl,--nxcompat 
#  LDFLAGS += -Wl,-z,relro -Wl,-z,now
# if not windows:
#  HARDENED_CXXFLAGS += -fno-stack-protector -fstack-protector-all
#  -pie will link successfully with MinGW, but it's unsupported and leads to undeterministic binaries
#  HARDENED_LDFAGS += -pie

# TODO:
# this flag screws up non-darwin gcc even when the check fails. special-case it.
#if test x$TARGET_OS = xdarwin; then
#  AX_CHECK_LINK_FLAG([[-Wl,-dead_strip]], [LDFLAGS="$LDFLAGS -Wl,-dead_strip"])
#fi

#dnl these are only used when qt is enabled
#if test x$use_qt = xyes; then
#
#  dnl enable dbus support
#  AC_MSG_CHECKING([if dbus should be enabled])
#  if test x$use_dbus != xno; then
#    use_dbus=yes
#    AC_DEFINE([USE_DBUS],[1],[Define if dbus support should be compiled in])
#  else
#    use_dbus=no
#  fi
#  AC_MSG_RESULT($use_dbus)
#
#  dnl enable qr support
#  AC_MSG_CHECKING([if qr should be enabled])
#  if test x$have_qrencode = xno; then
#    if test x$use_qr == xyes; then
#     AC_MSG_ERROR("QR support requested but cannot be built. use --without-qrencode")
#    fi
#    AC_MSG_RESULT(no)
#  else
#    if test x$use_qr != xno; then
#      AC_MSG_RESULT(yes)
#      AC_DEFINE([USE_QRCODE],[1],[Define if QR support should be compiled in])
#      use_qr=yes
#    else
#      AC_MSG_RESULT(no)
#    fi
#  fi
#
#  if test x$use_tests$have_qt_test = xyesyes; then
#    BUILD_TEST_QT="test"
#  fi
#fi

option(ENABLE_TESTS "Compile and enable unit tests." TRUE)

add_subdirectory(src)

find_package(Doxygen)
if(DOXYGEN_FOUND)
    configure_file(${CMAKE_CURRENT_SOURCE_DIR}/doc/Doxyfile.in 
	           ${CMAKE_CURRENT_BINARY_DIR}/doc/Doxyfile @ONLY)
    add_custom_target(doc ${DOXYGEN_EXECUTABLE}
                      ${CMAKE_CURRENT_BINARY_DIR}/doc/Doxyfile
		      WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
		      COMMENT "Bitcoin API documentation via Doxygen" VERBATIM)
endif()


