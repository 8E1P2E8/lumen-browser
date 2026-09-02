{ lib
, buildNpmPackage
, fetchFromGitHub
, makeWrapper
, nodejs
, electron
, kubo
}:

buildNpmPackage rec {
  pname = "lumen-browser";
  version = "0.9.20";

  src = fetchFromGitHub {
    owner = "network-lumen";
    repo = "browser";
    rev = "v0.9.9";
    hash = "sha256-soVW0Wj5Jf/GUoUc5xzGC2OROacChRMj0FR9dzqqjwk=";
  };

  npmDepsHash = "sha256-OtwQkkGzbqC9Z4qgg5A9xfFUoOsbjr7t2wGsZnNsCNY=";
  npmFlags = [ "--ignore-scripts" ];

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/${pname} $out/bin
    cp -r . $out/share/${pname}

    makeWrapper ${nodejs}/bin/npm $out/bin/lumen-browser \
      --run 'RUNTIME_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}/lumen-browser-dev"; mkdir -p "$RUNTIME_DIR"; if [ ! -f "$RUNTIME_DIR/package.json" ]; then cp -r --no-preserve=mode ${placeholder "out"}/share/${pname}/* "$RUNTIME_DIR/"; chmod -R +rwx "$RUNTIME_DIR"; fi; cd "$RUNTIME_DIR"' \
      --set ELECTRON_OVERRIDE_DIST_PATH "${electron}" \
      --prefix PATH : "${lib.makeBinPath [ nodejs kubo electron ]}" \
      --add-flags "run dev" \
      --add-flags "\$@"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Lumen Browser self-contained runtime";
    homepage = "https://github.com/network-lumen/browser";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "lumen-browser";
  };
}
