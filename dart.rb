class Dart < Formula
  desc "The Dart SDK"
  homepage "https://www.dartlang.org/"

  version "1.24.3"
  if MacOS.prefer_64_bit?
    url "https://storage.googleapis.com/dart-archive/channels/stable/release/1.24.3/sdk/dartsdk-macos-x64-release.zip"
    sha256 "3419869401184d1ebf44e8947de36ac83ff614097c2c52a80792e89a25c18cd8"
  else
    url "https://storage.googleapis.com/dart-archive/channels/stable/release/1.24.3/sdk/dartsdk-macos-ia32-release.zip"
    sha256 "387fb5e1a1231b219a599d2d7efe250387e041d6b4822ec1ddbf364794762097"
  end

  devel do
    version "2.0.0-dev.24.0"
    if MacOS.prefer_64_bit?
      url "https://storage.googleapis.com/dart-archive/channels/dev/release/2.0.0-dev.24.0/sdk/dartsdk-macos-x64-release.zip"
      sha256 "39e3cfdddde33bcc45cc6fd7dba26af10b97baee271288b992e97d418e850c96"
    else
      url "https://storage.googleapis.com/dart-archive/channels/dev/release/2.0.0-dev.24.0/sdk/dartsdk-macos-ia32-release.zip"
      sha256 "631f0a4c7b532c3e88fdf5e3da5143c67fc9349c53f667d1c7c19622035b54ef"
    end
  end

  option "with-content-shell", "Download and install content_shell -- headless Dartium for testing"
  option "with-dartium", "Download and install Dartium -- Chromium with Dart"

  resource "content_shell" do
    version "1.24.3"
    url "https://storage.googleapis.com/dart-archive/channels/stable/release/1.24.3/dartium/content_shell-macos-x64-release.zip"
    sha256 "01efc473c68aed830307d1dafb0cbcbfe77f40ceeeab3ef3ebe58a9912d05b13"
  end

  resource "dartium" do
    version "1.24.3"
    url "https://storage.googleapis.com/dart-archive/channels/stable/release/1.24.3/dartium/dartium-macos-x64-release.zip"
    sha256 "188a038bd6367fddb434338bf6549bae25f5ad89b2f5b462acf8fb1fa20a3916"
  end

  def install
    libexec.install Dir["*"]
    bin.install_symlink "#{libexec}/bin/dart"
    bin.write_exec_script Dir["#{libexec}/bin/{pub,dart?*}"]

    if build.with? "dartium"
      dartium_binary = "Chromium.app/Contents/MacOS/Chromium"
      prefix.install resource("dartium")
      (bin+"dartium").write shim_script dartium_binary
    end

    if build.with? "content-shell"
      content_shell_binary = "Content Shell.app/Contents/MacOS/Content Shell"
      prefix.install resource("content_shell")
      (bin+"content_shell").write shim_script content_shell_binary
    end
  end

  def shim_script(target)
    <<-EOS.undent
      #!/usr/bin/env bash
      exec "#{prefix}/#{target}" "$@"
    EOS
  end

  def caveats; <<-EOS.undent
    Please note the path to the Dart SDK:
      #{opt_libexec}

    --with-dartium:
      To use with IntelliJ, set the Dartium execute home to:
        #{opt_prefix}/Chromium.app
    EOS
  end

  test do
    (testpath/"sample.dart").write <<-EOS.undent
      void main() {
        print(r"test message");
      }
    EOS

    assert_equal "test message\n", shell_output("#{bin}/dart sample.dart")
  end
end
