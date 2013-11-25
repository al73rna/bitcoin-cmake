
set(LIB_HEADERS
    addrman.h
    alert.h
    allocators.h
    base58.h
    bignum.h
    bitcoinrpc.h
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
    script.h
    serialize.h
    sync.h
    threadsafety.h
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
    bitcoinrpc.cpp
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
    rpcdump.cpp
    rpcmining.cpp
    rpcnet.cpp
    rpcrawtransaction.cpp
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

add_subdirectory(leveldb)

add_definitions( "-DHAS_BOOST -DHAVE_WORKING_BOOST_SLEEP" )

# Generate bitcoin-config.h substituting config vars for include:
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/bitcoin-config.h.in
               ${CMAKE_CURRENT_BINARY_DIR}/bitcoin-config.h @ONLY)
add_definitions( "-DHAVE_CONFIG_H" )

include_directories(${CMAKE_CURRENT_BINARY_DIR} # for bitcoin-config.h
	            ${BDB_INCLUDE}
                    ${Boost_INCLUDE_DIRS}
                    ${OPENSSL_INCLUDE_DIRS}
                    "leveldb/include"
                    "leveldb/helpers"
                    )

add_library(bitcoin ${LIB_HEADERS} ${LIB_SOURCES})
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

add_executable(bitcoind bitcoind.cpp)
target_link_libraries(bitcoind bitcoin)

add_executable(bitcoin-cli bitcoin-cli.cpp)
target_link_libraries(bitcoin-cli bitcoin)

if(BUILD_QT)
    add_subdirectory( qt )
endif()

add_subdirectory(test)

