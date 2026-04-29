class Wt < Formula
  desc "Git worktree manager powered by fzf"
  homepage "https://github.com/RodrigoEspinosa/wt"
  url "https://github.com/RodrigoEspinosa/wt/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "e4aee19fd7e16b2b320fb2d2b4d3c2f10925bcf52196890d98ae384db7cc2bef"
  license "MIT"

  depends_on "fzf"

  def install
    bin.install "bin/wt"
    man1.install "doc/wt.1"
  end

  test do
    assert_match "wt 0.2.0", shell_output("#{bin}/wt -v")
  end
end
