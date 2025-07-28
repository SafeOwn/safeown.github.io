(function () {
    'use strict';

    // Имя плагина
    const PLUGIN_NAME = 'M3U Loader';

    // Регистрация плагина
    Lampa.Lang.add({
        ru: {
            'm3u_loader': 'M3U Плеер',
            'm3u_search': 'Поиск в M3U'
        },
        en: {
            'm3u_loader': 'M3U Player',
            'm3u_search': 'Search in M3U'
        }
    });

    // Основной класс плагина
    function M3ULoader() {
        this.playlist = [];
        this.displayedItems = [];
    }

    M3ULoader.prototype.init = function () {
        console.log('Plugin M3U Loader initialized');

        // Добавляем в меню
        Lampa.Manifest.plugins.push({
            name: 'm3u_loader',
            title: Lampa.Lang.translate('m3u_loader'),
            icon: 'img/icons/menu/catalog.svg',
            page: () => this.openPage()
        });

        // Интеграция в глобальный поиск
        Lampa.Search.addSource({
            title: Lampa.Lang.translate('m3u_search'),
            search: (query, call) => this.search(query, call)
        });
    };

    M3ULoader.prototype.openPage = function () {
        const page = Lampa.Page.build('m3u_loader');
        page.title = Lampa.Lang.translate('m3u_loader');

        const items = this.parsePlaylist();

        const container = Lampa.Template.get('items', {
            items: items,
            card_events: (item) => {
                Lampa.Player.play({
                    url: item.url,
                    title: item.title
                });
            }
        });

        page.append(container.render());

        Lampa.Activity.push({
            page: page,
            title: Lampa.Lang.translate('m3u_loader')
        });
    };

    M3ULoader.prototype.parsePlaylist = function () {
        // Пример плейлиста
        const playlistURL = 'https://example.com/playlist.m3u'; // заменить на свой URL

        const xhr = new XMLHttpRequest();
        xhr.open('GET', playlistURL, false); // синхронный запрос для простоты
        xhr.send();

        if (xhr.status === 200) {
            const lines = xhr.responseText.split('\n');
            let items = [];
            let title = '';
            let url = '';

            for (let i = 0; i < lines.length; i++) {
                const line = lines[i].trim();

                if (line.startsWith('#EXTINF:')) {
                    const titleMatch = line.match(/,(.*)$/);
                    title = titleMatch ? titleMatch[1] : 'Без названия';
                } else if (line.startsWith('http')) {
                    url = line;
                    items.push({
                        title: title,
                        url: url,
                        poster: this.getPoster(title), // генерируем обложку
                        year: 0,
                        genres: ['M3U']
                    });
                }
            }

            this.playlist = items;
            return this.adaptForScreen(items);
        }

        return [];
    };

    M3ULoader.prototype.getPoster = function (title) {
        // Можно использовать сервис обложек, например, через TMDB или заглушку
        return 'https://via.placeholder.com/300x450?text=' + encodeURIComponent(title);
    };

    M3ULoader.prototype.adaptForScreen = function (items) {
        const isTV = Lampa.Platform.is('tv');
        const count = isTV ? 6 : 2;

        this.displayedItems = items.slice(0, count);
        return this.displayedItems;
    };

    M3ULoader.prototype.search = function (query, callback) {
        const results = this.playlist.filter(item =>
            item.title.toLowerCase().includes(query.toLowerCase())
        );

        callback(results.map(item => ({
            title: item.title,
            year: item.year,
            genres: item.genres,
            poster: item.poster,
            onEnter: () => {
                Lampa.Player.play({
                    url: item.url,
                    title: item.title
                });
            }
        })));
    };

    // Инициализация плагина после загрузки Lampa
    if (window.Lampa) {
        new M3ULoader().init();
    } else {
        window.addEventListener('load', () => {
            new M3ULoader().init();
        });
    }

})();