/*// Плагин 4K Фильмы для Lampa*/
;(function () {
    'use strict';
    
    var plugin = {
        component: '4k_films',
        name: '4K Фильмы',
        icon: "<svg viewBox=\"0 0 24 24\" width=\"24\" height=\"24\" fill=\"currentColor\"><path d=\"M18 3v2h-2V3H8v2H6V3H4v18h2v-2h2v2h8v-2h2v2h2V3h-2zM8 17H6v-2h2v2zm0-4H6v-2h2v2zm0-4H6V7h2v2zm10 8h-2v-2h2v2zm0-4h-2v-2h2v2zm0-4h-2V7h2v2z\"/></svg>",
        url: 'https://safeown.github.io/plvideo_4k_final.m3u'
    };

    function pluginPage(data) {
        var network = new Lampa.Reguest();
        var scroll = new Lampa.Scroll({ mask: true, over: true });
        var html = $('<div></div>');
        var body = $('<div class="' + plugin.component + ' category-full"></div>');
        var info;
        var last;

        // Добавляем CSS стили
        var styles = $(`
            <style>
            .${plugin.component}.category-full {
                padding-bottom: 10em;
            }
            
            /* Адаптивная сетка через float (как в оригинальном примере) */
            .${plugin.component}_grid {
                padding: 0 20px 20px;
            }
            
            /* Карточка в сетке */
            .${plugin.component}_item {
                float: left;
                /* Для больших экранов (ТВ) - 6 колонок */
                width: calc((100% - 75px) / 6); /* 6 карточек - 5 промежутков по 15px = 75px */
                margin-right: 15px;
                margin-bottom: 15px;
            }
            
            /* Сброс margin-right для последней карточки в строке */
            .${plugin.component}_item:nth-child(6n) {
                margin-right: 0;
            }
            
            /* Для планшетов - 4 колонки */
            @media screen and (max-width: 1200px) {
                .${plugin.component}_item {
                    width: calc((100% - 45px) / 4); /* 4 карточки - 3 промежутка по 15px = 45px */
                }
                
                .${plugin.component}_item:nth-child(6n) {
                    margin-right: 15px;
                }
                
                .${plugin.component}_item:nth-child(4n) {
                    margin-right: 0;
                }
            }
            
            /* Для телефонов - 2 колонки */
            @media screen and (max-width: 768px) {
                .${plugin.component}_grid {
                    padding: 0 10px 10px;
                }
                
                .${plugin.component}_item {
                    width: calc((100% - 10px) / 2); /* 2 карточки - 1 промежуток по 10px */
                    margin-right: 10px;
                    margin-bottom: 10px;
                }
                
                .${plugin.component}_item:nth-child(6n),
                .${plugin.component}_item:nth-child(4n) {
                    margin-right: 10px;
                }
                
                .${plugin.component}_item:nth-child(2n) {
                    margin-right: 0;
                }
            }
            
            /* Для очень маленьких экранов */
            @media screen and (max-width: 480px) {
                .${plugin.component}_grid {
                    padding: 0 8px 8px;
                }
                
                .${plugin.component}_item {
                    margin-bottom: 8px;
                }
            }
            
            /* Очистка float */
            .${plugin.component}_grid::after {
                content: "";
                display: table;
                clear: both;
            }
            
            /* Стили для книжных карточек */
            .${plugin.component} .card {
                width: 100% !important;
                margin: 0 !important;
            }
            
            .${plugin.component} .card__view {
                position: relative;
                background-color: #353535;
                border-radius: 1em;
                cursor: pointer;
                /* Книжный формат 2:3 */
                padding-bottom: 150% !important;
                height: 0;
                overflow: hidden;
            }
            
            .${plugin.component} img.card__img,
            .${plugin.component} div.card__img {
                background-color: unset;
                border-radius: unset;
                max-height: 200%;
                max-width: 50%;
                height: 200%;
                width: 50%;
                position: absolute;
                top: 50%;
                left: 50%;
                transform: translate(-50%, -50%);
                font-size: 1.5em;
                object-fit: cover;
                display: flex;
                align-items: center;
                justify-content: center;
                font-weight: bold;
            }
            
            .${plugin.component} .card__title {
                margin-top: 8px;
                font-size: 12px;
                text-align: center;
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
                padding: 0 4px;
            }
            
            @media screen and (max-width: 768px) {
                .${plugin.component} .card__title {
                    font-size: 13px;
                }
                
                .${plugin.component} img.card__img,
                .${plugin.component} div.card__img {
                    font-size: 1.2em;
                }
            }
            </style>
        `);
        $('head').append(styles);

        this.create = function () {
            this.activity.loader(true);

            info = $(`<div class="info"><div class="info__title">${plugin.name}</div><div class="info__create">Загрузка плейлиста...</div></div>`);
            html.append(info);

            scroll.render().addClass('layer--wheight').data('mheight', info);
            html.append(scroll.render());
            scroll.append(body);

            this.loadPlaylist();

            return this.render();
        };

        this.loadPlaylist = function () {
            var url = plugin.url;
            var _this = this;

            network.native(
                url,
                function (data) {
                    if (typeof data === 'string' && data.trim().startsWith('#EXTM3U')) {
                        var channels = _this.parseM3U(data);
                        info.find('.info__create').text(`Загружено каналов: ${channels.length}`);
                        _this.displayChannels(channels);
                    } else {
                        _this.showError('Неверный формат плейлиста');
                    }
                    _this.activity.loader(false);
                    _this.activity.toggle();
                },
                function (xhr) {
                    console.error("Ошибка загрузки плейлиста:", xhr);
                    // Пробуем через прокси
                    network.silent(
                        Lampa.Utils.protocol() + 'epg.rootu.top/cors.php?url=' + encodeURIComponent(url),
                        function (data) {
                            if (typeof data === 'string' && data.trim().startsWith('#EXTM3U')) {
                                var channels = _this.parseM3U(data);
                                info.find('.info__create').text(`Загружено каналов: ${channels.length}`);
                                _this.displayChannels(channels);
                            } else {
                                _this.showError('Неверный формат плейлиста (прокси)');
                            }
                            _this.activity.loader(false);
                            _this.activity.toggle();
                        },
                        function (xhr2) {
                            console.error("Ошибка загрузки через прокси:", xhr2);
                            _this.showError('Не удалось загрузить плейлист');
                            _this.activity.loader(false);
                            _this.activity.toggle();
                        },
                        false,
                        { dataType: 'text' }
                    );
                },
                false,
                { dataType: 'text' }
            );
        };

        this.parseM3U = function (text) {
            var lines = text.split(/\r?\n/);
            var channels = [];
            var currentChannel = null;

            for (var i = 0; i < lines.length; i++) {
                var line = lines[i].trim();

                if (line.startsWith('#EXTINF:')) {
                    // Извлекаем tvg-logo и название канала
                    var logoMatch = line.match(/tvg-logo="([^"]+)"/);
                    var nameMatch = line.split(',').pop();

                    var logo = logoMatch ? logoMatch[1] : '';
                    var name = nameMatch ? nameMatch.trim() : 'Без названия';

                    currentChannel = {
                        Title: name,
                        'tvg-logo': logo,
                        Url: ''
                    };
                } else if (currentChannel && line.startsWith('http')) {
                    currentChannel.Url = line;
                    channels.push(currentChannel);
                    currentChannel = null;
                }
            }
            return channels;
        };

        this.displayChannels = function (channels) {
            body.empty();

            // Создаем контейнер сетки
            var grid = $(`<div class="${plugin.component}_grid"></div>`);

            channels.forEach(function (channel, chI) {
                // Создаем контейнер для карточки
                var item = $(`<div class="${plugin.component}_item"></div>`);
                
                // Используем стандартный шаблон карточки Lampa
                var card = Lampa.Template.get('card', {
                    title: channel.Title,
                    release_year: ''
                });

                // Добавляем класс для коллекции
                card.addClass('card--collection');
                
                // --- Установка книжной формы карточки через cardView.css() ---
                var cardView = card.find('.card__view');
                // padding-bottom: 150% создает высоту, равную 150% от ширины (формат 2:3)
                cardView.css({
                    'padding-bottom': '150%', // Книжный формат 2:3
                    'height': '0',
                    'position': 'relative',
                    'overflow': 'hidden'
                });
                // --- Конец установки формы ---
                
                var img = card.find('.card__img')[0];
                
                // Ленивая загрузка для оптимизации
                if ('loading' in HTMLImageElement.prototype) {
                    img.loading = (chI < 18 ? 'eager' : 'lazy');
                }
                
                // Обработчик успешной загрузки изображения
                img.onload = function () {
                    card.addClass('card--loaded');
                };
                
                // Обработчик ошибки загрузки изображения
                img.onerror = function (e) {
                    // Создаем заглушку с инициалами названия канала
                    var name = channel.Title.replace(/\s+\(([+-]?\d+)\)/, ' $1')
                                          .replace(/[-.()\s]+/g, ' ')
                                          .replace(/(^|\s+)(TV|ТВ)(\s+|$)/i, '$3');
                    var fl = name.replace(/\s+/g, '').length > 5 ? 
                             name.split(/\s+/).map(function(v) { 
                                 return v.match(/^(\+?\d+|[UF]?HD|4K)$/i) ? v : v.substring(0,1).toUpperCase() 
                             }).join('').substring(0,6) : 
                             name.replace(/\s+/g, '');
                    fl = fl.replace(/([UF]?HD|4k|\+\d+)$/i, '<sup>$1</sup>');
                    
                    // Генерируем цвет на основе названия
                    var hex = (Lampa.Utils.hash(channel.Title) * 1).toString(16);
                    while (hex.length < 6) hex += hex;
                    hex = hex.substring(0,6);
                    var r = parseInt(hex.slice(0, 2), 16),
                        g = parseInt(hex.slice(2, 4), 16),
                        b = parseInt(hex.slice(4, 6), 16);
                    var hexText = (r * 0.299 + g * 0.587 + b * 0.114) > 186 ? '#000000' : '#FFFFFF';
                    
                    // Заменяем изображение на заглушку
                    card.find('.card__img').replaceWith(`<div class="card__img" style="background-color: #${hex}; color: ${hexText};">${fl}</div>`);
                    card.addClass('card--loaded');
                };

                // Устанавливаем источник изображения или вызываем onerror если лого нет
                if (channel['tvg-logo']) {
                    img.src = channel['tvg-logo'];
                } else {
                    img.onerror();
                }

                // Обработчики событий навигации
                card.on('hover:focus hover:hover', function (e) {
                    last = card[0];
                    scroll.update(card, true);
                }).on('hover:enter', function () {
                    // Воспроизведение канала
                    var video_data = {
                        title: channel.Title,
                        url: channel.Url,
                        plugin: plugin.component,
                        tv: true
                    };
                    Lampa.Player.play(video_data);
                });

                // Добавляем карточку в контейнер
                item.append(card);
                grid.append(item);
            });

            body.append(grid);
        };

        this.showError = function (message) {
            info.find('.info__create').text(message);
            var empty = new Lampa.Empty({ title: 'Ошибка', text: message });
            body.empty().append(empty.render());
        };

        this.start = function () {
            var _this = this;
            Lampa.Controller.add('content', {
                toggle: function () {
                    Lampa.Controller.collectionSet(scroll.render());
                    Lampa.Controller.collectionFocus(last || false, scroll.render());
                },
                left: function () {
                    if (Lampa.Navigator.canmove('left')) Lampa.Navigator.move('left');
                    else Lampa.Controller.toggle('menu');
                },
                right: function () {
                    Lampa.Navigator.move('right');
                },
                up: function () {
                    Lampa.Navigator.move('up');
                },
                down: function () {
                    Lampa.Navigator.move('down');
                },
                back: function () {
                    Lampa.Activity.backward();
                }
            });
            Lampa.Controller.toggle('content');
        };

        this.pause = function () { };
        this.stop = function () { };
        this.render = function () {
            return html;
        };
        this.destroy = function () {
            network.clear();
            scroll.destroy();
            html.remove();
            body.remove();
            info = null;
            // Удаляем стили при уничтожении
            $('style').filter(function() {
                return this.textContent.indexOf(plugin.component) !== -1;
            }).remove();
        };
    }

    // Инициализация плагина
    function initPlugin() {
        // Регистрируем компонент плагина
        Lampa.Component.add(plugin.component, pluginPage);

        // Функция добавления пункта меню
        function addToMenu() {
            var menu_item = $(`
                <li class="menu__item selector" data-component="${plugin.component}">
                    <div class="menu__ico">${plugin.icon}</div>
                    <div class="menu__text">${plugin.name}</div>
                </li>
            `).on('hover:enter', function () {
                Lampa.Activity.push({
                    component: plugin.component
                });
            });

            $('.menu .menu__list').first().append(menu_item);
        }

        // Ждем готовности приложения перед добавлением в меню
        if (window.appready) {
            addToMenu();
        } else {
            Lampa.Listener.follow('app', function (e) {
                if (e.type === 'ready') {
                    addToMenu();
                }
            });
        }
    }

    // Запускаем инициализацию плагина
    initPlugin();

})();
