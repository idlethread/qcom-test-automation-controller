# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
#
# SPDX-License-Identifier: BSD-3-Clause

class Qtac < Formula
  desc "Qualcomm Test Automation Controller device-control libraries (QCommonConsole + TACDev C API)"
  homepage "https://github.com/qualcomm/qcom-test-automation-controller"
  license "BSD-3-Clause"

  # Remote HEAD (default):
  #   brew install --HEAD --formula ./Formula/qtac.rb
  #
  # Local source (recommended for development — see README for local tap setup):
  #   brew install --HEAD --formula ./Formula/qtac.rb
  head "https://github.com/qualcomm/qcom-test-automation-controller.git", branch: "main"

  depends_on "cmake" => :build
  depends_on "qt"

  def install
    args = std_cmake_args + %W[
      -DBUILD_UI=OFF
      -DCMAKE_PREFIX_PATH=#{Formula["qt"].opt_prefix}
    ]

    system "cmake", "-S", ".", "-B", "build", *args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    # Install the FTDI runtime dylib fetched during cmake configure
    lib.install Dir["__Builds/Linux/Release/lib/libftd2xx*.dylib"]
  end

  test do
    (testpath/"test.c").write <<~C
      #include <qtac/TACDev.h>
      int main(void) { return 0; }
    C
    system ENV.cc, "-I#{include}", "test.c", "-o", "#{testpath}/test"
  end
end
