class Wt < Formula
  desc "Git worktree manager powered by fzf"
  homepage "https://github.com/RodrigoEspinosa/wt"
  url "https://github.com/RodrigoEspinosa/wt/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "97f2a5d181b0b0540897b9f85c5a28e8dc534ca4fbb2cbbaacd36f8559942550"
  license "MIT"

  depends_on "fzf"

  def install
    bin.install "bin/wt"
  end

  test do
    assert_match "wt 0.1.1", shell_output("#{bin}/wt -v")
  end
end
