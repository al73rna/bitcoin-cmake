
#define CLIENT_VERSION_MAJOR @CLIENT_VERSION_MAJOR@
#define CLIENT_VERSION_MINOR @CLIENT_VERSION_MINOR@
#define CLIENT_VERSION_RELEASE @CLIENT_VERSION_RELEASE@
#define CLIENT_VERSION_REVISION @CLIENT_VERSION_RELEASE@
#define CLIENT_VERSION_BUILD @CLIENT_VERSION_BUILD@
#define COPYRIGHT_YEAR @COPYRIGHT_YEAR@

#define CLIENT_VERSION_IS_RELEASE @CLIENT_VERSION_IS_RELEASE_SETTING@

#cmakedefine ENABLE_WALLET

#cmakedefine MSG_NOSIGNAL
#cmakedefine HAVE_MSG_NOSIGNAL

// USE_UPNP is defined whenever UPnP should be compiled 
// and linked with. The value assigned is 1 if UPnP should 
// be enabled during bitcoin startup and 0 if not.
#cmakedefine USE_UPNP @UPNP_SETTING@

#define USE_IPV6 @USE_IPV6@

#cmakedefine USE_QRCODE 

#cmakedefine USE_DBUS
