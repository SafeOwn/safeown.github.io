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
        // Простая иконка Play
        icon: "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 24\" fill=\"currentColor\"><path d=\"M8 5v14l11-7z\"/></svg>",
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
        this.html = $('<div class="' + PLUGIN_COMPONENT + '-plugin-container"></div>'); // Добавляем класс-обертку
        this.scroll = new Lampa.Scroll({ mask: true, over: true });
        this.last_focused_card = null;
        this.itemsRendered = 0; // Счетчик отрендеренных карточек
        this.totalItems = 0; // Общее количество карточек
    }

    PluginPage.prototype.create = function () {
        this.activity.loader(true);
        // Очищаем контейнер и добавляем скролл
        this.html.empty().append(this.scroll.render());
        this.loadAndParsePlaylist();
        return this.html;
    };

    PluginPage.prototype.loadAndParsePlaylist = function () {
        const network = new Lampa.Reguest();
        console.log('[' + PLUGIN_COMPONENT + '] Загрузка плейлиста:', HARDCODED_URL);
        network.native(
            HARDCODED_URL,
            (data) => { // Успех
                if (typeof data === 'string' && data.trim().startsWith('#EXTM3U')) {
                    parsedItems = this.parseM3U(data); // Используем метод компонента
                    console.log('[' + PLUGIN_COMPONENT + '] Плейлист загружен и распарсен. Элементов:', parsedItems.length);
                    if (parsedItems.length > 0) {
                         this.buildPage();
                    } else {
                         this.showError('Плейлист пуст или не содержит поддерживаемых записей.');
                    }
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
        return items;
    };


    PluginPage.prototype.buildPage = function () {
        const cards_container = $('<div class="' + PLUGIN_COMPONENT + '-cards-container"></div>');
        this.scroll.append(cards_container);

        // Добавляем CSS для адаптивной сетки и книжных постеров
        const styleId = PLUGIN_COMPONENT + '-styles';
        if (!$('#' + styleId).length) {
            $('body').append(`
                <style id="${styleId}">
                    .${PLUGIN_COMPONENT}-plugin-container {
                        /* Чтобы скролл работал правильно */
                        height: 100%;
                    }
                    .${PLUGIN_COMPONENT}-cards-container {
                        display: flex;
                        flex-wrap: wrap;
                        /* gap заменен на margin для лучшей совместимости */
                        /* gap: 1.5em; */
                        padding: 1.5em;
                        /* Убираем стандартные margin у первых/последних элементов */
                        margin: 0;
                    }
                    /* Телефон: 2 колонки */
                    .${PLUGIN_COMPONENT}-card {
                        /* Ширина карточки с учетом отступов */
                        width: calc(50% - 0.75em); /* 2 колонки: (100% - 1.5em отступ) / 2 */
                        margin: 0 1.5em 1.5em 0; /* margin-right и margin-bottom */
                        position: relative;
                        border-radius: 0.5em;
                        overflow: hidden;
                        background-color: #2b2b2b;
                        cursor: pointer;
                        display: flex;
                        flex-direction: column;
                        /* Устанавливаем минимальную высоту, чтобы избежать "полосок" */
                        min-height: 200px; /* Примерная минимальная высота */
                    }
                    /* Убираем правый margin у последнего элемента в строке */
                    .${PLUGIN_COMPONENT}-card:nth-child(2n) {
                        margin-right: 0;
                    }

                    .${PLUGIN_COMPONENT}-card__img-container {
                        /* Контейнер для изображения */
                        width: 100%;
                        /* Высота будет определяться содержимым или flex */
                        flex-grow: 1; /* Занимает всё доступное пространство по высоте внутри .my-4k-iptv-card */
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        background-color: #3a3a3a;
                        overflow: hidden;
                        /* Устанавливаем соотношение сторон 2:3 (портрет) */
                        aspect-ratio: 2 / 3; /* Ширина : Высота */
                        /* Для браузеров, не поддерживающих aspect-ratio */
                        padding-top: 150%; /* 3/2 * 100% = 150% */
                        height: 0;
                    }
                    .${PLUGIN_COMPONENT}-card__img {
                        /* Само изображение */
                        width: 100%;
                        height: 100%;
                        object-fit: cover; /* Масштабирует изображение, обрезая края, чтобы заполнить контейнер */
                        display: block;
                        position: absolute;
                        top: 0;
                        left: 0;
                    }
                    .${PLUGIN_COMPONENT}-card__img-placeholder {
                        /* Плейсхолдер, если изображения нет */
                        color: #aaa;
                        font-size: 0.8em;
                        text-align: center;
                        padding: 0.5em;
                        box-sizing: border-box;
                        position: absolute; /* Позиционируем абсолютно внутри контейнера */
                        top: 0;
                        left: 0;
                        width: 100%;
                        height: 100%;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                    }
                    .${PLUGIN_COMPONENT}-card__title {
                        padding: 0.5em;
                        font-size: 1em;
                        white-space: nowrap;
                        overflow: hidden;
                        text-overflow: ellipsis;
                        background-color: rgba(0,0,0,0.5);
                        /* Располагается внизу, вне контейнера изображения */
                        margin: 0; /* Убираем возможные margin от заголовка */
                    }

                    /* Телевизор: 6 колонок */
                    @media screen and (min-width: 768px) {
                        .${PLUGIN_COMPONENT}-card {
                            width: calc(16.666% - 1.25em); /* 6 колонок: (100% - 5 * 1.5em) / 6 = 16.666% - 1.25em */
                            margin: 0 1.5em 1.5em 0;
                        }
                        /* Убираем правый margin у последнего элемента в строке (6n) */
                        .${PLUGIN_COMPONENT}-card:nth-child(6n) {
                            margin-right: 0;
                        }
                    }
                </style>
            `);
        }

        this.totalItems = parsedItems.length;
        this.itemsRendered = 0;

        parsedItems.forEach((item, index) => {
            let imgContent;
            if (item['tvg-logo']) {
                // Если есть лого, используем <img>
                // Используем loading="lazy" для оптимизации
                imgContent = `
                    <div class="${PLUGIN_COMPONENT}-card__img-container">
                        <img class="${PLUGIN_COMPONENT}-card__img" src="${item['tvg-logo']}" loading="lazy" alt="${encoder.text(item.title).html()}">
                        <div class="${PLUGIN_COMPONENT}-card__img-placeholder" style="display:none;">${encoder.text(item.title.substring(0, 30) + (item.title.length > 30 ? '...' : '')).html()}</div>
                    </div>
                `;
            } else {
                // Если лого нет, показываем название как плейсхолдер
                imgContent = `
                    <div class="${PLUGIN_COMPONENT}-card__img-container">
                        <div class="${PLUGIN_COMPONENT}-card__img-placeholder">${encoder.text(item.title.substring(0, 30) + (item.title.length > 30 ? '...' : '')).html()}</div>
                    </div>
                `;
            }

            const card = $(`
                <div class="${PLUGIN_COMPONENT}-card selector" data-item-index="${index}">
                    ${imgContent}
                    <div class="${PLUGIN_COMPONENT}-card__title">${encoder.text(item.title).html()}</div>
                </div>
            `);

            // Обработчик загрузки изображения
            const imgElement = card.find(`.${PLUGIN_COMPONENT}-card__img`)[0];
            if (imgElement) {
                imgElement.onload = () => {
                    // Скрываем плейсхолдер, если он есть
                    const placeholder = card.find(`.${PLUGIN_COMPONENT}-card__img-placeholder`);
                    if (placeholder.length) {
                         placeholder.hide();
                    }
                    this.onItemRendered();
                };
                imgElement.onerror = () => {
                    // Показываем плейсхолдер, если изображение не загрузилось
                    const placeholder = card.find(`.${PLUGIN_COMPONENT}-card__img-placeholder`);
                    if (placeholder.length) {
                         placeholder.show();
                    }
                    // Скрываем img тег, если он есть
                    const img = card.find(`.${PLUGIN_COMPONENT}-card__img`);
                    if (img.length) {
                         img.hide();
                    }
                    this.onItemRendered();
                };
            } else {
                // Если изображения нет с самого начала (плейсхолдер)
                this.onItemRendered();
            }

            card.on('hover:enter', () => {
                console.log('[' + PLUGIN_COMPONENT + '] Воспроизведение:', item.title);
                Lampa.Player.play({
                    title: item.title,
                    url: item.url
                });
            });

            cards_container.append(card);
        });

        // Если список пуст, сразу скрываем лоадер
        if (this.totalItems === 0) {
             this.onAllItemsRendered();
        }
    };

    PluginPage.prototype.onItemRendered = function() {
        this.itemsRendered++;
        if (this.itemsRendered >= this.totalItems) {
            this.onAllItemsRendered();
        }
    };

    PluginPage.prototype.onAllItemsRendered = function() {
        console.log('[' + PLUGIN_COMPONENT + '] Все карточки отрендерены.');
        this.activity.loader(false);
        this.activity.toggle(); // Активируем активность
    };

    PluginPage.prototype.showError = function (message) {
        this.html.empty().append(`<div style="padding: 20px; color: #ff5555;">Ошибка: ${message}</div>`);
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
        console.log('[' + PLUGIN_COMPONENT + '] Уничтожение компонента.');
        this.scroll.destroy();
        this.html.remove();
        // Удаляем стили при уничтожении, если это последний экземпляр
        const styleId = PLUGIN_COMPONENT + '-styles';
        // Проверяем, есть ли еще активные карточки этого плагина на странице
        if ($('.' + PLUGIN_COMPONENT + '-card').length === 0) {
             $('#' + styleId).remove();
             console.log('[' + PLUGIN_COMPONENT + '] Стили удалены.');
        }
        // Не очищаем parsedItems здесь, так как они нужны для поиска
    };

    // --- Интеграция в глобальный поиск ---
    // Выносим parseM3U в отдельную функцию верхнего уровня для поиска
    function parseM3UStandalone(m3uString) {
         // Копируем логику из PluginPage.prototype.parseM3U
         const lines = m3uString.split(/\r?\n/);
         const items = [];
         let currentItem = { title: '', url: '', 'tvg-logo': '' };

         for (let i = 0; i < lines.length; i++) {
             const line = lines[i].trim();
             if (line.startsWith('#EXTINF:')) {
                 const titleMatch = line.match(/,(.*)$/);
                 currentItem.title = titleMatch ? titleMatch[1].trim() : 'Без названия';
                 const logoMatch = line.match(/tvg-logo="([^"]*)"/i);
                 currentItem['tvg-logo'] = logoMatch ? logoMatch[1] : '';
             } else if (line.startsWith('http') && line.includes('://')) {
                 currentItem.url = line;
                 if (currentItem.url) {
                     items.push({
                         title: currentItem.title || 'Без названия',
                         url: currentItem.url,
                         'tvg-logo': currentItem['tvg-logo'] || ''
                     });
                     currentItem = { title: '', url: '', 'tvg-logo': '' };
                 }
             }
         }
         return items;
    }

    function performGlobalSearch(query, callback) {
        console.log('[' + PLUGIN_COMPONENT + '] Глобальный поиск по запросу:', query);
        const searchTerm = query.toLowerCase().trim();
        if (!searchTerm) {
             callback([]);
             return;
        }
        // Если данные еще не загружены, загружаем их
        if (parsedItems.length === 0) {
            console.log('[' + PLUGIN_COMPONENT + '] Данные плейлиста не в кэше, загружаем для поиска...');
            const network = new Lampa.Reguest();
            network.native(
                HARDCODED_URL,
                (data) => {
                    if (typeof data === 'string' && data.trim().startsWith('#EXTM3U')) {
                        parsedItems = parseM3UStandalone(data); // Используем standalone функцию
                        console.log('[' + PLUGIN_COMPONENT + '] Плейлист для поиска загружен. Элементов:', parsedItems.length);
                        executeSearch(searchTerm, callback);
                    } else {
                        console.warn('[' + PLUGIN_COMPONENT + '] Поиск: Полученные данные не являются корректным M3U.');
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
            console.log('[' + PLUGIN_COMPONENT + '] Используем кэшированные данные для поиска.');
            executeSearch(searchTerm, callback);
        }
    }

    function executeSearch(searchTerm, callback) {
        const results = parsedItems.filter(item =>
            item.title.toLowerCase().includes(searchTerm)
        ).map(item => ({
            title: item.title,
            // year: 0,
            // genres: ['IPTV'],
            // poster: item['tvg-logo'], // Можно добавить, если нужно отображать постер в результатах поиска
            onEnter: () => {
                console.log('[' + PLUGIN_COMPONENT + '] Воспроизведение из поиска:', item.title);
                Lampa.Player.play({
                    title: item.title,
                    url: item.url
                });
            }
        }));
        console.log('[' + PLUGIN_COMPONENT + '] Поиск завершен. Найдено:', results.length);
        callback(results);
    }

    // --- Инициализация плагина ---
    function initPlugin() {
        console.log('[' + PLUGIN_COMPONENT + '] Плагин инициализирован.');

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
            console.log('[' + PLUGIN_COMPONENT + '] Открытие страницы плагина из меню.');
            const activity = {
                component: plugin.component,
                // Можно добавить другие параметры активности при необходимости
            };
            Lampa.Activity.push(activity);
        });

        // 3. Добавляем пункт меню в главное меню при запуске приложения
        function pluginStart() {
            if (!!window['plugin_' + plugin.component + '_ready']) {
                 console.log('[' + PLUGIN_COMPONENT + '] Плагин уже запущен.');
                 return;
            }
            window['plugin_' + plugin.component + '_ready'] = true;
            var menu = $('.menu .menu__list').eq(0);
            menu.append(menuEl);
            console.log('[' + PLUGIN_COMPONENT + '] Пункт меню добавлен.');
        }

        if (!!window.appready) {
            console.log('[' + PLUGIN_COMPONENT + '] appready уже true, вызываем pluginStart.');
            pluginStart();
        } else {
            console.log('[' + PLUGIN_COMPONENT + '] Ждем событие appready.');
            Lampa.Listener.follow('app', function(e){
                if (e.type === 'ready') {
                     console.log('[' + PLUGIN_COMPONENT + '] Получено событие appready, вызываем pluginStart.');
                     pluginStart();
                }
            });
        }

        // 4. Интегрируем в глобальный поиск
        console.log('[' + PLUGIN_COMPONENT + '] Регистрация в глобальном поиске.');
        Lampa.Search.addSource({
            title: Lampa.Lang.translate(plugin.component + '_search'),
            search: (query, call) => performGlobalSearch(query, call)
        });
    }

    // --- Запуск после загрузки Lampa ---
    if (window.Lampa) {
        console.log('[' + PLUGIN_COMPONENT + '] Lampa уже загружена, инициализируем плагин.');
        initPlugin();
    } else {
        console.log('[' + PLUGIN_COMPONENT + '] Ждем загрузку Lampa.');
        window.addEventListener('load', function(){
             console.log('[' + PLUGIN_COMPONENT + '] Событие load, инициализируем плагин.');
             initPlugin();
        });
    }

})();
