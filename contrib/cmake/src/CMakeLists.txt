
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
    compressor.h
    core_io.h
    primitives/block.h
    primitives/transaction.h
    crypter.h
    crypto/common.h
    crypto/hmac_sha256.h
    crypto/hmac_sha512.h
    crypto/rfc6979_hmac_sha256.h
    crypto/ripemd160.h
    crypto/sha1.h
    crypto/sha256.h
    crypto/sha512.h
    db.h
    eccryptoverify.h
    ecwrapper.h
    hash.h
    init.h
    key.h
    keystore.h
    leveldbwrapper.h
    limitedmap.h
    main.h
    merkleblock.h
    miner.h
    mruset.h
    netbase.h
    net.h
    pow.h
    protocol.h
    pubkey.h
    rpcclient.h
    rpcprotocol.h
    rpcserver.h
    script/bitcoinconsensus.h
    script/interpreter.h
    script/script.h
    script/script_error.h
    script/sigcache.h
    script/sign.h
    script/standard.h
    secp256k1/include/secp256k1.h
    serialize.h
    streams.h
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
    amount.cpp
    alert.cpp
    allocators.cpp
    base58.cpp
    bloom.cpp
    chain.cpp
    chainparamsbase.cpp
    chainparams.cpp
    checkpoints.cpp
    clientversion.cpp
    coins.cpp
    compat/glibc_sanity.cpp
    compat/glibcxx_sanity.cpp
    compat/strnlen.cpp
    compressor.cpp
    core_read.cpp
    core_write.cpp
    primitives/block.cpp
    primitives/transaction.cpp
    crypter.cpp
    crypto/hmac_sha256.cpp
    crypto/hmac_sha512.cpp
    crypto/rfc6979_hmac_sha256.cpp
    crypto/ripemd160.cpp
    crypto/sha1.cpp
    crypto/sha256.cpp
    crypto/sha512.cpp
    db.cpp
    eccryptoverify.cpp
    ecwrapper.cpp
    hash.cpp
    init.cpp
    key.cpp
    keystore.cpp
    leveldbwrapper.cpp
    main.cpp
    merkleblock.cpp
    miner.cpp
    netbase.cpp
    net.cpp
    noui.cpp
    pow.cpp
    protocol.cpp
    pubkey.cpp
    random.cpp
    rest.cpp
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
    script/bitcoinconsensus.cpp
    script/interpreter.cpp
    script/script.cpp
    script/script_error.cpp
    script/sigcache.cpp
    script/sign.cpp
    script/standard.cpp
    secp256k1/src/secp256k1.c
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
    wallet.cpp
    walletdb.cpp
    wallet_ismine.cpp
    )

if(GLIBC_BACK_COMPAT)
    #list(APPEND ${LIB_SOURCES} compat/glibc_compat.cpp compat/glibcxx_compat.cpp)
    set(LIB_SOURCES ${LIB_SOURCES} compat/glibc_compat.cpp compat/glibcxx_compat.cpp)
endif()

if(USE_ASM)
    # This should never be reached. It's disabled in ../CMakeLists.txt
    set(can_use_assembler FALSE)
    set(LIB_SOURCES ${LIB_SOURCES} secp256k1/src/field_5x52_asm.asm)
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
                    ${OPENSSL_INCLUDE_DIR}
                    ${CMAKE_CURRENT_SOURCE_DIR}
                    ${CMAKE_CURRENT_SOURCE_DIR}/leveldb/include
                    ${CMAKE_CURRENT_SOURCE_DIR}/leveldb/helpers
                    ${CMAKE_CURRENT_SOURCE_DIR}/leveldb/helpers/memenv
                    ${CMAKE_CURRENT_SOURCE_DIR}/secp256k1
                    ${CMAKE_CURRENT_SOURCE_DIR}/secp256k1/include
                    )

# TODO: autotools splits this into:
#      libbitcoin
#      libbitcoinconsensus
#      libsecp256k1
add_library(bitcoin ${DIR_HEADERS} ${DIR_SOURCES})
target_link_libraries(bitcoin leveldb
                      ${CMAKE_THREAD_LIBS_INIT}
                      ${BDB_LIBRARY}
                      ${Boost_LIBRARIES}
                      ${OPENSSL_LIBRARIES}
        -L/usr/local/lib/
                     )

if(USE_GMP)
    target_link_libraries(bitcoin gmp)
endif()

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

