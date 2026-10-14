class Dtidy < Formula
  desc "Sort loose Desktop items into folders, with undo"
  homepage "https://github.com/dtidy-app/dtidy-macos"
  url "https://github.com/dtidy-app/dtidy-macos/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "03d170f6ea3d2f65b1554c896cf085ce8ee237218411b2a8c8e528bda9a7d784"
  license "GPL-3.0-or-later"
  head "https://github.com/dtidy-app/dtidy-macos.git", branch: "main"

  bottle do
    root_url "https://github.com/dtidy-app/homebrew-tap/releases/download/dtidy-0.1.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "6ec3f5fa8182c2ce5a91c65ddafb875872ee2e5c19d805575da9b82d73bded9f"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "05c457e30c9a93248134b2aadc7bd494d5d65fa096a9f0f83ae99e4955947fcd"
  end

  depends_on xcode: ["16.0", :build]
  depends_on macos: :sonoma

  def install
    system "swift", "build", "--disable-sandbox", "--configuration", "release"
    bin.install ".build/release/dtidy"
    generate_completions_from_executable(bin/"dtidy", "--generate-completion-script")
    man1.install "docs/man/dtidy.1"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/dtidy --version")

    ENV["XDG_DATA_HOME"] = testpath/"data"
    ENV["XDG_CONFIG_HOME"] = testpath/"config"
    (testpath/"root").mkpath
    # Older than the 10-second "too recent" window, so plan does not skip it.
    touch testpath/"root/report.pdf", mtime: Time.new(2020, 1, 1)
    assert_match "PDFs/report.pdf", shell_output("#{bin}/dtidy plan --root #{testpath}/root")
    refute_path_exists testpath/"data/dtidy"
  end
end
