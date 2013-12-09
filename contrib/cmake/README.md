Bitcoin - Building with CMake
-----------------------------

**WARNING**: This patch is _experimental_!! Only use it with the testnet for now! You will likely corrupt your wallet using this! 

Features:
  - Can generate various IDE project files.
  - Allows out-of-source directory builds.
  - Provides GUI access to configurable bitcoin build options.
  - Allows CMakeLists.txt out-of-source builds (as in contrib/cmake).

Prerequisites:
  - >= CMake 2.8
  - >= libboost 1.45 (system filesystem thread)
  - OpenSSL
  - Protobuf

Optional dependencies:
  - >= Qt 4.4.3 (QtCore QtGui QtNetwork QtDbus)
  - Miniupnpc
  - QRencode
  - Doxygen

Linux Build Instructions:

1. Create a directory where you want the binaries and libs to compile to:
    $ mkdir -f ~/tmp && mkdir ~/tmp/bitcoin-cmake
    $ cd ~/tmp/bitcoin-cmake

2. Run CMake with path to this contrib directory from your build directory:
    $ ccmake ~/src/bitcoin-qt/contrib/cmake
    alternatively:
    $ cmake-gui ~/src/bitcoin-qt/contrib/cmake

3. Select 'c' to configure or click the Configure button.

4. If everything is found, set CMake build options:
  - CMAKE_BUILD_TYPE: Debug
  - CMAKE_INSTALL_PREFIX: ~/local (or wherever you want to install to)

5. Select 'g' to generate or click the Generate button.

6. Initiate 'make' or start your IDE of choice using generated project files:
    $ make

7. Libraries and executables are placed wrt build directory in: 'lib' and 'bin'.

8. Install to desired path (optional):
    $ make install

Windows Build Instructions:

1. TODO


