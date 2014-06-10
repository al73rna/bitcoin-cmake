
# Save current directory path of this CMakeLists.txt into CONTRIB_SOURCE_DIR 
# and overwrite CMAKE_*_SOURCE_DIR with the path to the actual source.
set(CONTRIB_CURRENT_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR})
string(REGEX REPLACE "/contrib/cmake" "" CMAKE_CURRENT_SOURCE_DIR
       ${CMAKE_CURRENT_SOURCE_DIR})


set(LIB_HEADERS
    addrman.h
    alert.h
    allocators.h
    base58.h
    coins.h
    bloom.h
    chainparams.h
    checkpoints.h
    checkqueue.h
    clientversion.h
    coincontrol.h
    compat.h
    core.h
    crypter.h
    db.h
    hash.h
    init.h
    key.h
    keystore.h
    leveldbwrapper.h
    limitedmap.h
    main.h
    miner.h
    mruset.h
    netbase.h
    net.h
    protocol.h
    rpcclient.h
    rpcprotocol.h
    rpcserver.h
    script.h
    serialize.h
    sync.h
    threadsafety.h
    tinyformat.h
    txdb.h
    txmempool.h
    ui_interface.h
    uint256.h
    util.h
    version.h
    walletdb.h
    wallet.h
    )

set(LIB_SOURCES
    addrman.cpp
    alert.cpp
    allocators.cpp
    bloom.cpp
    chainparams.cpp
    checkpoints.cpp
    coins.cpp
    core.cpp
    crypter.cpp
    db.cpp
    hash.cpp
    init.cpp
    key.cpp
    keystore.cpp
    leveldbwrapper.cpp
    main.cpp
    miner.cpp
    netbase.cpp
    net.cpp
    noui.cpp
    protocol.cpp
    rpcblockchain.cpp
    rpcclient.cpp
    rpcdump.cpp
    rpcmining.cpp
    rpcmisc.cpp
    rpcnet.cpp
    rpcprotocol.cpp
    rpcrawtransaction.cpp
    rpcserver.cpp
    rpcwallet.cpp
    script.cpp
    sync.cpp
    txdb.cpp
    txmempool.cpp
    util.cpp
    version.cpp
    wallet.cpp
    walletdb.cpp
    )

if(GLIBC_BACK_COMPAT)
    list(APPEND ${LIB_SOURCES} compat/glibc_compat.cpp compat/glibcxx_compat.cpp)
endif()

set(DIR_SOURCES)
foreach(file ${LIB_SOURCES})
    set(DIR_SOURCES ${DIR_SOURCES} ${CMAKE_CURRENT_SOURCE_DIR}/${file})
endforeach()

set(DIR_HEADERS)
foreach(file ${LIB_HEADERS})
    set(DIR_HEADERS ${DIR_HEADERS} ${CMAKE_CURRENT_SOURCE_DIR}/${file})
endforeach()

add_subdirectory(${CONTRIB_CURRENT_SOURCE_DIR}/leveldb
                 ${CMAKE_CURRENT_BINARY_DIR}/leveldb)

add_definitions( "-DHAS_BOOST -DHAVE_WORKING_BOOST_SLEEP" )

# Generate bitcoin-config.h substituting config vars for include:
configure_file(${CONTRIB_CURRENT_SOURCE_DIR}/bitcoin-config.h.cmake
               ${CMAKE_CURRENT_BINARY_DIR}/bitcoin-config.h @ONLY)
add_definitions( "-DHAVE_CONFIG_H" )

include_directories(${CMAKE_CURRENT_BINARY_DIR} # for bitcoin-config.h
                    ${BDB_INCLUDE}
                    ${Boost_INCLUDE_DIRS}
                    ${OPENSSL_INCLUDE_DIRS}
                    ${CMAKE_CURRENT_SOURCE_DIR}/leveldb/include
                    ${CMAKE_CURRENT_SOURCE_DIR}/leveldb/helpers
                    ${CMAKE_CURRENT_SOURCE_DIR}/leveldb/helpers/memenv
                    )

add_library(bitcoin ${DIR_HEADERS} ${DIR_SOURCES})
target_link_libraries(bitcoin leveldb
                      ${CMAKE_THREAD_LIBS_INIT}
                      ${BDB_LIBRARY}
                      ${Boost_LIBRARIES}
                      ${OPENSSL_LIBRARIES}
                     )

if(USE_UPNP)
    include_directories(${MINIUPNP_INCLUDE_DIR})
    target_link_libraries(bitcoin ${MINIUPNP_LIBRARY})
endif()

add_executable(bitcoind ${CMAKE_CURRENT_SOURCE_DIR}/bitcoind.cpp)
target_link_libraries(bitcoind bitcoin)

add_executable(bitcoin-cli ${CMAKE_CURRENT_SOURCE_DIR}/bitcoin-cli.cpp)
target_link_libraries(bitcoin-cli bitcoin)

if(BUILD_QT)
    add_subdirectory(${CONTRIB_CURRENT_SOURCE_DIR}/qt
                     ${CMAKE_CURRENT_BINARY_DIR}/qt)
endif()

if(ENABLE_TESTS)
    add_subdirectory(${CONTRIB_CURRENT_SOURCE_DIR}/test
                     ${CMAKE_CURRENT_BINARY_DIR}/test)
endif()

