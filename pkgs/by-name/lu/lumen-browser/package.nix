{ lib
, stdenv
, fetchFromGitHub
, makeWrapper
, nodejs
, electron
, kubo
}:

stdenv.mkDerivation rec {
  pname = "lumen-browser";
  version = "0.9.9";

  src = fetchFromGitHub {
    owner = "network-lumen";
    repo = "browser";
    rev = "v${version}";
    hash = "sha256-soVW0Wj5Jf/GUoUc5xzGC2OROacChRMj0FR9dzqqjwk=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    mkdir -p $out/share/${pname} $out/bin
    cp -r . $out/share/${pname}

    makeWrapper ${nodejs}/bin/npm $out/bin/lumen-browser \
      --run "cd $out/share/${pname} && [ -d node_modules ] || npm install --offline --no-fund || npm install" \
      --set ELECTRON_OVERRIDE_DIST_PATH "${electron}/bin" \
      --prefix PATH : "${lib.makeBinPath [ nodejs kubo electron ]}" \
      --add-flags "run dev" \
      --add-flags "\$@"
  '';

  meta = with lib; {
    description = "Lumen Browser self-contained runtime";
    homepage = "https://github.com/network-lumen/browser";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "lumen-browser";
  };
}
