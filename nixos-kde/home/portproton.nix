{ lib, stdenv, fetchurl, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "portproton";
  version = "24.09";

  src = fetchurl {
    url = "https://github.com/linux-gaming/PortProton/releases/download/${version}/portproton.tar.gz";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";  # ← Замени!
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/opt/portproton
    cp -r * $out/opt/portproton/

    mkdir -p $out/bin
    makeWrapper ${stdenv.shell} $out/bin/portproton \
      --set PORTPROTON_PATH "$out/opt/portproton" \
      --set WINEPREFIX "$HOME/.portproton/prefix" \
      --set WINEDEBUG "-all" \
      --add-flags "$out/opt/portproton/portproton.sh"
  '';

  meta = with lib; {
    description = "WINE Proton launcher without Steam";
    homepage = "https://linux-gaming.ru";
    license = licenses.gpl3;
    platforms = [ "x86_64-linux" ];
  };
}
