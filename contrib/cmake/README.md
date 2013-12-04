Bitcoin - Building with CMake
-----------------------------

**WARNING**: This patch is _experimental_!!  Only use it with the testnet for now! You will likely corrupt your wallet using this!

Features:
  - Can generate various IDE project files.
  - Allows out-of-source directory builds.
  - Allows CMakeLists.txt out-of-source builds.

Prerequisites:
  - >= CMake 2.8
  - >= libboost 1.45 (system filesystem thread)
  - OpenSSL
  - Protobuf

Optional prerequisites:
  - >= Qt 4.4.3 (QtCore QtGui QtNetwork QtDbus)
  - Miniupnpc
  - QRencode
  - Doxygen

1. Make a directory anywhere you want the binaries and libs to output to:
    $ mkdir ~/bitcoin-cmake
    $ cd ~/bitcoin-cmake

2. Run CMake with path to this contrib directory from your build directory:
    $ ccmake ~/src/bitcoin-qt/contrib/cmake

3. Select 'c' to configure.

4. If everything is found, set CMake build options:
  - CMAKE_BUILD_TYPE: Debug
  - CMAKE_INSTALL_PREFIX: ~/local (or wherever you want to install to)

5. Select 'g' to generate.

6. Initiate make:
    $ make

7. Libraries and executables are placed wrt build directory in: 'lib' and 'bin'.

8. Install to desired path (optional):
    $ make install

