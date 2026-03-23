class Wt < Formula
  desc "Git worktree manager powered by fzf"
  homepage "https://github.com/RodrigoEspinosa/wt"
  url "https://github.com/RodrigoEspinosa/wt/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "e9dc4bda5e824f08277b47a55b576b6f27e8325706866bb6d3b117dcc83357d5"
  license "MIT"

  depends_on "fzf"

  def install
    bin.install "bin/wt"
  end

  test do
    assert_match "wt 0.1.0", shell_output("#{bin}/wt -v")
  end
end
