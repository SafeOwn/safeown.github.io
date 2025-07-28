// plugins/4k_iptv/index.js

(function () {
    'use strict';

    // --- ЖЕСТКО ЗАДАННЫЕ НАСТРОЙКИ ---
    const HARDCODED_URL = 'https://safeown.github.io/plvideo_4k_final_with_posters.m3u'; // Ваш URL
    const HARDCODED_NAME = '4kTV'; // Ваше имя в меню
    const PLUGIN_COMPONENT = '4k_iptv'; // Внутреннее имя компонента
    // -------------------------------

    // --- Основной объект плагина ---
    const plugin = {
        component: PLUGIN_COMPONENT,
        // Иконка из вашего примера
        icon: "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"244\" height=\"260\" viewBox=\"0 0 244 260\" fill=\"currentColor\"><g transform=\"translate(0.000000,260.000000) scale(0.100000,-0.100000)\" fill=\"currentColor\" stroke=\"none\"><path d=\"M432 2570 c-162 -17 -301 -130 -347 -281 -39 -132 -39 -942 0 -1079 21 -72 72 -146 132 -191 93 -70 150 -89 302 -98 l103 -6 -82 -100 c-93 -114 -102 -128 -94 -149 8 -21 38 -28 104 -24 l54 3 111 132 110 132 401 0 400 1 75 -87 c40 -49 94 -109 118 -135 l44 -48 66 0 c67 0 91 10 91 38 0 7 -38 62 -85 122 -47 60 -85 111 -85 114 0 3 35 6 78 6 150 0 268 45 357 134 62 62 93 124 106 208 15 104 22 668 11 846 -10 151 -13 169 -42 230 -61 131 -187 216 -346 232 -105 11 -1476 11 -1582 0z m1370 -141 c230 -12 255 -16 322 -60 62 -41 94 -91 107 -165 27 -163 19 -829 -12 -946 -15 -59 -67 -120 -130 -151 -55 -28 -61 -28 -305 -37 -574 -21 -1321 -5 -1400 29 -49 22 -111 84 -131 130 -22 51 -33 227 -33 526 0 296 12 481 35 525 24 46 100 106 157 123 105 32 970 48 1390 26z\"/><path d=\"M569 2231 l-24 -19 -3 -476 c-3 -525 -3 -519 59 -551 78 -41 1179 -42 1256 -2 66 35 63 13 63 540 l0 478 -25 24 c-23 24 -30 25 -142 25 -99 0 -123 -3 -148 -19 -16 -10 -100 -93 -185 -184 -85 -91 -166 -169 -179 -173 -22 -6 -44 13 -210 185 l-186 191 -126 0 c-110 0 -130 -3 -150 -19z m323 -308 c62 -65 153 -159 202 -210 99 -103 126 -116 180 -86 18 10 118 107 222 216 194 202 220 221 244 178 14 -27 14 -615 0 -642 -10 -18 -27 -19 -505 -19 -435 0 -495 2 -509 16 -14 13 -16 56 -16 320 0 191 4 313 10 325 23 41 54 23 172 -98z m185 -679 c12 -19 11 -24 -6 -45 -16 -21 -22 -22 -45 -11 -17 8 -26 19 -26 35 0 48 50 62 77 21z m181 14 c39 -39 -17 -100 -58 -63 -24 22 -25 33 -3 57 19 21 44 23 61 6z m200 0 c39 -39 -17 -100 -58 -63 -25 22 -26 51 -2 64 23 14 45 14 60 -1z\"/><path d=\"M198 250 l-3 -230 50 0 50 0 -2 157 c-1 87 1 152 4 145 3 -8 29 -77 58 -155 l53 -142 43 0 44 0 63 160 63 160 -6 -162 -6 -163 50 0 51 0 0 230 0 231 -67 -3 -67 -3 -34 -90 c-19 -49 -45 -120 -60 -158 -14 -37 -28 -64 -31 -61 -3 3 -31 74 -61 157 l-55 152 -67 3 -67 3 -3 -231z\"/><path d=\"M1470 440 l0 -40 80 0 81 0 -3 -190 -3 -190 48 0 47 0 0 190 0 190 75 0 75 0 0 40 0 40 -200 0 -200 0 0 -40z\"/><path d=\"M1892 468 c3 -7 40 -111 83 -231 l78 -217 57 0 57 0 43 118 c105 294 120 335 120 338 0 2 -22 4 -49 4 l-50 0 -19 -52 c-11 -29 -37 -108 -58 -175 -22 -68 -41 -123 -44 -123 -3 0 -32 79 -63 175 l-58 175 -51 0 c-36 0 -49 -4 -46 -12z\"/><path d=\"M850 344 c-32 -14 -69 -49 -70 -66 0 -4 17 -12 37 -17 30 -9 40 -8 55 6 28 25 87 22 109 -6 34 -41 26 -48 -65 -53 -92 -5 -130 -21 -147 -65 -12 -32 3 -83 32 -108 30 -28 115 -31 162 -7 29 16 37 17 37 6 0 -10 13 -14 45 -14 l45 0 0 115 c0 144 -12 178 -72 205 -51 23 -120 25 -168 4z m143 -191 c11 -19 -16 -55 -50 -69 -43 -18 -83 -6 -83 25 0 27 19 39 70 44 25 2 48 4 52 5 4 1 9 -1 11 -5z\"/><path d=\"M1156 313 c15 -21 43 -58 61 -82 l33 -44 -27 -36 c-15 -20 -42 -56 -60 -80 -18 -24 -33 -47 -33 -50 0 -3 24 -5 53 -3 50 3 55 6 82 48 17 24 33 44 36 44 3 0 20 -20 38 -44 31 -42 37 -44 87 -48 30 -1 54 -1 54 1 0 2 -24 36 -53 75 -29 39 -56 76 -60 82 -3 6 21 46 53 90 l59 79 -50 3 c-43 3 -53 0 -68 -20 -10 -13 -27 -34 -38 -47 l-20 -24 -33 47 c-33 45 -34 46 -88 46 l-54 0 28 -37z\"/></g></svg>",
        name: HARDCODED_NAME
    };

    // --- Глобальные переменные ---
    let parsedItems = []; // Для хранения распарсенных данных
    let encoder = $('<div/>'); // Для экранирования HTML

    // --- Добавляем переводы ---
    Lampa.Lang.add({
        ru: {
            [PLUGIN_COMPONENT]: HARDCODED_NAME,
            [PLUGIN_COMPONENT + '_search']: 'Поиск в ' + HARDCODED_NAME
        },
        en: {
            [PLUGIN_COMPONENT]: HARDCODED_NAME,
            [PLUGIN_COMPONENT + '_search']: 'Search in ' + HARDCODED_NAME
        }
    });

    // --- Компонент страницы плагина ---
    function PluginPage(object) {
        this.activity = object;
        this.html = $('<div></div>');
        this.scroll = new Lampa.Scroll({ mask: true, over: true });
        this.last_focused_card = null;
    }

    PluginPage.prototype.create = function () {
        this.activity.loader(true);
        this.html.append(this.scroll.render());
        this.loadAndParsePlaylist();
        return this.html;
    };

    PluginPage.prototype.loadAndParsePlaylist = function () {
        const network = new Lampa.Reguest();
        network.native(
            HARDCODED_URL,
            (data) => { // Успех
                if (typeof data === 'string' && data.trim().startsWith('#EXTM3U')) {
                    parsedItems = this.parseM3U(data);
                    this.buildPage();
                } else {
                    console.error('[' + PLUGIN_COMPONENT + '] Полученные данные не являются корректным M3U.');
                    this.showError('Полученные данные не являются корректным M3U плейлистом.');
                }
            },
            (error) => { // Ошибка
                console.error('[' + PLUGIN_COMPONENT + '] Ошибка загрузки плейлиста:', error);
                this.showError('Ошибка загрузки плейлиста: ' + (error.statusText || error.message || 'Неизвестная ошибка'));
            },
            false, // cache
            { dataType: 'text' }
        );
    };

    PluginPage.prototype.parseM3U = function (m3uString) {
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
        console.log('[' + PLUGIN_COMPONENT + '] Распарсено элементов:', items.length);
        return items;
    };

    PluginPage.prototype.buildPage = function () {
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

    PluginPage.prototype.showError = function (message) {
        this.html.empty();
        this.html.append(`<div style="padding: 20px; color: #ff5555;">Ошибка: ${message}</div>`);
        this.activity.loader(false);
        this.activity.toggle();
    };

    PluginPage.prototype.start = function () {
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

    PluginPage.prototype.pause = function () { };
    PluginPage.prototype.stop = function () { };
    PluginPage.prototype.render = function () { return this.html; };
    PluginPage.prototype.destroy = function () {
        this.scroll.destroy();
        this.html.remove();
        parsedItems = []; // Очищаем данные при уничтожении
    };

    // --- Интеграция в глобальный поиск ---
    function performGlobalSearch(query, callback) {
        // Если данные еще не загружены, загружаем их
        if (parsedItems.length === 0) {
            const network = new Lampa.Reguest();
            network.native(
                HARDCODED_URL,
                (data) => {
                    if (typeof data === 'string' && data.trim().startsWith('#EXTM3U')) {
                        parsedItems = PluginPage.prototype.parseM3U(data);
                        executeSearch(query, callback);
                    } else {
                        console.warn('[' + PLUGIN_COMPONENT + '] Поиск: Не удалось загрузить плейлист.');
                        callback([]);
                    }
                },
                (error) => {
                    console.error('[' + PLUGIN_COMPONENT + '] Поиск: Ошибка загрузки плейлиста:', error);
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
        ).map(item => ({
            title: item.title,
            // year: 0,
            // genres: ['IPTV'],
            // poster: item['tvg-logo'],
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
        console.log('[' + PLUGIN_COMPONENT + '] Plugin initialized');

        // 1. Регистрируем компонент страницы
        Lampa.Component.add(plugin.component, PluginPage);

        // 2. Добавляем пункт в главное меню (автоматически, без настроек)
        const menuEl = $('<li class="menu__item selector js-' + plugin.component + '-menu0">'
                    + '<div class="menu__ico">' + plugin.icon + '</div>'
                    + '<div class="menu__text js-' + plugin.component + '-menu0-title">'
                        + encoder.text(plugin.name).html()
                    + '</div>'
                + '</li>')
        .on('hover:enter', function(){
            const activity = {
                component: plugin.component,
                // Можно добавить другие параметры активности при необходимости
            };
            Lampa.Activity.push(activity);
        });

        // 3. Добавляем пункт меню в главное меню при запуске приложения
        function pluginStart() {
            if (!!window['plugin_' + plugin.component + '_ready']) return;
            window['plugin_' + plugin.component + '_ready'] = true;
            var menu = $('.menu .menu__list').eq(0);
            menu.append(menuEl);
            console.log('[' + PLUGIN_COMPONENT + '] Menu item added.');
        }

        if (!!window.appready) {
            pluginStart();
        } else {
            Lampa.Listener.follow('app', function(e){
                if (e.type === 'ready') pluginStart();
            });
        }

        // 4. Интегрируем в глобальный поиск
        Lampa.Search.addSource({
            title: Lampa.Lang.translate(plugin.component + '_search'),
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
