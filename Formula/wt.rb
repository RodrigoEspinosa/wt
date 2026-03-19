class Wt < Formula
  desc "Git worktree manager powered by fzf"
  homepage "https://github.com/RodrigoEspinosa/wt"
  url "https://github.com/RodrigoEspinosa/wt/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "REPLACE_WITH_SHA256"
  license "MIT"

  depends_on "fzf"

  def install
    bin.install "bin/wt"
  end

  test do
    assert_match "wt 0.1.0", shell_output("#{bin}/wt -v")
  end
end
