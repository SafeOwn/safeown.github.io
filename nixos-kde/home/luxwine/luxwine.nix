{ stdenv }:

stdenv.mkDerivation {
  name = "luxwine-wrapper";
  version = "latest";

  buildCommand = ''
    mkdir -p $out/bin $out/share/applications

    cat > $out/bin/lwrun <<'EOF'
    #!/bin/sh
    LW_BIN="$HOME/.local/share/LuxWine/bin/lwrun"

    if [ ! -x "$LW_BIN" ]; then
      echo "📦 Устанавливаю LuxWine..."
      curl -sL https://lwrap.github.io | bash
    fi

    if [ ! -x "$LW_BIN" ]; then
      echo "❌ Ошибка: не удалось установить LuxWine"
      exit 1
    fi

    exec "$LW_BIN" "$@"
    EOF
    chmod +x $out/bin/lwrun
    ln -sf $out/bin/lwrun $out/bin/luxwine

    cat > $out/share/applications/luxwine.desktop <<EOF
    [Desktop Entry]
    Name=LuxWine
    Comment=Запуск Windows-приложений
    Exec=luxwine
    Icon=application-x-wine-extension-exe
    Terminal=false
    Type=Application
    Categories=Application;Utility;Wine;
    EOF
  '';
}
