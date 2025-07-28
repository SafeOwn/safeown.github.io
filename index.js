(function () {
    'use strict';

    // --- Конфигурация ---
    const PLUGIN_NAME = 'Simple M3U';
    const PLAYLIST_URL = 'https://safeown.github.io/plvideo_4k_final_with_posters.m3u'; // Замените на ваш URL
    // --------------------

    // Добавляем переводы
    Lampa.Lang.add({
        ru: {
            'simple_m3u_title': PLUGIN_NAME,
            'simple_m3u_search': 'Поиск в ' + PLUGIN_NAME
        },
        en: {
            'simple_m3u_title': PLUGIN_NAME,
            'simple_m3u_search': 'Search in ' + PLUGIN_NAME
        }
        // Добавьте другие языки при необходимости
    });

    // --- Основной класс плагина ---
    function SimpleM3UPlugin() {
        this.items = []; // Массив для хранения распарсенных элементов
    }

    // Инициализация плагина
    SimpleM3UPlugin.prototype.init = function () {
        console.log('[' + PLUGIN_NAME + '] Plugin initialized');

        // Добавляем пункт в главное меню
        Lampa.Manifest.plugins.push({
            name: 'simple_m3u', // Должно совпадать с component
            title: Lampa.Lang.translate('simple_m3u_title'),
            icon: '<svg viewBox="0 0 24 24" fill="currentColor"><path d="M8 5v14l11-7z"/></svg>', // Простая иконка Play
            page: () => this.openMainPage()
        });

        // Интеграция в глобальный поиск
        Lampa.Search.addSource({
            title: Lampa.Lang.translate('simple_m3u_search'),
            search: (query, call) => this.globalSearch(query, call)
        });
    };

    // Открытие главной страницы плагина
    SimpleM3UPlugin.prototype.openMainPage = function () {
        const activity = {
            component: 'simple_m3u_main',
            // Можно добавить другие параметры активности при необходимости
        };
        Lampa.Activity.push(activity);
    };

    // --- Компонент для главной страницы плагина ---
    function SimpleM3UMainComponent(object) {
        this.activity = object;
        this.html = $('<div></div>');
        this.scroll = new Lampa.Scroll({ mask: true, over: true });
        this.items = [];
        this.last_focused_card = null;
    }

    SimpleM3UMainComponent.prototype.create = function () {
        this.activity.loader(true);
        this.html.append(this.scroll.render());
        this.loadPlaylist();
        return this.html;
    };

    SimpleM3UMainComponent.prototype.loadPlaylist = function () {
        const network = new Lampa.Reguest();
        network.native(
            PLAYLIST_URL,
            (data) => { // Успех
                if (typeof data === 'string' && data.trim().startsWith('#EXTM3U')) {
                    this.items = this.parseM3U(data);
                    this.buildPage();
                } else {
                    console.error('[' + PLUGIN_NAME + '] Полученные данные не являются корректным M3U.');
                    this.showErrorMessage('Полученные данные не являются корректным M3U плейлистом.');
                }
            },
            (error) => { // Ошибка
                console.error('[' + PLUGIN_NAME + '] Ошибка загрузки плейлиста:', error);
                this.showErrorMessage('Ошибка загрузки плейлиста: ' + (error.statusText || error.message || 'Неизвестная ошибка'));
            },
            false, // cache
            { dataType: 'text' }
        );
    };

    SimpleM3UMainComponent.prototype.parseM3U = function (m3uString) {
        const lines = m3uString.split(/\r?\n/);
        const items = [];
        let currentItem = { title: '', url: '' };

        for (let i = 0; i < lines.length; i++) {
            const line = lines[i].trim();
            if (line.startsWith('#EXTINF:')) {
                // Извлекаем название
                const titleMatch = line.match(/,(.*)$/);
                currentItem.title = titleMatch ? titleMatch[1].trim() : 'Без названия';
            } else if (line.startsWith('http') && line.includes('://')) {
                currentItem.url = line;
                if (currentItem.url) { // Добавляем только если есть URL
                    items.push({
                        title: currentItem.title || 'Без названия',
                        url: currentItem.url
                    });
                    // Сброс для следующего элемента
                    currentItem = { title: '', url: '' };
                }
            }
        }
        console.log('[' + PLUGIN_NAME + '] Распарсено элементов:', items.length);
        return items;
    };

    SimpleM3UMainComponent.prototype.buildPage = function () {
        const cards_container = $('<div class="simple-m3u-cards-container"></div>');
        this.scroll.append(cards_container);

        // Добавляем CSS для адаптивной сетки
        if (!$('#simple-m3u-styles').length) {
            $('body').append(`
                <style id="simple-m3u-styles">
                    .simple-m3u-cards-container {
                        display: flex;
                        flex-wrap: wrap;
                        gap: 1.5em;
                        padding: 1.5em;
                    }
                    /* Телефон: 2 колонки */
                    .simple-m3u-card {
                        width: calc(50% - 0.75em); /* 2 колонки: (100% - 1 промежуток) / 2 */
                        position: relative;
                        border-radius: 0.5em;
                        overflow: hidden;
                        background-color: #2b2b2b;
                        cursor: pointer;
                    }
                    .simple-m3u-card__img {
                        width: 100%;
                        /* Книжная ориентация: высота больше ширины */
                        padding-bottom: 150%; /* Соотношение сторон 2:3 */
                        background-size: cover;
                        background-position: center;
                        background-color: #3a3a3a;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        color: #aaa;
                        font-size: 0.9em;
                        text-align: center;
                        overflow: hidden;
                        text-overflow: ellipsis;
                        padding: 0.5em;
                        box-sizing: border-box;
                    }
                    .simple-m3u-card__title {
                        padding: 0.5em;
                        font-size: 1em;
                        white-space: nowrap;
                        overflow: hidden;
                        text-overflow: ellipsis;
                        background-color: rgba(0,0,0,0.5);
                        position: absolute;
                        bottom: 0;
                        left: 0;
                        right: 0;
                    }

                    /* Телевизор: 6 колонок */
                    @media screen and (min-width: 768px) {
                        .simple-m3u-card {
                            width: calc(16.666% - 1.25em); /* 6 колонок: (100% - 5 промежутков) / 6 */
                        }
                    }
                </style>
            `);
        }

        this.items.forEach((item, index) => {
            const card = $(`
                <div class="simple-m3u-card selector">
                    <div class="simple-m3u-card__img" style="background-image: url('${this.getPosterUrl(item.title)}');">
                        ${!this.getPosterUrl(item.title) ? item.title.substring(0, 30) + (item.title.length > 30 ? '...' : '') : ''}
                    </div>
                    <div class="simple-m3u-card__title">${item.title}</div>
                </div>
            `);

            card.on('hover:enter', () => {
                Lampa.Player.play({
                    title: item.title,
                    url: item.url
                });
            });

            cards_container.append(card);
        });

        this.activity.loader(false);
        this.activity.toggle();
    };

    SimpleM3UMainComponent.prototype.getPosterUrl = function (title) {
        // В этом простом примере используем заглушку.
        // В реальном плагине можно интегрироваться с TMDB API или другим источником обложек.
        // return `https://image.tmdb.org/t/p/w300_and_h450_bestv2/...`;
        return ''; // Пока без реальных обложек
    };

    SimpleM3UMainComponent.prototype.showErrorMessage = function (message) {
        this.html.empty();
        this.html.append(`<div style="padding: 20px; color: #ff5555;">Ошибка: ${message}</div>`);
        this.activity.loader(false);
        this.activity.toggle();
    };

    SimpleM3UMainComponent.prototype.start = function () {
        Lampa.Controller.add('content', {
            toggle: () => {
                Lampa.Controller.collectionSet(this.scroll.render());
                Lampa.Controller.collectionFocus(this.last_focused_card || false, this.scroll.render());
            },
            left: () => { if (Navigator.canmove('left')) Navigator.move('left'); else Lampa.Controller.toggle('menu'); },
            right: () => { if (Navigator.canmove('right')) Navigator.move('right'); },
            up: () => { if (Navigator.canmove('up')) Navigator.move('up'); else Lampa.Controller.toggle('head'); },
            down: () => { if (Navigator.canmove('down')) Navigator.move('down'); },
            back: () => { Lampa.Activity.backward(); }
        });
        Lampa.Controller.toggle('content');
    };

    SimpleM3UMainComponent.prototype.pause = function () { };
    SimpleM3UMainComponent.prototype.stop = function () { };
    SimpleM3UMainComponent.prototype.render = function () { return this.html; };
    SimpleM3UMainComponent.prototype.destroy = function () {
        this.scroll.destroy();
        this.html.remove();
        // Удаляем стили при уничтожении последнего экземпляра, если нужно
        // if ($('.simple-m3u-card').length === 0) $('#simple-m3u-styles').remove();
    };

    // --- Поиск ---
    SimpleM3UPlugin.prototype.globalSearch = function (query, callback) {
        // Загружаем и парсим плейлист при первом поиске, если он еще не загружен
        if (this.items.length === 0) {
            const network = new Lampa.Reguest();
            network.native(
                PLAYLIST_URL,
                (data) => {
                    if (typeof data === 'string' && data.trim().startsWith('#EXTM3U')) {
                        this.items = this.parseM3U(data);
                        this.performSearch(query, callback);
                    } else {
                        console.warn('[' + PLUGIN_NAME + '] Поиск: Не удалось загрузить плейлист для поиска.');
                        callback([]);
                    }
                },
                (error) => {
                    console.error('[' + PLUGIN_NAME + '] Поиск: Ошибка загрузки плейлиста:', error);
                    callback([]);
                },
                false,
                { dataType: 'text' }
            );
        } else {
            this.performSearch(query, callback);
        }
    };

    SimpleM3UPlugin.prototype.performSearch = function (query, callback) {
        const search_results = this.items.filter(item =>
            item.title.toLowerCase().includes(query.toLowerCase())
        ).map(item => ({
            title: item.title,
            // year: 0,
            // genres: ['M3U'],
            // poster: this.getPosterUrl(item.title), // Можно добавить позже
            onEnter: () => {
                Lampa.Player.play({
                    title: item.title,
                    url: item.url
                });
            }
        }));
        callback(search_results);
    };
    // --- Конец Поиска ---

    // Регистрируем компонент главной страницы
    Lampa.Component.add('simple_m3u_main', SimpleM3UMainComponent);

    // Инициализируем плагин после загрузки Lampa
    if (window.Lampa) {
        new SimpleM3UPlugin().init();
    } else {
        window.addEventListener('load', () => {
            new SimpleM3UPlugin().init();
        });
    }

})();
