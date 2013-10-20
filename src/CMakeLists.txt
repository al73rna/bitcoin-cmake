
file(GLOB HEADERS *.h)
file(GLOB SOURCES *.cpp)

add_subdirectory(leveldb)

include_directories(${BDB_INCLUDE})

include_directories("leveldb/include")
include_directories("leveldb/helpers")

include_directories(${Boost_INCLUDE_DIRS})
add_definitions( "-DHAS_BOOST -DHAVE_WORKING_BOOST_SLEEP" )

include_directories(${OPENSSL_INCLUDE_DIRS})


add_library(bitcoin ${HEADERS} ${SOURCES})
target_link_libraries(bitcoin leveldb
                      ${CMAKE_THREAD_LIBS_INIT}
                      ${DB_LIBS}
                      ${Boost_LIBRARIES}
                      ${OpenSSL_LIBRARIES}
		      )

add_executable(bitcoind ${HEADERS} ${SOURCES})

target_link_libraries(bitcoind bitcoin
                      ${CMAKE_THREAD_LIBS_INIT}
		      ${BDB_LIBRARY}
                      ${Boost_LIBRARIES}
		      ${OPENSSL_LIBRARIES}
                      )



