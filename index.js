(function () {
    'use strict';

    // --- Конфигурация ---
    const PLUGIN_NAME = 'my_4k_iptv'; // Внутреннее имя плагина
    const MENU_TITLE = '4kTV'; // Название в меню
    const PLAYLIST_URL = 'https://safeown.github.io/plvideo_4k_final_with_posters.m3u'; // Ваш URL
    // --------------------

    // --- Основной объект плагина ---
    const plugin = {
        component: PLUGIN_NAME,
        icon: "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"24\" height=\"24\" viewBox=\"0 0 24 24\" fill=\"currentColor\"><path d=\"M8 5v14l11-7z\"/></svg>", // Простая иконка Play
        name: MENU_TITLE
    };

    // Добавляем переводы
    Lampa.Lang.add({
        ru: {
            [PLUGIN_NAME]: MENU_TITLE,
            [PLUGIN_NAME + '_search']: 'Поиск в ' + MENU_TITLE
        },
        en: {
            [PLUGIN_NAME]: MENU_TITLE,
            [PLUGIN_NAME + '_search']: 'Search in ' + MENU_TITLE
        }
        // Добавьте другие языки при необходимости
    });

    // --- Глобальные переменные плагина ---
    let parsedItems = []; // Для хранения распарсенных данных
    let encoder = $('<div/>'); // Для экранирования HTML

    // --- Компонент страницы плагина ---
    function My4KIptvPage(object) {
        this.activity = object;
        this.html = $('<div></div>');
        this.scroll = new Lampa.Scroll({ mask: true, over: true });
        this.last_focused_card = null;
    }

    My4KIptvPage.prototype.create = function () {
        this.activity.loader(true);
        this.html.append(this.scroll.render());
        this.loadAndParsePlaylist();
        return this.html;
    };

    My4KIptvPage.prototype.loadAndParsePlaylist = function () {
        const network = new Lampa.Reguest();
        network.native(
            PLAYLIST_URL,
            (data) => { // Успех
                if (typeof data === 'string' && data.trim().startsWith('#EXTM3U')) {
                    parsedItems = this.parseM3U(data);
                    this.buildPage();
                } else {
                    console.error('[' + PLUGIN_NAME + '] Полученные данные не являются корректным M3U.');
                    this.showError('Полученные данные не являются корректным M3U плейлистом.');
                }
            },
            (error) => { // Ошибка
                console.error('[' + PLUGIN_NAME + '] Ошибка загрузки плейлиста:', error);
                this.showError('Ошибка загрузки плейлиста: ' + (error.statusText || error.message || 'Неизвестная ошибка'));
            },
            false, // cache
            { dataType: 'text' }
        );
    };

    My4KIptvPage.prototype.parseM3U = function (m3uString) {
        const lines = m3uString.split(/\r?\n/);
        const items = [];
        let currentItem = { title: '', url: '', 'tvg-logo': '' };

        for (let i = 0; i < lines.length; i++) {
            const line = lines[i].trim();
            if (line.startsWith('#EXTINF:')) {
                // Извлекаем название и лого
                const titleMatch = line.match(/,(.*)$/);
                currentItem.title = titleMatch ? titleMatch[1].trim() : 'Без названия';

                const logoMatch = line.match(/tvg-logo="([^"]*)"/i);
                currentItem['tvg-logo'] = logoMatch ? logoMatch[1] : '';
            } else if (line.startsWith('http') && line.includes('://')) {
                currentItem.url = line;
                if (currentItem.url) { // Добавляем только если есть URL
                    items.push({
                        title: currentItem.title || 'Без названия',
                        url: currentItem.url,
                        'tvg-logo': currentItem['tvg-logo'] || ''
                    });
                    // Сброс для следующего элемента
                    currentItem = { title: '', url: '', 'tvg-logo': '' };
                }
            }
        }
        console.log('[' + PLUGIN_NAME + '] Распарсено элементов:', items.length);
        return items;
    };

    My4KIptvPage.prototype.buildPage = function () {
        const cards_container = $('<div class="my-4k-iptv-cards-container"></div>');
        this.scroll.append(cards_container);

        // Добавляем CSS для адаптивной сетки и книжных постеров
        if (!$('#my-4k-iptv-styles').length) {
            $('body').append(`
                <style id="my-4k-iptv-styles">
                    .my-4k-iptv-cards-container {
                        display: flex;
                        flex-wrap: wrap;
                        gap: 1.5em;
                        padding: 1.5em;
                    }
                    /* Телефон: 2 колонки */
                    .my-4k-iptv-card {
                        width: calc(50% - 0.75em); /* 2 колонки */
                        position: relative;
                        border-radius: 0.5em;
                        overflow: hidden;
                        background-color: #2b2b2b;
                        cursor: pointer;
                    }
                    .my-4k-iptv-card__img {
                        width: 100%;
                        /* Книжная ориентация */
                        padding-bottom: 150%; /* Соотношение сторон 2:3 */
                        background-size: cover;
                        background-position: center;
                        background-color: #3a3a3a;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        color: #aaa;
                        font-size: 0.8em;
                        text-align: center;
                        overflow: hidden;
                        text-overflow: ellipsis;
                        padding: 0.5em;
                        box-sizing: border-box;
                    }
                    .my-4k-iptv-card__title {
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
                        .my-4k-iptv-card {
                            width: calc(16.666% - 1.25em); /* 6 колонок */
                        }
                    }
                </style>
            `);
        }

        parsedItems.forEach((item, index) => {
            const imgHtml = item['tvg-logo'] ?
                `<div class="my-4k-iptv-card__img" style="background-image: url('${item['tvg-logo']}');"></div>` :
                `<div class="my-4k-iptv-card__img">${encoder.text(item.title.substring(0, 30) + (item.title.length > 30 ? '...' : '')).html()}</div>`;

            const card = $(`
                <div class="my-4k-iptv-card selector">
                    ${imgHtml}
                    <div class="my-4k-iptv-card__title">${encoder.text(item.title).html()}</div>
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

    My4KIptvPage.prototype.showError = function (message) {
        this.html.empty();
        this.html.append(`<div style="padding: 20px; color: #ff5555;">Ошибка: ${message}</div>`);
        this.activity.loader(false);
        this.activity.toggle();
    };

    My4KIptvPage.prototype.start = function () {
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

    My4KIptvPage.prototype.pause = function () { };
    My4KIptvPage.prototype.stop = function () { };
    My4KIptvPage.prototype.render = function () { return this.html; };
    My4KIptvPage.prototype.destroy = function () {
        this.scroll.destroy();
        this.html.remove();
        parsedItems = []; // Очищаем данные при уничтожении
        // Можно удалить стили, если это был последний экземпляр
        // if ($('.my-4k-iptv-card').length === 0) $('#my-4k-iptv-styles').remove();
    };

    // --- Интеграция в глобальный поиск ---
    function performGlobalSearch(query, callback) {
        // Если данные еще не загружены, загружаем их
        if (parsedItems.length === 0) {
            const network = new Lampa.Reguest();
            network.native(
                PLAYLIST_URL,
                (data) => {
                    if (typeof data === 'string' && data.trim().startsWith('#EXTM3U')) {
                        parsedItems = My4KIptvPage.prototype.parseM3U(data);
                        executeSearch(query, callback);
                    } else {
                        console.warn('[' + PLUGIN_NAME + '] Поиск: Не удалось загрузить плейлист.');
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
            executeSearch(query, callback);
        }
    }

    function executeSearch(query, callback) {
        const searchTerm = query.toLowerCase();
        const results = parsedItems.filter(item =>
            item.title.toLowerCase().includes(searchTerm)
            // Можно добавить поиск по другим полям, если нужно
        ).map(item => ({
            title: item.title,
            // year: 0, // Если есть год
            // genres: ['IPTV'], // Если есть жанры
            // poster: item['tvg-logo'], // Если нужна обложка в результатах поиска
            onEnter: () => {
                Lampa.Player.play({
                    title: item.title,
                    url: item.url
                });
            }
        }));
        callback(results);
    }

    // --- Инициализация плагина ---
    function initPlugin() {
        console.log('[' + PLUGIN_NAME + '] Plugin initialized');

        // 1. Регистрируем компонент страницы
        Lampa.Component.add(plugin.component, My4KIptvPage);

        // 2. Добавляем пункт в главное меню
        Lampa.Manifest.plugins.push({
            name: plugin.component,
            title: Lampa.Lang.translate(plugin.component), // Использует перевод
            icon: plugin.icon,
            page: () => {
                Lampa.Activity.push({
                    component: plugin.component
                    // Можно добавить другие параметры активности
                });
            }
        });

        // 3. Интегрируем в глобальный поиск
        Lampa.Search.addSource({
            title: Lampa.Lang.translate(plugin.component + '_search'), // Использует перевод
            search: (query, call) => performGlobalSearch(query, call)
        });
    }

    // --- Запуск после загрузки Lampa ---
    if (window.Lampa) {
        initPlugin();
    } else {
        window.addEventListener('load', initPlugin);
    }

})();
