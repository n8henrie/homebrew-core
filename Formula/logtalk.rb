class Logtalk < Formula
  desc "Object-oriented logic programming language"
  homepage "https://logtalk.org/"
  url "https://github.com/LogtalkDotOrg/logtalk3/archive/lgt3270stable.tar.gz"
  version "3.27.0"
  sha256 "ddfbd126bd6663462d72df113bf2a77ccc197a03a4133d465b0d07afa8d62363"

  bottle do
    cellar :any_skip_relocation
    sha256 "e2b3806d7686cafa339f363caffece517acf321dbc60b9627586b31df0c4cc8e" => :mojave
    sha256 "eef75b51b61a30c79acf0f8784590b0d9015d15cbbb8ec180ecce28008c15782" => :high_sierra
    sha256 "15d9b812979a71bb876483a01e906a8ccf1b279968848416cf19dd7e39aed503" => :sierra
  end

  depends_on "gnu-prolog"

  def install
    cd("scripts") { system "./install.sh", "-p", prefix }
  end
end
