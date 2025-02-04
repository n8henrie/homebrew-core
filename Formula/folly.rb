class Folly < Formula
  desc "Collection of reusable C++ library artifacts developed at Facebook"
  homepage "https://github.com/facebook/folly"
  url "https://github.com/facebook/folly/archive/v2022.02.14.00.tar.gz"
  sha256 "6ec28672a524e1d9d89cdb528d64362b939b4f0afc526767d93aa1ebb2639fc1"
  license "Apache-2.0"
  head "https://github.com/facebook/folly.git", branch: "main"

  bottle do
    sha256 cellar: :any,                 arm64_monterey: "296dd25f8bc82c034b44d6e312b48c0395ad4cd091f0a4aa9035699377114039"
    sha256 cellar: :any,                 arm64_big_sur:  "a7d321f22a73a9ea0f73d971c96f646695fcbac3c56ff954312d668ab64f25fe"
    sha256 cellar: :any,                 monterey:       "48d2b6afc5d1a74af4d26002c6627e905f3cae06ea166e0f9401d68932ac7397"
    sha256 cellar: :any,                 big_sur:        "b22b6ef90b85d3d508ef921506630088d7b7ab53a05c9816c4e5816c8a2e3f85"
    sha256 cellar: :any,                 catalina:       "34b08153bc0d6261879a83bd640f58bcaa11c0231ea51bd78feb14c3d6ab8b97"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "3e5174aac08d90a97296997b91e70cff1c5c1827ba3334b2473b30ee760e9480"
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "boost"
  depends_on "double-conversion"
  depends_on "fmt"
  depends_on "gflags"
  depends_on "glog"
  depends_on "libevent"
  depends_on "lz4"
  depends_on "openssl@1.1"
  depends_on "snappy"
  depends_on "xz"
  depends_on "zstd"

  on_macos do
    depends_on "llvm" if DevelopmentTools.clang_build_version <= 1100
  end

  on_linux do
    depends_on "gcc"
  end

  fails_with :clang do
    build 1100
    # https://github.com/facebook/folly/issues/1545
    cause <<-EOS
      Undefined symbols for architecture x86_64:
        "std::__1::__fs::filesystem::path::lexically_normal() const"
    EOS
  end

  fails_with gcc: "5"

  def install
    ENV.llvm_clang if OS.mac? && (DevelopmentTools.clang_build_version <= 1100)

    mkdir "_build" do
      args = std_cmake_args + %w[
        -DFOLLY_USE_JEMALLOC=OFF
      ]

      system "cmake", "..", *args, "-DBUILD_SHARED_LIBS=ON"
      system "make"
      system "make", "install"

      system "make", "clean"
      system "cmake", "..", *args, "-DBUILD_SHARED_LIBS=OFF"
      system "make"
      lib.install "libfolly.a", "folly/libfollybenchmark.a"
    end
  end

  test do
    # Force use of Clang rather than LLVM Clang
    ENV.clang if OS.mac?

    (testpath/"test.cc").write <<~EOS
      #include <folly/FBVector.h>
      int main() {
        folly::fbvector<int> numbers({0, 1, 2, 3});
        numbers.reserve(10);
        for (int i = 4; i < 10; i++) {
          numbers.push_back(i * 2);
        }
        assert(numbers[6] == 12);
        return 0;
      }
    EOS
    system ENV.cxx, "-std=c++14", "test.cc", "-I#{include}", "-L#{lib}",
                    "-lfolly", "-o", "test"
    system "./test"
  end
end
