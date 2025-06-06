{
  lib,
  stdenv,
  fetchurl,
  fetchpatch,
  libtool,
  libtommath,
}:

stdenv.mkDerivation rec {
  pname = "libtomcrypt";
  version = "1.18.2";

  src = fetchurl {
    url = "https://github.com/libtom/libtomcrypt/releases/download/v${version}/crypt-${version}.tar.xz";
    sha256 = "113vfrgapyv72lalhd3nkw7jnks8az0gcb5wqn9hj19nhcxlrbcn";
  };

  patches = [
    (fetchpatch {
      name = "CVE-2019-17362.patch";
      url = "https://github.com/libtom/libtomcrypt/pull/508/commits/25c26a3b7a9ad8192ccc923e15cf62bf0108ef94.patch";
      sha256 = "1bwsj0pwffxw648wd713z3xcyrbxc2z646psrzp38ys564fjh5zf";
    })
  ];

  buildInputs = [
    libtommath
  ];

  postPatch = ''
    substituteInPlace makefile.shared \
      --replace-fail "LIBTOOL:=glibtool" "LIBTOOL:=libtool" \
      --replace-fail libtool "${lib.getExe libtool}"
  '';

  preBuild = ''
    makeFlagsArray+=(PREFIX=$out \
      CFLAGS="-DUSE_LTM -DLTM_DESC -DLTC_PTHREAD" \
      EXTRALIBS=\"-ltommath\" \
      INSTALL_GROUP=$(id -g) \
      INSTALL_USER=$(id -u))
  '';

  makefile = "makefile.shared";

  enableParallelBuilding = true;

  meta = with lib; {
    description = "Fairly comprehensive, modular and portable cryptographic toolkit";
    homepage = "https://www.libtom.net/LibTomCrypt/";
    changelog = "https://github.com/libtom/libtomcrypt/raw/v${version}/changes";
    license = with licenses; [
      publicDomain
      wtfpl
    ];
    maintainers = [ ];
    platforms = platforms.all;
  };
}
