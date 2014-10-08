
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
    chain.h
    chainparams.h
    chainparamsbase.h
    chainparamsseeds.h
    checkpoints.h
    checkqueue.h
    clientversion.h
    coincontrol.h
    compat.h
    compat/sanity.h
    core.h
    core_io.h
    crypter.h
    crypto/common.h
    crypto/ripemd160.h
    crypto/sha1.h
    crypto/sha2.h
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
    pow.h
    protocol.h
    rpcclient.h
    rpcprotocol.h
    rpcserver.h
    script/script.h
    script/compressor.h
    script/interpreter.h
    script/sigcache.h
    script/sign.h
    script/standard.h
    serialize.h
    sync.h
    threadsafety.h
    timedata.h
    tinyformat.h
    txdb.h
    txmempool.h
    ui_interface.h
    uint256.h
    univalue/univalue.h
    univalue/univalue_escapes.h
    util.h
    utilmoneystr.h
    utilstrencodings.h
    utiltime.h
    version.h
    walletdb.h
    wallet.h
    )

set(LIB_SOURCES
    addrman.cpp
    alert.cpp
    allocators.cpp
    base58.cpp
    bloom.cpp
    chain.cpp
    chainparamsbase.cpp
    chainparams.cpp
    checkpoints.cpp
    coins.cpp
    compat/glibc_sanity.cpp
    compat/glibcxx_sanity.cpp
    core.cpp
    core_read.cpp
    core_write.cpp
    crypter.cpp
    crypto/ripemd160.cpp
    crypto/sha1.cpp
    crypto/sha2.cpp
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
    pow.cpp
    protocol.cpp
    random.cpp
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
    script/script.cpp
    script/compressor.cpp
    script/interpreter.cpp
    script/sigcache.cpp
    script/sign.cpp
    script/standard.cpp
    sync.cpp
    timedata.cpp
    txdb.cpp
    txmempool.cpp
    uint256.cpp
    univalue/gen.cpp
    univalue/univalue.cpp
    univalue/univalue_read.cpp
    univalue/univalue_write.cpp
    util.cpp
    utilmoneystr.cpp
    utilstrencodings.cpp
    utiltime.cpp
    version.cpp
    wallet.cpp
    walletdb.cpp
    wallet_ismine.cpp
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

include_directories(${CMAKE_CURRENT_BINARY_DIR}/config
                    ${BDB_INCLUDE}
                    ${Boost_INCLUDE_DIRS}
                    ${OPENSSL_INCLUDE_DIRS}
                    ${CMAKE_CURRENT_SOURCE_DIR}
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

add_executable(bitcoin-tx ${CMAKE_CURRENT_SOURCE_DIR}/bitcoin-tx.cpp)
target_link_libraries(bitcoin-tx bitcoin)

if(BUILD_QT)
    add_subdirectory(${CONTRIB_CURRENT_SOURCE_DIR}/qt
                     ${CMAKE_CURRENT_BINARY_DIR}/qt)
endif()

if(ENABLE_TESTS)
    add_subdirectory(${CONTRIB_CURRENT_SOURCE_DIR}/test
                     ${CMAKE_CURRENT_BINARY_DIR}/test)
endif()

install(TARGETS bitcoind DESTINATION bin)

