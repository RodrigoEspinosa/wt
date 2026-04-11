class Wt < Formula
  desc "Git worktree manager powered by fzf"
  homepage "https://github.com/RodrigoEspinosa/wt"
  url "https://github.com/RodrigoEspinosa/wt/archive/refs/tags/v0.1.2.tar.gz"
  sha256 "e4ee8b44568faea3b041c001c6efa4bae705c0bfa373274cb801646af558b15c"
  license "MIT"

  depends_on "fzf"

  def install
    bin.install "bin/wt"
  end

  test do
    assert_match "wt 0.1.2", shell_output("#{bin}/wt -v")
  end
end
