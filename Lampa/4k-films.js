/*
// Плагин IPTV для Lampa (исправленная версия)
// Загружает M3U плейлист и отображает каналы с обложками
// Адаптирует количество колонок под тип устройства (телефон/планшет/телевизор)
*/
;(function () {
    'use strict';

    // Основная конфигурация плагина
    var plugin = {
        component: 'my_iptv_channels', // Уникальный идентификатор компонента
        icon: "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"24\" height=\"24\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\" class=\"feather feather-tv\"><rect x=\"2\" y=\"7\" width=\"20\" height=\"15\" rx=\"2\" ry=\"2\"></rect><polyline points=\"17 2 12 7 7 2\"></polyline></svg>",
        name: 'My IPTV Channels'
    };

    // Глобальные переменные
    var lists = []; // Хранит данные о плейлистах
    var curListId = -1; // ID текущего плейлиста
    var defaultGroup = 'Все каналы'; // Группа по умолчанию
    var catalog = {}; // Каталог каналов по группам
    var listCfg = {}; // Конфигурация плейлиста
    var UID = ''; // Уникальный идентификатор пользователя

    // Элементы интерфейса
    var encoder = $('<div/>'); // Для экранирования HTML

    /**
     * Проверяет, является ли плейлист плагина
     * @param {Array} playlist - Плейлист
     * @returns {boolean}
     */
    function isPluginPlaylist(playlist) {
        return !(!playlist.length || !playlist[0].tv || !playlist[0].plugin || playlist[0].plugin !== plugin.component);
    }

    /**
     * Генерирует уникальную подпись для строки
     * @param {string} string - Входная строка
     * @returns {string}
     */
    function generateSigForString(string) {
        var sigTime = Math.floor(Date.now() / 1000);
        return sigTime.toString(36) + ':' + Lampa.Utils.hash((string || '') + sigTime + UID).toString(36);
    }

    /**
     * Подготавливает URL, заменяя переменные
     * @param {string} url - Исходный URL
     * @returns {string}
     */
    function prepareUrl(url) {
        var timestamp = Math.floor(Date.now() / 1000);
        var replacements = {
            '${timestamp}': timestamp,
            '${uid}': UID,
            '${token}': generateSigForString(Lampa.Storage.field('account_email').toLowerCase()),
            // Можно добавить другие переменные при необходимости
        };

        for (var key in replacements) {
            url = url.replace(new RegExp(key.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'g'), replacements[key]);
        }
        return url;
    }

    /**
     * Получает значение из хранилища
     * @param {string} name - Имя ключа
     * @param {*} defaultValue - Значение по умолчанию
     * @returns {*}
     */
    function getStorage(name, defaultValue) {
        return Lampa.Storage.get(plugin.component + '_' + name, defaultValue);
    }

    /**
     * Сохраняет значение в хранилище
     * @param {string} name - Имя ключа
     * @param {*} val - Значение
     * @param {boolean} noListen - Не уведомлять слушателей
     * @returns {*}
     */
    function setStorage(name, val, noListen) {
        return Lampa.Storage.set(plugin.component + '_' + name, val, noListen);
    }

    /**
     * Получает значение настройки
     * @param {string} name - Имя настройки
     * @returns {*}
     */
    function getSettings(name) {
        return Lampa.Storage.field(plugin.component + '_' + name);
    }

    /**
     * Добавляет параметр в настройки
     * @param {string} type - Тип параметра (input, title и т.д.)
     * @param {Object} param - Параметры
     */
    function addSettings(type, param) {
        var data = {
            component: plugin.component,
            param: {
                name: plugin.component + '_' + param.name,
                type: type,
                values: param.values || '',
                placeholder: param.placeholder || '',
                default: (typeof param.default === 'undefined') ? '' : param.default
            },
            field: {
                name: param.title || param.name || ''
            }
        };

        if (param.description) data.field.description = param.description;
        if (param.onChange) data.onChange = param.onChange;

        Lampa.SettingsApi.addParam(data);
    }

    /**
     * Конфигурирует плейлист в настройках
     * @param {number} i - Индекс плейлиста
     * @returns {number}
     */
    function configurePlaylist(i) {
        addSettings('title', { title: 'Плейлист ' + (i + 1) });

        var defName = 'IPTV Плейлист ' + (i + 1);
        var activity = {
            id: i,
            url: '',
            title: defName,
            groups: [],
            currentGroup: getStorage('last_catalog_' + i, defaultGroup),
            component: plugin.component,
            page: 1
        };

        if (activity.currentGroup === '!!') activity.currentGroup = '';

        addSettings('input', {
            title: 'Название плейлиста',
            name: 'list_name_' + i,
            default: defName,
            placeholder: defName,
            description: 'Название плейлиста в меню',
            onChange: function (newVal) {
                var title = !newVal ? defName : newVal;
                $('.js-' + plugin.component + '-menu' + i + '-title').text(title);
                activity.title = title;
                if (lists[i]) lists[i].activity.title = title; // Обновляем в списке
            }
        });

        addSettings('input', {
            title: 'URL плейлиста',
            name: 'list_url_' + i,
            default: 'https://safeown.github.io/plvideo_4k_final.m3u',
            placeholder: 'https://example.com/playlist.m3u',
            description: 'Ссылка на .m3u или .m3u8 файл',
            onChange: function (url) {
                if (url === (lists[i] ? lists[i].activity.url : '')) return;
                if (activity.id === curListId) {
                    catalog = {};
                    curListId = -1;
                }
                var menuEl = lists[i] ? lists[i].menuEl : null;
                if (/^https?:\/\/./i.test(url)) {
                    activity.url = url;
                    if (menuEl) menuEl.show();
                } else {
                    activity.url = '';
                    if (menuEl) menuEl.hide();
                }
                if (lists[i]) lists[i].activity.url = url; // Обновляем в списке
            }
        });

        var name = getSettings('list_name_' + i) || defName;
        var url = getSettings('list_url_' + i) || 'https://safeown.github.io/plvideo_4k_final.m3u';
        var title = name;

        activity.title = title;
        activity.url = url;

        var menuEl = $('<li class="menu__item selector js-' + plugin.component + '-menu' + i + '">' +
            '<div class="menu__ico">' + plugin.icon + '</div>' +
            '<div class="menu__text js-' + plugin.component + '-menu' + i + '-title">' +
            encoder.text(title).html() +
            '</div>' +
            '</li>')
            .on('hover:enter', function () {
                if (Lampa.Activity.active().component === plugin.component) {
                    Lampa.Activity.replace(Lampa.Arrays.clone(activity));
                } else {
                    Lampa.Activity.push(Lampa.Arrays.clone(activity));
                }
            });

        // Инициализируем видимость элемента меню
        if (/^https?:\/\/./i.test(url)) {
            menuEl.show();
        } else {
            menuEl.hide();
        }

        // Если список уже существует, обновляем его, иначе добавляем
        if (lists[i]) {
            lists[i].activity = activity;
            lists[i].menuEl.replaceWith(menuEl);
            lists[i].menuEl = menuEl;
        } else {
            lists.push({ activity: activity, menuEl: menuEl, groups: [] });
        }

        return i;
    }

    /**
     * Основной класс страницы плагина
     * @param {Object} object - Данные активности
     */
    function pluginPage(object) {
        if (object.id !== curListId) {
            catalog = {};
            listCfg = {};
            curListId = object.id;
        }

        var network = new Lampa.Reguest();
        var scroll = new Lampa.Scroll({
            mask: true,
            over: true
        });

        var html = $('<div></div>');
        var body = $('<div class="' + plugin.component + ' category-full"></div>');
        
        // Определяем количество колонок в зависимости от типа устройства
        var isMobile = Lampa.Platform.is('mobile');
        var isTablet = Lampa.Platform.is('tablet');
        var columnsClass = 'columns-tv'; // По умолчанию для ТВ

        if (isMobile) {
            columnsClass = 'columns-mobile';
        } else if (isTablet) {
            columnsClass = 'columns-tablet';
        }
        body.addClass(columnsClass);

        var info;
        var last;

        this.create = function () {
            var _this = this;
            this.activity.loader(true);

            var emptyResult = function () {
                var empty = new Lampa.Empty();
                html.append(empty.render());
                _this.start = empty.start;
                _this.activity.loader(false);
                _this.activity.toggle();
            };

            // Если каталог уже загружен
            if (Object.keys(catalog).length) {
                _this.build(
                    !catalog[object.currentGroup] ?
                    (lists[object.id].groups.length > 1 && catalog[lists[object.id].groups[1].key] ?
                        catalog[lists[object.id].groups[1].key]['channels'] : []) :
                    catalog[object.currentGroup]['channels']
                );
            } else if (!lists[object.id] || !object.url) {
                emptyResult();
                return;
            } else {
                // Загрузка и парсинг плейлиста
                var listUrl = prepareUrl(object.url);
                
                var handleSuccess = function(data) {
                    if (typeof data != 'string' || data.substr(0, 7).toUpperCase() !== "#EXTM3U") {
                        console.error("Полученные данные не являются корректным M3U плейлистом");
                        emptyResult();
                        return;
                    }

                    catalog = {
                        '': {
                            title: 'Все каналы',
                            channels: []
                        }
                    };

                    lists[object.id].groups = [{
                        title: 'Все каналы',
                        key: ''
                    }];

                    var lines = data.split(/\r?\n/);
                    var channel = null;
                    var defGroup = defaultGroup;
                    var chNum = 0;

                    for (var i = 0; i < lines.length; i++) {
                        var line = lines[i].trim();

                        if (line.startsWith('#EXTGRP:')) {
                            defGroup = line.substring(8).trim() || defaultGroup;
                        }
                        else if (line.startsWith('#EXTINF:')) {
                            channel = {
                                ChNum: ++chNum,
                                Title: "Канал " + chNum,
                                isYouTube: false,
                                Url: '',
                                Group: defGroup,
                                Options: {},
                                'tvg-logo': '',
                                'group-title': defGroup
                            };

                            var titleMatch = line.match(/,(.*)$/);
                            if (titleMatch) {
                                channel.Title = titleMatch[1].trim();
                            }

                            // Парсим параметры #EXTINF
                            var paramsLine = line.substring(8, line.indexOf(','));
                            var paramRegex = /([a-zA-Z0-9-]+?)=("(?:[^"\\]|\\.)*"|'(?:[^'\\]|\\.)*'|[^,\s]+)/g;
                            var paramMatch;
                            while ((paramMatch = paramRegex.exec(paramsLine)) !== null) {
                                var key = paramMatch[1].toLowerCase();
                                var value = paramMatch[2];
                                // Убираем кавычки, если они есть
                                if ((value.startsWith('"') && value.endsWith('"')) || (value.startsWith("'") && value.endsWith("'"))) {
                                    value = value.substring(1, value.length - 1);
                                }
                                channel[key] = value;
                            }
                        }
                        else if (line.startsWith('#EXTVLCOPT:')) {
                            if (channel) {
                                var optMatch = line.match(/#EXTVLCOPT:(.*)=(.*)/);
                                if (optMatch) {
                                    channel.Options[optMatch[1].toLowerCase()] = optMatch[2];
                                }
                            }
                        }
                        // else if (line.match(/^(https?|udp|rt[ms]?p|mms|acestream):\/\//)) { // Более широкий список протоколов
                        else if (line.match(/^(https?):\/\//)) { // Ограничимся http/https для простоты
                            if (channel) {
                                channel.Url = line;
                                channel.isYouTube = line.includes('youtube.com');
                                channel.Group = channel['group-title'] || defGroup;

                                // Добавляем в каталог
                                if (!catalog[channel.Group]) {
                                    catalog[channel.Group] = {
                                        title: channel.Group,
                                        channels: []
                                    };
                                    lists[object.id].groups.push({
                                        title: channel.Group,
                                        key: channel.Group
                                    });
                                }
                                catalog[channel.Group].channels.push(channel);
                                catalog[''].channels.push(channel); // Все каналы
                                channel = null; // Сброс для следующего канала
                            }
                        }
                        // Игнорируем другие строки (пустые, комментарии и т.д.)
                    }

                    // Обновляем названия групп с количеством каналов
                    for (i = 0; i < lists[object.id].groups.length; i++) {
                        var group = lists[object.id].groups[i];
                        if (catalog[group.key]) {
                             group.title = catalog[group.key].title + ' [' + catalog[group.key].channels.length + ']';
                        }
                    }

                    _this.build(
                        !catalog[object.currentGroup] ?
                        (lists[object.id].groups.length > 1 && !!catalog[lists[object.id].groups[1].key] ?
                            catalog[lists[object.id].groups[1].key]['channels'] : []) :
                        catalog[object.currentGroup]['channels']
                    );
                };

                var handleError = function(jqXHR, textStatus, errorThrown) {
                    console.error("Ошибка загрузки плейлиста:", textStatus, errorThrown);
                    // Пробуем через прокси
                    network.silent(
                        Lampa.Utils.protocol() + 'epg.rootu.top/cors.php?url=' + encodeURIComponent(listUrl) +
                        '&uid=' + UID + '&sig=' + generateSigForString(listUrl),
                        handleSuccess,
                        function() {
                            console.error("Ошибка загрузки плейлиста через прокси");
                            emptyResult();
                        },
                        false,
                        { dataType: 'text' }
                    );
                };

                network.native(
                    listUrl,
                    handleSuccess,
                    handleError,
                    false,
                    { dataType: 'text' }
                );
            }

            return this.render();
        };

        /**
         * Добавляет каналы на страницу
         * @param {Array} data - Массив каналов
         */
        this.append = function (data) {
            var _this2 = this;
            
            // Определяем количество каналов для одновременной загрузки
            var bulkSize = Lampa.Platform.is('mobile') ? 10 : (Lampa.Platform.is('tablet') ? 20 : 30);
            
            var bulkFn = function(channel) {
                var card = Lampa.Template.get('card', {
                    title: channel.Title,
                    release_year: ''
                });
                
                card.addClass('card--collection');

                var img = card.find('.card__img')[0];
                img.loading = 'lazy'; // Используем ленивую загрузку

                img.onload = function () {
                    card.addClass('card--loaded');
                };

                img.onerror = function (e) {
                    // Генерируем placeholder, если логотип не загрузился
                    var name = channel.Title
                        .replace(/\s+\(([+-]?\d+)\)/, ' $1')
                        .replace(/[-.()\s]+/g, ' ')
                        .replace(/(^|\s+)(TV|ТВ)(\s+|$)/i, '$3');
                    var fl = name.replace(/\s+/g, '').length > 5 ?
                        name.split(/\s+/).map(function(v) {
                            return v.match(/^(\+?\d+|[UF]?HD|4K)$/i) ? v : v.substring(0,1).toUpperCase()
                        }).join('').substring(0,6) :
                        name.replace(/\s+/g, '');
                    fl = fl.replace(/([UF]?HD|4k|\+\d+)$/i, '<sup>$1</sup>');
                    
                    var hex = Math.abs(Lampa.Utils.hash(channel.Title)).toString(16);
                    while (hex.length < 6) hex += hex;
                    hex = hex.substring(0,6);
                    var r = parseInt(hex.slice(0, 2), 16),
                        g = parseInt(hex.slice(2, 4), 16),
                        b = parseInt(hex.slice(4, 6), 16);
                    var hexText = (r * 0.299 + g * 0.587 + b * 0.114) > 186 ? '#000000' : '#FFFFFF';
                    
                    card.find('.card__img').replaceWith('<div class="card__img">' + fl + '</div>');
                    card.find('.card__view').css({'background-color': '#' + hex, 'color': hexText});
                    channel['tvg-logo'] = '';
                    card.addClass('card--loaded');
                };

                if (channel['tvg-logo']) {
                    img.src = channel['tvg-logo'];
                } else {
                    img.onerror();
                }

                card.on('hover:focus hover:hover', function (event) {
                    if (event.type !== 'touchstart' && event.type !== 'hover:hover') scroll.update(card);
                    last = card[0];
                    info.find('.info__title').text(channel.Title);
                }).on('hover:enter', function () {
                    var video = {
                        title: channel.Title,
                        url: prepareUrl(channel.Url),
                        plugin: plugin.component,
                        tv: true
                    };

                    // Создаем плейлист для внешнего плеера (начинается с текущего)
                    var playlistForExternal = data.map(function(elem) {
                        return {
                            title: elem.Title,
                            url: prepareUrl(elem.Url),
                            tv: true
                        };
                    });

                    // Создаем плейлист для внутреннего плеера (с номерами)
                    var playlist = data.map(function(elem, index) {
                        return {
                            title: (index + 1) + '. ' + elem.Title,
                            url: prepareUrl(elem.Url),
                            plugin: plugin.component,
                            tv: true
                        };
                    });

                    video['playlist'] = playlistForExternal;

                    // Воспроизводим
                    Lampa.Player.play(video);
                    Lampa.Player.playlist(playlist);
                });

                body.append(card);
            };

            // Добавляем каналы с контролем скорости
            var index = 0;
            var total = data.length;
            var addNext = function() {
                if (index < total) {
                    var end = Math.min(index + bulkSize, total);
                    for (var i = index; i < end; i++) {
                        bulkFn(data[i]);
                    }
                    index = end;
                    if (index < total) {
                         setTimeout(addNext, 10); // Небольшая задержка для разгрузки
                    } else {
                        _this2.activity.loader(false);
                        _this2.activity.toggle();
                    }
                } else {
                    _this2.activity.loader(false);
                    _this2.activity.toggle();
                }
            };
            
            if (data.length > 0) {
                addNext();
            } else {
                _this2.activity.loader(false);
                _this2.activity.toggle();
            }
        };

        /**
         * Строит интерфейс страницы
         * @param {Array} data - Массив каналов для отображения
         */
        this.build = function (data) {
            Lampa.Background.clear(); // Очищаем фон

            // Добавляем CSS для адаптивных колонок
            Lampa.Template.add(plugin.component + '_styles', `
                <style>
                .${plugin.component}.columns-mobile .card--collection { width: calc(50% - var(--card-margin) * 2) !important; }
                .${plugin.component}.columns-tablet .card--collection { width: calc(33.333% - var(--card-margin) * 2) !important; }
                .${plugin.component}.columns-tv .card--collection { width: calc(16.666% - var(--card-margin) * 2) !important; }
                
                @media screen and (max-width: 2560px) and (min-width: 1201px) {
                    .${plugin.component}.columns-tv .card--collection { width: calc(16.666% - var(--card-margin) * 2) !important; }
                }
                @media screen and (max-width: 1200px) and (min-width: 769px) {
                    .${plugin.component}.columns-tv .card--collection, .${plugin.component}.columns-tablet .card--collection { width: calc(25% - var(--card-margin) * 2) !important; }
                }
                @media screen and (max-width: 768px) and (min-width: 481px) {
                    .${plugin.component}.columns-tv .card--collection, .${plugin.component}.columns-tablet .card--collection { width: calc(33.333% - var(--card-margin) * 2) !important; }
                    .${plugin.component}.columns-mobile .card--collection { width: calc(50% - var(--card-margin) * 2) !important; }
                }
                @media screen and (max-width: 480px) {
                    .${plugin.component} .card--collection { width: calc(50% - var(--card-margin) * 2) !important; }
                }
                </style>
            `);
            if (!$('head').find('style').hasClass(plugin.component + '_styles')) {
                $('head').append(Lampa.Template.get(plugin.component + '_styles', {}, true));
            }


            Lampa.Template.add(plugin.component + '_button_category', `
                <div class="full-start__button selector view--category">
                    <svg style="enable-background:new 0 0 512 512;" version="1.1" viewBox="0 0 24 24" xml:space="preserve" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
                        <g id="info"/><g id="icons"><g id="menu">
                            <path d="M20,10H4c-1.1,0-2,0.9-2,2c0,1.1,0.9,2,2,2h16c1.1,0,2-0.9,2-2C22,10.9,21.1,10,20,10z" fill="currentColor"/>
                            <path d="M4,8h12c1.1,0,2-0.9,2-2c0-1.1-0.9-2-2-2H4C2.9,4,2,4.9,2,6C2,7.1,2.9,8,4,8z" fill="currentColor"/>
                            <path d="M16,16H4c-1.1,0-2,0.9-2,2c0,1.1,0.9,2,2,2h12c1.1,0,2-0.9,2-2C18,16.9,17.1,16,16,16z" fill="currentColor"/>
                        </g></g>
                    </svg>
                    <span>Категории</span>
                </div>
            `);

            Lampa.Template.add(plugin.component + '_info', `
                <div class="info layer--width">
                    <div class="info__left">
                        <div class="info__title"></div>
                        <div class="info__title-original"></div>
                    </div>
                    <div class="info__right" style="display: flex !important;">
                        <div id="category_filter"></div>
                    </div>
                </div>
            `);

            var btn = Lampa.Template.get(plugin.component + '_button_category');
            info = Lampa.Template.get(plugin.component + '_info');
            info.find('#category_filter').append(btn);

            btn.on('hover:enter hover:click', function () {
                _this2.selectGroup();
            });

            info.find('.info__title-original').text(!catalog[object.currentGroup] ? '' : catalog[object.currentGroup].title);
            html.append(info);

            if (data.length) {
                scroll.render().addClass('layer--wheight').data('mheight', info);
                html.append(scroll.render());
                this.append(data);
                scroll.append(body);
                setStorage('last_catalog_' + object.id, object.currentGroup ? object.currentGroup : '!!');
                lists[object.id].activity.currentGroup = object.currentGroup;
            } else {
                var empty = new Lampa.Empty();
                html.append(empty.render());
                Lampa.Controller.collectionSet(info);
                Navigator.move('right');
            }
            _this2.activity.loader(false);
            _this2.activity.toggle();
        };

        /**
         * Открывает выбор группы
         */
        this.selectGroup = function () {
            var activity = Lampa.Arrays.clone(lists[object.id].activity);
            Lampa.Select.show({
                title: 'Категории',
                items: Lampa.Arrays.clone(lists[object.id].groups),
                onSelect: function(group) {
                    if (object.currentGroup !== group.key) {
                        activity.currentGroup = group.key;
                        Lampa.Activity.replace(activity);
                    } else {
                        Lampa.Controller.toggle('content');
                    }
                },
                onBack: function() {
                    Lampa.Controller.toggle('content');
                }
            });
        };

        /**
         * Стартует активность
         */
        this.start = function () {
            if (Lampa.Activity.active().activity !== this.activity) return;

            var _this = this;
            Lampa.Controller.add('content', {
                toggle: function () {
                    Lampa.Controller.collectionSet(scroll.render());
                    Lampa.Controller.collectionFocus(last || false, scroll.render());
                },
                left: function () {
                    if (Navigator.canmove('left')) Navigator.move('left');
                    else Lampa.Controller.toggle('menu');
                },
                right: function () {
                    if (Navigator.canmove('right')) Navigator.move('right');
                    else _this.selectGroup();
                },
                up: function () {
                    if (Navigator.canmove('up')) {
                        Navigator.move('up');
                    } else {
                        if (!info.find('.view--category').hasClass('focus')) {
                            Lampa.Controller.collectionSet(info);
                            Navigator.move('right')
                        } else Lampa.Controller.toggle('head');
                    }
                },
                down: function () {
                    if (Navigator.canmove('down')) Navigator.move('down');
                    else if (info.find('.view--category').hasClass('focus')) {
                        Lampa.Controller.toggle('content');
                    }
                },
                back: function () {
                    Lampa.Activity.backward();
                }
            });
            Lampa.Controller.toggle('content');
        };

        this.render = function () {
            return html;
        };

        this.destroy = function () {
            network.clear();
            scroll.destroy();
            if (info) info.remove();
            html.remove();
            body.remove();
            network = null;
            html = null;
            body = null;
            info = null;
        };
    }

    // Локализация (упрощенная)
    if (!Lampa.Lang) {
        var lang_data = {};
        Lampa.Lang = {
            add: function (data) { lang_data = data; },
            translate: function (key) { return lang_data[key] ? lang_data[key].ru : key; }
        };
    }

    var langData = {};
    function langAdd(name, values) {
        langData[plugin.component + '_' + name] = values;
    }

    // Добавляем переводы (если нужно)
    langAdd('categories', { ru: 'Категории' });
    Lampa.Lang.add(langData);

    // Регистрация компонента и настроек
    Lampa.Component.add(plugin.component, pluginPage);
    Lampa.SettingsApi.addComponent(plugin);

    // Конфигурация плейлиста (один по умолчанию)
    configurePlaylist(0);

    // Генерация или загрузка UID
    UID = getStorage('uid', '');
    if (!UID) {
        UID = Lampa.Utils.uid(10).toUpperCase().replace(/(.{4})/g, '$1-');
        setStorage('uid', UID);
    } else if (UID.length > 12) {
        UID = UID.substring(0, 12);
        setStorage('uid', UID);
    }

    /**
     * Инициализация плагина после готовности приложения
     */
    function pluginStart() {
        if (window['plugin_' + plugin.component + '_ready']) return;
        window['plugin_' + plugin.component + '_ready'] = true;

        var menu = $('.menu .menu__list').eq(0);
        // Добавляем элементы меню для всех сконфигурированных плейлистов
        for (var i = 0; i < lists.length; i++) {
            if (lists[i] && lists[i].menuEl) {
                menu.append(lists[i].menuEl);
            }
        }
    }

    if (window.appready) pluginStart();
    else Lampa.Listener.follow('app', function(e){ if (e.type === 'ready') pluginStart(); });

})();
