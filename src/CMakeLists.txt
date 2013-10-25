
file(GLOB HEADERS *.h)
file(GLOB SOURCES *.cpp)

# remove bitcoind main() from lib:
list(REMOVE_ITEM SOURCES bitcoind.cpp)

add_subdirectory(leveldb)

add_definitions( "-DHAS_BOOST -DHAVE_WORKING_BOOST_SLEEP" )

include_directories(${BDB_INCLUDE}
                    ${Boost_INCLUDE_DIRS}
                    ${OPENSSL_INCLUDE_DIRS}
                    "leveldb/include"
                    "leveldb/helpers"
                    )

add_library(bitcoin ${HEADERS} ${SOURCES})
target_link_libraries(bitcoin leveldb
                      ${CMAKE_THREAD_LIBS_INIT}
		      ${BDB_LIBRARY}
                      ${Boost_LIBRARIES}
		      ${OPENSSL_LIBRARIES}
		      )

add_executable(bitcoind bitcoind.cpp)
target_link_libraries(bitcoind bitcoin)

# TODO: conditional subdirectory
add_subdirectory( qt )

