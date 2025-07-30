// plugins/4k_iptv/index.js
// Упрощенный плагин на основе Pasted_Text_1753876141723.txt

(function () {
    'use strict';

    var plugin = {
        component: '4k_iptv',
        // Иконка Play из оригинала
        icon: "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 24\" fill=\"currentColor\"><path d=\"M8 5v14l11-7z\"/></svg>",
        name: '4kTV' // Имя по умолчанию, может быть изменено в настройках
    };

    var lists = [];
    var encoder = $('<div/>');
    var defaultPlaylistUrl = 'https://safeown.github.io/plvideo_4k_final.m3u'; // Ваш URL по умолчанию

    // Добавляем переводы
    Lampa.Lang.add({
        ru: {
            '4k_iptv': '4kTV',
            '4k_iptv_settings_playlist_num_group': 'Плейлист ',
            '4k_iptv_settings_list_name': 'Название',
            '4k_iptv_settings_list_name_desc': 'Название плейлиста в левом меню',
            '4k_iptv_settings_list_url': 'URL-адрес',
            '4k_iptv_default_playlist_cat': 'Категории'
        },
        en: {
            '4k_iptv': '4kTV',
            '4k_iptv_settings_playlist_num_group': 'Playlist ',
            '4k_iptv_settings_list_name': 'Name',
            '4k_iptv_settings_list_name_desc': 'Playlist name in the left menu',
            '4k_iptv_settings_list_url': 'URL',
            '4k_iptv_default_playlist_cat': 'Categories'
        }
        // Добавьте другие языки при необходимости
    });

    function getStorage(name, defaultValue) {
        return Lampa.Storage.get(plugin.component + '_' + name, defaultValue);
    }

    function setStorage(name, val, noListen) {
        return Lampa.Storage.set(plugin.component + '_' + name, val, noListen);
    }

    function getSettings(name) {
        return Lampa.Storage.field(plugin.component + '_' + name);
    }

    function addSettings(type, param) {
        // Упрощенная обертка для добавления настроек
        var data = {
            component: plugin.component,
            param: param
        };
        if (type === 'title') {
            data.param.type = 'title';
        } else if (type === 'input') {
            data.param.type = 'input';
        } else if (type === 'static') {
            data.param.type = 'static';
        }
        // Добавляем параметр в API настроек
        Lampa.SettingsApi.addParam(data);
    }

    // --- Компонент страницы плагина ---
    function pluginPage(object) {
        var html = $('<div></div>');
        var body = $('<div class="' + plugin.component + '_custom_container"></div>'); // Собственный контейнер
        body.toggleClass('my_custom_icons', true); // Простой класс для стилей

        var scroll = new Lampa.Scroll({
            mask: true,
            over: true
        });

        var network = new Lampa.Reguest();
        var items = [];

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

            var parseList = function (data) {
                if (typeof data != 'string' || data.substr(0, 7).toUpperCase() !== "#EXTM3U") {
                    emptyResult();
                    return;
                }
                items = [];
                var l = data.split(/\r?\n/);
                var cnt = 0, i = 1, chNum = 0, m, mm, defGroup = 'Other';
                if (!!(m = l[0].match(/([^\s=]+)=((["'])(.*?)\3|\S+)/g))) {
                    // listCfg - не используется в упрощенной версии
                }
                while (i < l.length) {
                    chNum = cnt + 1;
                    var channel = {
                        ChNum: chNum,
                        Title: "Ch " + chNum,
                        isYouTube: false,
                        Url: '',
                        Group: '',
                        Options: {}
                    };
                    for (; cnt < chNum && i < l.length; i++) {
                        if (!!(m = l[i].match(/^#EXTGRP:\s*(.+?)\s*$/i)) && m[1].trim() !== '') {
                            defGroup = m[1].trim();
                        } else if (!!(m = l[i].match(/^#EXTINF:\s*-?\d+(\s+\S.*?\s*)?,(.+)$/i))) {
                            channel.Title = m[2].trim();
                            if (!!m[1] && !!(m = m[1].match(/([^\s=]+)=((["'])(.*?)\3|\S+)/g))) {
                                for (var j = 0; j < m.length; j++) {
                                    if (!!(mm = m[j].match(/([^\s=]+)=((["'])(.*?)\3|\S+)/))) {
                                        channel[mm[1].toLowerCase()] = mm[4] || mm[2];
                                    }
                                }
                            }
                        } else if (!!(m = l[i].match(/^#EXTVLCOPT:\s*([^\s=]+)=(.+)$/i))) {
                            channel.Options[m[1].trim().toLowerCase()] = m[2].trim();
                        } else if (!!(m = l[i].match(/^(https?):\/\/(.+)$/i))) {
                            channel.Url = m[0].trim();
                            channel.isYouTube = !!(m[2].match(/^(www\.)?youtube\.com/));
                            channel.Group = channel['group-title'] || defGroup;
                            cnt++;
                        }
                    }
                    if (!!channel.Url && !channel.isYouTube) {
                        channel['Title'] = channel['Title'].replace('ⓢ', '').replace('ⓖ', '').replace(/\s+/g, ' ').trim();
                        // Если нет лого, пытаемся сгенерировать URL (как в оригинале, но упрощенно)
                        if (!channel['tvg-logo'] && channel['Title'] !== "Ch " + chNum) {
                             // Используем ваш домен для генерации URL плейсхолдеров, если нужно
                             // channel['tvg-logo'] = Lampa.Utils.protocol() + 'epg.rootu.top/picon/' + encodeURIComponent(channel['Title']) + '.png';
                             // Или оставляем пустым, чтобы использовался текст
                        }
                        items.push(channel);
                    }
                }
                _this.build(items);
            };

            var listUrl = object.url; // URL берется из объекта активности, который формируется в configurePlaylist
            if (!listUrl) {
                 emptyResult();
                 return;
            }
            network.native(
                listUrl,
                parseList,
                function () {
                    // Ошибка, пробуем через прокси
                    network.silent(
                        Lampa.Utils.protocol() + 'epg.rootu.top/cors.php?url=' + encodeURIComponent(listUrl),
                        parseList,
                        emptyResult,
                        false,
                        {dataType: 'text'}
                    );
                },
                false,
                {dataType: 'text'}
            );
            return this.render();
        };

        this.append = function (data) {
            var _this2 = this;
            var lazyLoadImg = ('loading' in HTMLImageElement.prototype);

            data.forEach(function (channel, chIndex) {
                var card = Lampa.Template.get('card', {
                    title: channel.Title,
                    release_year: '' // Не используется
                });

                // --- НАЧАЛО ВСТАВКИ: Установка ширины и формы (книжная) карточки ---
                // Устанавливаем ширину карточки
                card.css('width', '48%'); // Почти 2 в ряд с учетом margin от Lampa

                // Находим контейнер изображения внутри карточки
                var cardView = card.find('.card__view');

                // Принудительно устанавливаем стили для .card__view, чтобы сделать его книжным
                // padding-bottom: 150% создает высоту, равную 150% от ширины (формат ~2:3)
                cardView.css({
                    'padding-bottom': '150%', // Фиксированное книжное соотношение
                    'height': '0',
                    'position': 'relative',
                    'overflow': 'hidden',
                    'background-color': '#353535' // Фон, если изображение не загрузится
                });
                // --- КОНЕЦ ВСТАВКИ ---

                card.addClass('card--collection');

                var img = card.find('.card__img')[0];
                if (lazyLoadImg) img.loading = (chIndex < 18 ? 'eager' : 'lazy');

                img.onload = function () {
                    card.addClass('card--loaded');
                };

                img.onerror = function (e) {
                    // Обработка ошибки загрузки изображения - показываем название
                    var name = channel.Title
                        .replace(/\s+\(([+-]?\d+)\)/, ' $1').replace(/[-.()\s]+/g, ' ').replace(/(^|\s+)(TV|ТВ)(\s+|$)/i, '$3');
                    var fl = name.replace(/\s+/g, '').length > 5
                        ? name.split(/\s+/).map(function(v) {return v.match(/^(\+?\d+|[UF]?HD|4K)$/i) ? v : v.substring(0,1).toUpperCase()}).join('').substring(0,6)
                        : name.replace(/\s+/g, '')
                    ;
                    fl = fl.replace(/([UF]?HD|4k|\+\d+)$/i, '<sup>$1</sup>');
                    var hex = (Lampa.Utils.hash(channel.Title) * 1).toString(16);
                    while (hex.length < 6) hex+=hex;
                    hex = hex.substring(0,6);
                    var r = parseInt(hex.slice(0, 2), 16),
                        g = parseInt(hex.slice(2, 4), 16),
                        b = parseInt(hex.slice(4, 6), 16);
                    var hexText = (r * 0.299 + g * 0.587 + b * 0.114) > 186 ? '#000000' : '#FFFFFF';
                    // Заменяем <img> на <div> с текстом и цветом фона
                    card.find('.card__img').replaceWith('<div class="card__img" style="display: flex; align-items: center; justify-content: center; height: 100%; font-size: 2em; background-color: #' + hex + '; color: ' + hexText + ';">' + fl + '</div>');
                    card.addClass('card--loaded'); // Помечаем как загруженную
                };

                if (channel['tvg-logo']) {
                    img.src = channel['tvg-logo'];
                } else {
                    // Если лого нет, вызываем onerror для отображения текста
                    img.onerror();
                }

                // Убираем иконки, которые не нужны
                card.find('.card__icons').empty();

                card.on('hover:focus hover:hover touchstart', function (event) {
                    // Скролл обновляется при фокусе
                    if (event.type && event.type !== 'touchstart' && event.type !== 'hover:hover') scroll.update(card, true);
                }).on('hover:enter', function () {
                    // Воспроизведение
                    var video = {
                        title: channel.Title,
                        url: channel.Url // Используем Url напрямую
                    };
                    console.log('[' + plugin.component + '] Playing:', video.title, video.url);
                    Lampa.Player.play(video);
                });

                body.append(card);
            });

            // Добавляем стили один раз
            var styleId = plugin.component + '_custom_style';
            if (!$('#' + styleId).length) {
                $('body').append(`
                    <style id="${styleId}">
                        /* Контейнер для всех карточек */
                        .${plugin.component}_custom_container {
                            padding: 0 1em 1em 1em; /* Отступы вокруг сетки */
                            display: flex;
                            flex-wrap: wrap;
                            gap: 1em; /* Расстояние между карточками */
                        }
                        /* Адаптация для ТВ: 6 колонок */
                        @media screen and (min-width: 768px) {
                            .${plugin.component}_custom_container .card--collection {
                                width: calc(16.666% - 0.833em) !important; /* 6 колонок */
                            }
                        }
                        /* Убираем стили из оригинального CSS, которые могут конфликтовать */
                        .${plugin.component}_custom_container .card__view {
                             border-radius: 0.5em !important; /* Скругление углов */
                        }
                        /* Принудительно убираем стили, которые могут быть применены из .category-full */
                        .${plugin.component}_custom_container .card__age {
                             display: none !important; /* Скрываем прогресс, если он есть */
                        }
                        .${plugin.component}_custom_container .card__icons {
                             display: none !important; /* Скрываем иконки */
                        }
                    </style>
                `);
            }
        };

        this.build = function (data) {
            scroll.append(body);
            html.append(scroll.render());
            this.append(data);
            this.activity.loader(false);
            this.activity.toggle();
        };

        this.start = function () {
            Lampa.Controller.add('content', {
                toggle: function () {
                    Lampa.Controller.collectionSet(scroll.render());
                    Lampa.Controller.collectionFocus(false, scroll.render());
                },
                left: function () {
                    if (Navigator.canmove('left')) Navigator.move('left');
                    else Lampa.Controller.toggle('menu');
                },
                right: function () {
                    if (Navigator.canmove('right')) Navigator.move('right');
                },
                up: function () {
                    if (Navigator.canmove('up')) Navigator.move('up');
                    else Lampa.Controller.toggle('head');
                },
                down: function () {
                    if (Navigator.canmove('down')) Navigator.move('down');
                },
                back: function () {
                    Lampa.Activity.backward();
                }
            });
            Lampa.Controller.toggle('content');
        };

        this.pause = function () {};
        this.stop = function () {};
        this.render = function () {
            return html;
        };
        this.destroy = function () {
            network.clear();
            scroll.destroy();
            html.remove();
            body.remove();
            // Можно удалить стили при уничтожении, если это последний экземпляр
            // var styleId = plugin.component + '_custom_style';
            // if ($('.' + plugin.component + '_custom_container').length === 0) {
            //     $('#' + styleId).remove();
            // }
        };
    }

    // --- Настройки и меню ---
    function configurePlaylist(i) {
        // Обрабатываем только первый плейлист (i=0)
        if (i > 0) return i + 1;

        addSettings('title', {title: Lampa.Lang.translate('4k_iptv_settings_playlist_num_group') + (i+1)});
        var defName = plugin.name;
        var activity = {
            id: i,
            url: '', // URL будет установлен позже
            title: defName, // Название по умолчанию
            // groups, currentGroup, component, page - как в оригинале, но упрощено
            groups: [],
            currentGroup: getStorage('last_catalog' + i, Lampa.Lang.translate('4k_iptv_default_playlist_cat')),
            component: plugin.component,
            page: 1
        };
        if (activity.currentGroup === '!!') activity.currentGroup = '';

        addSettings('input', {
            title: Lampa.Lang.translate('4k_iptv_settings_list_name'),
            name: 'list_name_' + i,
            default: defName,
            placeholder: defName,
            description: Lampa.Lang.translate('4k_iptv_settings_list_name_desc'),
            onChange: function (newVal) {
                var title = !newVal ? defName : newVal;
                $('.js-' + plugin.component + '-menu' + i + '-title').text(title);
                activity.title = title;
            }
        });

        addSettings('input', {
            title: Lampa.Lang.translate('4k_iptv_settings_list_url'),
            name: 'list_url_' + i,
            default: defaultPlaylistUrl,
            placeholder: 'https://example.com/playlist.m3u',
            onChange: function (url) {
                // Логика отображения/скрытия меню из оригинала
                if (/^https?:\/\/./i.test(url)) {
                    activity.url = url;
                    lists[i].menuEl.show();
                } else {
                    activity.url = '';
                    lists[i].menuEl.hide();
                }
            }
        });

        // Получаем значения из настроек
        var name = getSettings('list_name_' + i);
        var url = getSettings('list_url_' + i);
        var title = !name ? defName : name;
        activity.title = title;

        // Создаем элемент меню
        var menuEl = $('<li class="menu__item selector js-' + plugin.component + '-menu' + i + '">'
                        + '<div class="menu__ico">' + plugin.icon + '</div>'
                        + '<div class="menu__text js-' + plugin.component + '-menu' + i + '-title">'
                            + encoder.text(title).html()
                        + '</div>'
                    + '</li>')
            .hide() // Изначально скрыт
            .on('hover:enter', function(){
                if (Lampa.Activity.active().component === plugin.component) {
                    Lampa.Activity.replace(Lampa.Arrays.clone(activity));
                } else {
                    Lampa.Activity.push(Lampa.Arrays.clone(activity));
                }
            });

        // Проверяем URL при инициализации и показываем/скрываем меню
        if (/^https?:\/\/./i.test(url)) {
            activity.url = url;
            menuEl.show();
        } else {
            activity.url = '';
            menuEl.hide();
        }

        lists.push({activity: activity, menuEl: menuEl, groups: []});
        return !activity.url ? i + 1 : i;
    }

    // --- Инициализация ---
    Lampa.Component.add(plugin.component, pluginPage);

    // Добавляем плагин в настройки
    Lampa.SettingsApi.addComponent(plugin);

    // Настраиваем плейлист (только один)
    var i = configurePlaylist(0);

    // Добавляем пункт меню при запуске приложения
    function pluginStart() {
        if (!!window['plugin_' + plugin.component + '_ready']) return;
        window['plugin_' + plugin.component + '_ready'] = true;
        var menu = $('.menu .menu__list').eq(0);
        // Добавляем пункт меню
        if (lists.length > 0 && lists[0].menuEl) {
             menu.append(lists[0].menuEl);
        }
    }

    if (!!window.appready) pluginStart();
    else Lampa.Listener.follow('app', function(e){if (e.type === 'ready') pluginStart()});

})();
