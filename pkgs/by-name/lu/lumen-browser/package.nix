{ lib
, buildNpmPackage
, fetchFromGitHub
, makeWrapper
, nodejs
, electron
, kubo
, xorg
, xvfb-run
}:

buildNpmPackage rec {
  pname = "lumen-browser";
  version = "0.9.25";

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

    makeWrapper ${xvfb-run}/bin/xvfb-run $out/bin/lumen-browser \
      --add-flags "--auto-servernum" \
      --add-flags "${nodejs}/bin/npm" \
      --run 'RUNTIME_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}/lumen-browser-dev"; mkdir -p "$RUNTIME_DIR"; if [ ! -f "$RUNTIME_DIR/package.json" ]; then cp -r --no-preserve=mode ${placeholder "out"}/share/${pname}/* "$RUNTIME_DIR/"; chmod -R +rwx "$RUNTIME_DIR"; fi; cd "$RUNTIME_DIR"' \
      --set ELECTRON_OVERRIDE_DIST_PATH "${electron}/bin" \
      --prefix PATH : "${lib.makeBinPath [ nodejs kubo electron xorg.xorgserver xvfb-run ]}" \
      --set IPFS_PATH "${lib.getBin kubo}/bin/ipfs" \
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
