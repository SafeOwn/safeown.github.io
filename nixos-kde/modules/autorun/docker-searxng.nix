# Настройки Open WebUI
# Панель администратора -> Настройки -> Веб-поиск ->
# ВНИМАНИЕ!!! Обход встраивания и извлечения данных и Обход веб-загрузчика ставим галочки (или не ищет)
# Поисковая система searxng
# URL-адрес запроса Searxng -> http://localhost:8888/search?q=<query>&format=json&categories=general,files,it,science,news,images,videos,music,social media
# Количество результатов поиска -> 50, Одновременные запросы -> 15, Лимит длины содержимого URL -> 20000
{ config, pkgs, lib, ... }:

{
  # ========================================
  # 🔍 SEARXNG — Локальный поисковый движок (Docker)
  # ========================================

  # 1. "Зашиваем" конфигурационные файлы в Nix Store и прокидываем в /etc
  environment.etc."searxng/settings.yml".text = ''
    use_default_settings: true

    server:
      secret_key: "mysecretkey123"
      bind_address: "0.0.0.0"
      port: 8080
      limiter: false
      image_proxy: true

    search:
      safe_search: 0
      autocomplete: "google"
      default_lang: "ru"
      formats:
        - html
        - json
      ban_time_on_fail: 60
      suspended_times:
        SearxEngineAccessDenied: 300
        SearxEngineCaptcha: 300
        SearxEngineTooManyRequests: 60
      max_page: 5

    outgoing:
      request_timeout: 20.0
      max_request_timeout: 40.0
      pool_connections: 300
      pool_maxsize: 100
      enable_http2: true

    engines:
      # === ОТКЛЮЧИТЬ (Tor, API, банят VPN) ===
      - name: google
        disabled: true
      - name: google images
        disabled: true
      - name: google videos
        disabled: true
      - name: google news
        disabled: true
      - name: google scholar
        disabled: true
      - name: google play apps
        disabled: true
      - name: google play movies
        disabled: true
      - name: yandex
        disabled: true
      - name: yandex images
        disabled: true
      - name: yandex music
        disabled: true
      - name: braveapi
        inactive: true
      - name: flickr_api
        inactive: true
      - name: youtube_api
        inactive: true
      - name: wolframalpha_api
        inactive: true
      - name: springer
        inactive: true
      - name: deepl
        inactive: true
      - name: cloudflareai
        inactive: true
      - name: core.ac.uk
        inactive: true
      - name: astrophysics_data_system
        inactive: true
      - name: azure
        inactive: true
      - name: elasticsearch
        inactive: true
      - name: meilisearch
        inactive: true
      - name: postgresql
        inactive: true
      - name: mysql
        inactive: true
      - name: mariadb
        inactive: true
      - name: myvalkey
        inactive: true
      - name: opensemanticsearch
        inactive: true
      - name: seekninja
        inactive: true
      - name: xonaly
        inactive: true
      - name: tiger
        inactive: true
      - name: tiger news
        inactive: true
      - name: heexy
        inactive: true
      - name: luxxle
        inactive: true
      - name: neosearch
        inactive: true
      - name: chinaso news
        inactive: true
      - name: cl0q
        inactive: true
      - name: rawweb
        inactive: true
      - name: kukei
        inactive: true
      - name: kozmonavt
        inactive: true
      - name: grokipedia
        inactive: true
      - name: marginalia
        inactive: true
      - name: mwmbl
        inactive: true
      - name: zlibrary
        inactive: true
      - name: sina
        inactive: true
      - name: repology
        inactive: true

      # === ВЕБ ===
      - name: bing
        disabled: false
      - name: brave
        disabled: false
      - name: duckduckgo
        disabled: false
      - name: startpage
        disabled: false
      - name: mojeek
        disabled: false
      - name: qwant
        disabled: false
      - name: baidu
        disabled: false
      - name: seznam
        disabled: false
      - name: yahoo
        disabled: false
      - name: presearch
        disabled: false
      - name: dogpile
        disabled: false
      - name: yep
        disabled: false
      - name: sogou
        disabled: false
      - name: quark
        disabled: false
      - name: swisscows
        disabled: false
      - name: privacywall
        disabled: false
      - name: fireball
        disabled: false
      - name: resulthunter
        disabled: false
      - name: tusksearch
        disabled: false

      # === НОВОСТИ ===
      - name: bing news
        disabled: false
      - name: duckduckgo news
        disabled: false
      - name: brave.news
        disabled: false
      - name: qwant news
        disabled: false
      - name: startpage news
        disabled: false
      - name: presearch news
        disabled: false
      - name: hackernews
        disabled: false
      - name: reuters
        disabled: false
      - name: tagesschau
        disabled: false
      - name: wikinews
        disabled: false
      - name: ansa
        disabled: false
      - name: il post
        disabled: false
      - name: tusksearch news
        disabled: false

      # === ВИДЕО ===
      - name: youtube
        disabled: false
      - name: bing videos
        disabled: false
      - name: duckduckgo videos
        disabled: false
      - name: brave.videos
        disabled: false
      - name: qwant videos
        disabled: false
      - name: dailymotion
        disabled: false
      - name: vimeo
        disabled: false
      - name: peertube
        disabled: false
      - name: sepiasearch
        disabled: false
      - name: rumble
        disabled: false
      - name: odysee
        disabled: false
      - name: bitchute
        disabled: false
      - name: iqiyi
        disabled: false
      - name: bilibili
        disabled: false
      - name: niconico
        disabled: false
      - name: tusksearch videos
        disabled: false

      # === КАРТИНКИ ===
      - name: bing images
        disabled: false
      - name: duckduckgo images
        disabled: false
      - name: brave.images
        disabled: false
      - name: qwant images
        disabled: false
      - name: startpage images
        disabled: false
      - name: presearch images
        disabled: false
      - name: flickr
        disabled: false
      - name: pexels
        disabled: false
      - name: unsplash
        disabled: false
      - name: pinterest
        disabled: false
      - name: imgur
        disabled: false
      - name: deviantart
        disabled: false
      - name: wikicommons.images
        disabled: false
      - name: tusksearch images
        disabled: false

      # === ТОРРЕНТЫ ===
      - name: piratebay
        disabled: false
      - name: 1337x
        disabled: false
      - name: solidtorrents
        disabled: false
      - name: bt4g
        disabled: false
      - name: btdigg
        disabled: false
      - name: kickass
        disabled: false
      - name: nyaa
        disabled: false
      - name: tokyotoshokan
        disabled: false
      - name: findfiles
        disabled: false
      - name: findfiles images
        disabled: false
      - name: findfiles videos
        disabled: false
      - name: findfiles music
        disabled: false

      # === МУЗЫКА ===
      - name: bandcamp
        disabled: false
      - name: soundcloud
        disabled: false
      - name: genius
        disabled: false
      - name: mixcloud
        disabled: false
      - name: deezer
        disabled: false
      - name: piped.music
        disabled: false
      - name: radio browser
        disabled: false
      - name: wikicommons.audio
        disabled: false

      # === КОД ===
      - name: github
        disabled: false
      - name: github code
        disabled: false
      - name: stackoverflow
        disabled: false
      - name: superuser
        disabled: false
      - name: askubuntu
        disabled: false
      - name: gitlab
        disabled: false
      - name: codeberg
        disabled: false
      - name: gitea.com
        disabled: false
      - name: bitbucket
        disabled: false
      - name: sourcehut
        disabled: false
      - name: npm
        disabled: false
      - name: pypi
        disabled: false
      - name: crates.io
        disabled: false
      - name: rubygems
        disabled: false
      - name: pub.dev
        disabled: false
      - name: pkg.go.dev
        disabled: false
      - name: hex
        disabled: false
      - name: packagist
        disabled: false
      - name: docker hub
        disabled: false
      - name: huggingface
        disabled: false
      - name: huggingface datasets
        disabled: false
      - name: huggingface spaces
        disabled: false
      - name: ollama
        disabled: false
      - name: alpine linux packages
        disabled: false
      - name: cachy os packages
        disabled: false
      - name: fdroid
        disabled: false
      - name: apple app store
        disabled: false
      - name: apk mirror
        disabled: false
      - name: anaconda
        disabled: false
      - name: arch linux wiki
        disabled: false
      - name: gentoo
        disabled: false
      - name: voidlinux
        disabled: false
      - name: nixos wiki
        disabled: false
      - name: free software directory
        disabled: false
      - name: mdn
        disabled: false
      - name: microsoft learn
        disabled: false
      - name: lobste.rs
        disabled: false

      # === ЭНЦИКЛОПЕДИИ ===
      - name: wikipedia
        disabled: false
      - name: wikidata
        disabled: false
      - name: wiktionary
        disabled: false
      - name: wikibooks
        disabled: false
      - name: wikiquote
        disabled: false
      - name: wikisource
        disabled: false
      - name: wikispecies
        disabled: false
      - name: wikiversity
        disabled: false
      - name: wikivoyage
        disabled: false
      - name: wikimini
        disabled: false
      - name: wikicommons.files
        disabled: false
      - name: openstreetmap
        disabled: false
      - name: openlibrary
        disabled: false
      - name: pubmed
        disabled: false
      - name: semantic scholar
        disabled: false
      - name: crossref
        disabled: false
      - name: openalex
        disabled: false
      - name: openairedatasets
        disabled: false
      - name: openairepublications
        disabled: false
      - name: arxiv
        disabled: false
      - name: pdbe
        disabled: false

      # === КНИГИ ===
      - name: library genesis
        disabled: false
      - name: annas archive
        disabled: false
      - name: openrepos
        disabled: false

      # === СОЦСЕТИ ===
      - name: reddit
        disabled: false
      - name: mastodon users
        disabled: false
      - name: mastodon hashtags
        disabled: false
      - name: lemmy communities
        disabled: false
      - name: lemmy posts
        disabled: false
      - name: lemmy comments
        disabled: false
      - name: tootfinder
        disabled: false

      # === КАРТЫ ===
      - name: apple maps
        disabled: false
      - name: photon
        disabled: false

      # === ФИНАНСЫ ===
      - name: currency
        disabled: false

      # === ПЕРЕВОДЫ ===
      - name: lingva
        disabled: false
      - name: mozhi
        disabled: false
      - name: mymemory translated
        disabled: false
      - name: dictzone
        disabled: false

      # === ПОГОДА ===
      - name: duckduckgo weather
        disabled: false
      - name: wttr.in
        disabled: false
      - name: openmeteo
        disabled: false

      # === ФИЛЬМЫ ===
      - name: imdb
        disabled: false
      - name: tmdb
        disabled: false
      - name: rottentomatoes
        disabled: false
      - name: moviepilot
        disabled: false

      # === ПРОЧЕЕ ===
      - name: habrahabr
        disabled: false
      - name: chefkoch
        disabled: false
      - name: etymonline
        disabled: false
      - name: wordnik
        disabled: false
      - name: emojipedia
        disabled: false
      - name: lucide
        disabled: false
      - name: devicons
        disabled: false
      - name: material icons
        disabled: false
      - name: selfhst icons
        disabled: false
      - name: uxwing
        disabled: false
      - name: flaticon
        disabled: false
      - name: openverse
        disabled: false
      - name: stocksnap
        disabled: false
      - name: picjumbo
        disabled: false
      - name: pixabay images
        disabled: false
      - name: pixabay videos
        disabled: false
      - name: findthatmeme
        disabled: false
      - name: ina
        disabled: false
      - name: artic
        disabled: false
      - name: media.ccc.de
        disabled: false
      - name: boardreader
        disabled: false
      - name: bpb
        disabled: false
      - name: destatis
        disabled: false
      - name: erowid
        disabled: false
      - name: frinkiac
        disabled: false
      - name: goodreads
        disabled: false
      - name: gmx
        disabled: false
      - name: jisho
        disabled: false
      - name: mankier
        disabled: false
      - name: metacpan
        disabled: false
      - name: senscritique
        disabled: false
      - name: shopify stock
        disabled: false
      - name: steam
        disabled: false
      - name: wolframalpha
        disabled: false
      - name: woxikon.de synonyme
        disabled: false
      - name: yacy
        disabled: false
      - name: encyclosearch
        disabled: false
      - name: crowdview
        disabled: false
      - name: wiby
        disabled: false
      - name: unobtanium
        disabled: false
      - name: searchmysite
        disabled: false
      - name: infospace
        disabled: false
      - name: searchch
        disabled: false
      - name: searchzee
        disabled: false
      - name: searchzee news
        disabled: false
      - name: reloado
        disabled: false
      - name: startpagina
        disabled: false
      - name: startpagina images
        disabled: false
      - name: startpagina videos
        disabled: false
      - name: startpagina news
        disabled: false
      - name: zapmeta
        disabled: false
      - name: vuhuv
        disabled: false
      - name: vuhuv images
        disabled: false
      - name: vuhuv videos
        disabled: false
      - name: magnific
        disabled: false
      - name: cara
        disabled: false
      - name: fynd
        disabled: false
      - name: fyyd
        disabled: false
      - name: gabanza
        disabled: false
      - name: geizhals
        disabled: false
      - name: fastbot
        disabled: false

    doi_resolvers:
      oadoi.org: 'https://oadoi.org/'
      doi.org: 'https://doi.org/'
      sci-hub.se: 'https://sci-hub.se/'

    default_doi_resolver: 'oadoi.org'
  '';

  # Пустой файл, чтобы убрать WARNING "missing config file: limiter.toml"
  environment.etc."searxng/limiter.toml".text = ''
    # Empty limiter config
  '';

  # 2. Запускаем Docker-контейнер через нативный модуль NixOS
  virtualisation.oci-containers.backend = "docker";
  virtualisation.oci-containers.containers.searxng = {
    image = "searxng/searxng:latest";
    autoStart = true; # ✅ NixOS сам добавит это в автозагрузку (systemd)
    ports = ["8888:8080"];
    volumes = [
      # Монтируем файлы, которые мы создали через environment.etc
      "/etc/searxng/settings.yml:/etc/searxng/settings.yml:ro"
      "/etc/searxng/limiter.toml:/etc/searxng/limiter.toml:ro"
    ];
    environment = {
      SEARXNG_BASE_URL = "http://localhost:8888/";
    };
  };
}
