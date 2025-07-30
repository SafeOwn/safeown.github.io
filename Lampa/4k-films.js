/*
// Плагин IPTV для Lampa (Специально для https://safeown.github.io/plvideo_4k_final.m3u)
// Загружает M3U плейлист и отображает каналы с обложками
// Адаптирует количество колонок под тип устройства (телефон/планшет/телевизор)
*/
;(function () {
    'use strict';

    // Основная конфигурация плагина
    var plugin = {
        component: 'safeown_iptv', // Уникальный идентификатор компонента
        icon: "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"24\" height=\"24\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\" class=\"feather feather-tv\"><rect x=\"2\" y=\"7\" width=\"20\" height=\"15\" rx=\"2\" ry=\"2\"></rect><polyline points=\"17 2 12 7 7 2\"></polyline></svg>",
        name: 'SafeOwn IPTV'
    };

    var encoder = $('<div/>');

    /**
     * Основной класс страницы плагина
     */
    function pluginPage(object) {
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
                console.log(plugin.name, "Ошибка загрузки или пустой плейлист.");
                var empty = new Lampa.Empty();
                html.append(empty.render());
                _this.start = empty.start;
                _this.activity.loader(false);
                _this.activity.toggle();
            };

            // URL плейлиста (жестко задан)
            var playlistUrl = 'https://safeown.github.io/plvideo_4k_final.m3u';
            
            console.log(plugin.name, "Начинаем загрузку плейлиста:", playlistUrl);

            var handleSuccess = function(data) {
                console.log(plugin.name, "Плейлист загружен, длина данных:", data.length);
                
                if (typeof data != 'string' || data.trim().substr(0, 7).toUpperCase() !== "#EXTM3U") {
                    console.error(plugin.name, "Полученные данные не являются корректным M3U плейлистом");
                    emptyResult();
                    return;
                }

                var lines = data.split(/\r?\n/);
                var channels = [];
                var currentChannel = null;
                var defaultGroup = 'Без категории';

                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i].trim();

                    if (line.startsWith('#EXTGRP:')) {
                        defaultGroup = line.substring(8).trim() || defaultGroup;
                    }
                    else if (line.startsWith('#EXTINF:')) {
                        currentChannel = {
                            title: "Неизвестный канал",
                            url: '',
                            logo: '',
                            group: defaultGroup
                        };

                        // Извлекаем название канала (после последней запятой)
                        var titleMatch = line.match(/,(.*)$/);
                        if (titleMatch) {
                            currentChannel.title = titleMatch[1].trim();
                        }

                        // Извлекаем параметры tvg-logo и group-title
                        var logoMatch = line.match(/tvg-logo=["']?([^"']*)["']?/i);
                        if (logoMatch) {
                            currentChannel.logo = logoMatch[1];
                        }

                        var groupMatch = line.match(/group-title=["']?([^"']*)["']?/i);
                        if (groupMatch) {
                            currentChannel.group = groupMatch[1] || defaultGroup;
                        }
                    }
                    // Проверяем строку с URL (http или https)
                    else if (line.match(/^(https?):\/\//)) {
                        if (currentChannel) {
                            currentChannel.url = line;
                            // Добавляем только если есть URL
                            if (currentChannel.url) {
                                channels.push(currentChannel);
                            }
                            currentChannel = null; // Сброс для следующего канала
                        }
                    }
                    // Игнорируем другие строки
                }

                console.log(plugin.name, "Каналы после парсинга:", channels.length);
                if (channels.length === 0) {
                    emptyResult();
                    return;
                }

                _this.build(channels);
            };

            var handleError = function(jqXHR, textStatus, errorThrown) {
                console.error(plugin.name, "Ошибка загрузки плейлиста:", textStatus, errorThrown);
                // Пробуем через прокси
                network.silent(
                    Lampa.Utils.protocol() + 'epg.rootu.top/cors.php?url=' + encodeURIComponent(playlistUrl),
                    handleSuccess,
                    function() {
                        console.error(plugin.name, "Ошибка загрузки плейлиста через прокси");
                        emptyResult();
                    },
                    false,
                    { dataType: 'text' }
                );
            };

            network.native(
                playlistUrl,
                handleSuccess,
                handleError,
                false,
                { dataType: 'text' }
            );

            return this.render();
        };


        this.append = function (data) {
            var _this2 = this;
            
            var bulkFn = function(channel) {
                var card = Lampa.Template.get('card', {
                    title: channel.title,
                    release_year: '' // Группа можно было бы добавить сюда, но она нестандартная
                });
                
                card.addClass('card--collection');

                var img = card.find('.card__img')[0];

                img.onload = function () {
                    card.addClass('card--loaded');
                };

                img.onerror = function (e) {
                     // Генерируем placeholder, если логотип не загрузился
                    var name = channel.title
                        .replace(/\s+\(([+-]?\d+)\)/, ' $1')
                        .replace(/[-.()\s]+/g, ' ')
                        .replace(/(^|\s+)(TV|ТВ)(\s+|$)/i, '$3');
                    var fl = name.replace(/\s+/g, '').length > 5 ?
                        name.split(/\s+/).map(function(v) {
                            return v.match(/^(\+?\d+|[UF]?HD|4K)$/i) ? v : v.substring(0,1).toUpperCase()
                        }).join('').substring(0,6) :
                        name.replace(/\s+/g, '');
                    fl = fl.replace(/([UF]?HD|4k|\+\d+)$/i, '<sup>$1</sup>');
                    
                    var hex = Math.abs(Lampa.Utils.hash(channel.title)).toString(16);
                    while (hex.length < 6) hex += hex;
                    hex = hex.substring(0,6);
                    var r = parseInt(hex.slice(0, 2), 16),
                        g = parseInt(hex.slice(2, 4), 16),
                        b = parseInt(hex.slice(4, 6), 16);
                    var hexText = (r * 0.299 + g * 0.587 + b * 0.114) > 186 ? '#000000' : '#FFFFFF';
                    
                    card.find('.card__img').replaceWith('<div class="card__img">' + fl + '</div>');
                    card.find('.card__view').css({'background-color': '#' + hex, 'color': hexText});
                    card.addClass('card--loaded');
                };

                if (channel.logo) {
                    img.src = channel.logo;
                } else {
                    img.onerror(); // Сразу вызываем, если логотипа нет
                }

                card.on('hover:focus hover:hover', function (event) {
                    if (event.type !== 'touchstart' && event.type !== 'hover:hover') scroll.update(card);
                    last = card[0];
                    info.find('.info__title').text(channel.title);
                    // info.find('.info__title-original').text(channel.group); // Показываем группу
                }).on('hover:enter', function () {
                    var video = {
                        title: channel.title,
                        url: channel.url,
                        plugin: plugin.component,
                        tv: true
                    };

                    // Создаем простой плейлист для внутреннего плеера
                    var playlist = data.map(function(elem) {
                        return {
                            title: elem.title,
                            url: elem.url,
                            plugin: plugin.component,
                            tv: true
                        };
                    });

                    // Воспроизводим
                    Lampa.Player.play(video);
                    Lampa.Player.playlist(playlist);
                });

                body.append(card);
            };

            // Добавляем каналы
            var index = 0;
            var total = data.length;
            var addNext = function() {
                if (index < total) {
                     bulkFn(data[index]);
                    index++;
                    setTimeout(addNext, 1); // Минимальная задержка
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

            Lampa.Template.add(plugin.component + '_info', `
                <div class="info layer--width">
                    <div class="info__left">
                        <div class="info__title"></div>
                        <!-- <div class="info__title-original"></div> -->
                    </div>
                    <div class="info__right" style="display: flex !important;">
                        <!-- Кнопка категорий, если понадобится -->
                    </div>
                </div>
            `);

            info = Lampa.Template.get(plugin.component + '_info');
            html.append(info);

            if (data.length) {
                scroll.render().addClass('layer--wheight').data('mheight', info);
                html.append(scroll.render());
                this.append(data);
                scroll.append(body);
            } else {
                var empty = new Lampa.Empty();
                html.append(empty.render());
                Lampa.Controller.collectionSet(info);
                Navigator.move('right');
                this.activity.loader(false);
                this.activity.toggle();
                return; // Выходим, если данных нет
            }
            this.activity.loader(false);
            this.activity.toggle();
        };

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
                     // else _this.selectGroup(); // Нет групп в этой версии
                },
                up: function () {
                    if (Navigator.canmove('up')) {
                        Navigator.move('up');
                    } else {
                         Lampa.Controller.collectionSet(info);
                         // Navigator.move('right') // Нет кнопки категорий
                         Lampa.Controller.toggle('head');
                    }
                },
                down: function () {
                    if (Navigator.canmove('down')) Navigator.move('down');
                    // else if (info.find('.view--category').hasClass('focus')) { // Нет кнопки категорий
                    //     Lampa.Controller.toggle('content');
                    // }
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

    // Регистрация компонента
    Lampa.Component.add(plugin.component, pluginPage);

    // Добавление в меню
    function pluginStart() {
        if (window['plugin_' + plugin.component + '_ready']) return;
        window['plugin_' + plugin.component + '_ready'] = true;

        var menu = $('.menu .menu__list').eq(0);
        var menuEl = $('<li class="menu__item selector js-' + plugin.component + '-menu">' +
            '<div class="menu__ico">' + plugin.icon + '</div>' +
            '<div class="menu__text">' + plugin.name + '</div>' +
            '</li>')
            .on('hover:enter', function () {
                var activity = {
                    component: plugin.component
                };
                if (Lampa.Activity.active().component === plugin.component) {
                    Lampa.Activity.replace(activity);
                } else {
                    Lampa.Activity.push(activity);
                }
            });
        menu.append(menuEl);
    }

    if (window.appready) pluginStart();
    else Lampa.Listener.follow('app', function(e){ if (e.type === 'ready') pluginStart(); });

})();
