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
            [PLUGIN_COMPONENT]: HARDCODED_NAME
            // [PLUGIN_COMPONENT + '_search']: 'Поиск в ' + HARDCODED_NAME // Убрано
        },
        en: {
            [PLUGIN_COMPONENT]: HARDCODED_NAME
            // [PLUGIN_COMPONENT + '_search']: 'Search in ' + HARDCODED_NAME // Убрано
        }
    });

    // --- Компонент страницы плагина ---
    function PluginPage(object) {
        this.activity = object;
        this.html = $('<div class="' + PLUGIN_COMPONENT + '-plugin-container"></div>'); // Добавляем класс-обертку
        this.scroll = new Lampa.Scroll({ mask: true, over: true });
        this.last_focused_card = null;
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

        // Добавляем CSS для адаптивной сетки и карточек фиксированного размера
        const styleId = PLUGIN_COMPONENT + '-styles';
        if (!$('#' + styleId).length) {
            $('body').append(`
                <style id="${styleId}">
                    .${PLUGIN_COMPONENT}-plugin-container {
                        height: 100%;
                    }
                    .${PLUGIN_COMPONENT}-cards-container {
                        display: flex;
                        flex-wrap: wrap;
                        padding: 1.5em;
                        gap: 1.5em; /* Расстояние между карточками */
                    }
                    /* Телефон: 2 колонки */
                    .${PLUGIN_COMPONENT}-card {
                        /* Ширина карточки */
                        width: calc(50% - 0.75em); /* 2 колонки: (100% - 1.5em отступ) / 2 */
                        /* Фиксированная высота карточки */
                        height: 250px; /* <--- Установите желаемую высоту карточки здесь */

                        position: relative;
                        border-radius: 0.5em;
                        overflow: hidden;
                        background-color: #2b2b2b;
                        cursor: pointer;
                        display: flex;
                        flex-direction: column;
                    }

                    .${PLUGIN_COMPONENT}-card__img-container {
                        /* Контейнер для изображения или плейсхолдера */
                        width: 100%;
                        flex-grow: 1; /* Занимает всё доступное пространство по высоте внутри .card */
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        background-color: #3a3a3a;
                        overflow: hidden;
                        position: relative;
                    }
                    .${PLUGIN_COMPONENT}-card__img {
                        /* Само изображение */
                        width: 100%;
                        height: 100%;
                        object-fit: cover; /* Масштабирует изображение, обрезая края, чтобы заполнить контейнер */
                        display: block;
                    }
                    .${PLUGIN_COMPONENT}-card__img-placeholder {
                        /* Плейсхолдер, если изображения нет */
                        color: #aaa;
                        font-size: 0.9em;
                        text-align: center;
                        padding: 0.5em;
                        box-sizing: border-box;
                        /* position: absolute; Убираем absolute для простоты */
                        /* top: 0; */
                        /* left: 0; */
                        /* width: 100%; */
                        /* height: 100%; */
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        /* word-break: break-word; */
                        /* padding: 10px; */
                    }
                    .${PLUGIN_COMPONENT}-card__title {
                        padding: 0.5em;
                        font-size: 1em;
                        white-space: nowrap;
                        overflow: hidden;
                        text-overflow: ellipsis;
                        background-color: rgba(0,0,0,0.5);
                        margin: 0; /* Убираем возможные margin от заголовка */
                        /* Минимальная высота для заголовка, если нужно */
                        /* min-height: 1.5em; */
                    }

                    /* Телевизор: 6 колонок */
                    @media screen and (min-width: 768px) {
                        .${PLUGIN_COMPONENT}-card {
                            /* Ширина карточки для 6 колонок */
                            width: calc(16.666% - 1.25em); /* 6 колонок: (100% - 5 * 1.5em) / 6 = 16.666% - 1.25em */
                            /* Можно также изменить высоту для ТВ, если нужно */
                            /* height: 300px; */
                        }
                    }
                </style>
            `);
        }

        parsedItems.forEach((item, index) => {
            let imgContent;
            if (item['tvg-logo']) {
                // Если есть лого, используем <img>
                imgContent = `
                    <div class="${PLUGIN_COMPONENT}-card__img-container">
                        <img class="${PLUGIN_COMPONENT}-card__img" src="${item['tvg-logo']}" loading="lazy" alt="${encoder.text(item.title).html()}">
                    </div>
                `;
            } else {
                // Если лого нет, показываем название как плейсхолдер
                // Ограничиваем длину текста плейсхолдера
                const placeholderText = item.title.substring(0, 50) + (item.title.length > 50 ? '...' : '');
                imgContent = `
                    <div class="${PLUGIN_COMPONENT}-card__img-container">
                        <div class="${PLUGIN_COMPONENT}-card__img-placeholder">${encoder.text(placeholderText).html()}</div>
                    </div>
                `;
            }

            const card = $(`
                <div class="${PLUGIN_COMPONENT}-card selector" data-item-index="${index}">
                    ${imgContent}
                    <div class="${PLUGIN_COMPONENT}-card__title">${encoder.text(item.title).html()}</div>
                </div>
            `);

            card.on('hover:enter', () => {
                console.log('[' + PLUGIN_COMPONENT + '] Воспроизведение:', item.title);
                Lampa.Player.play({
                    title: item.title,
                    url: item.url
                });
            });

            // Добавляем обработчики ошибок изображения прямо здесь
            const imgElement = card.find(`.${PLUGIN_COMPONENT}-card__img`)[0];
            if (imgElement) {
                imgElement.onerror = () => {
                    console.log('[' + PLUGIN_COMPONENT + '] Ошибка загрузки изображения для:', item.title);
                    // При ошибке загрузки показываем плейсхолдер
                    const container = card.find(`.${PLUGIN_COMPONENT}-card__img-container`);
                    container.empty().append(`<div class="${PLUGIN_COMPONENT}-card__img-placeholder">${encoder.text(item.title.substring(0, 50) + (item.title.length > 50 ? '...' : '')).html()}</div>`);
                };
            }

            cards_container.append(card);
        });

        this.activity.loader(false);
        this.activity.toggle();
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
        // if ($('.' + PLUGIN_COMPONENT + '-card').length === 0) { // Опционально
             $('#' + styleId).remove();
             console.log('[' + PLUGIN_COMPONENT + '] Стили удалены.');
        // }
        // Не очищаем parsedItems
    };

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

        // 4. Интеграция в глобальный поиск УБРАНА
        // console.log('[' + PLUGIN_COMPONENT + '] Регистрация в глобальном поиске УБРАНА.');
        // Lampa.Search.addSource({...});
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
