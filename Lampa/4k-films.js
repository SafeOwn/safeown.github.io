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

        // Добавляем CSS стили для полностью независимой сетки
        var styles = $(`
            <style>
            /* Основные стили для плагина */
            .${plugin.component}.category-full {
                padding-bottom: 10em;
            }
            
            /* Контейнер для нашей независимой сетки */
            .${plugin.component}_custom_grid {
                position: relative;
                width: 100%;
                margin: 0;
                padding: 0 20px 20px 20px;
            }
            
            /* Контейнер одной карточки */
            .${plugin.component}_card_container {
                position: absolute;
                top: 0;
                left: 0;
                width: calc((100% - 85px) / 6); /* 6 колонок по умолчанию */
                height: 0;
                padding-bottom: calc(((100% - 85px) / 6) * 1.5); /* Высота 150% от ширины (книжный формат) */
            }
            
            /* Стили для карточки */
            .${plugin.component}_card {
                position: absolute;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background-color: #353535;
                border-radius: 1em;
                cursor: pointer;
                overflow: hidden;
                box-sizing: border-box;
            }
            
            /* Изображение в карточке */
            .${plugin.component}_card_img {
                position: absolute;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                object-fit: cover;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 2em;
                font-weight: bold;
                color: #fff;
            }
            
            /* Заголовок карточки */
            .${plugin.component}_card_title {
                position: absolute;
                bottom: 0;
                left: 0;
                width: 100%;
                padding: 8px 4px;
                margin: 0;
                font-size: 12px;
                text-align: center;
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
                box-sizing: border-box;
                background: rgba(0, 0, 0, 0.7);
                color: #fff;
            }
            
            /* Для телефонов - 2 колонки */
            @media screen and (max-width: 768px) {
                .${plugin.component}_card_container {
                    width: calc((100% - 10px) / 2); /* 2 колонки */
                    padding-bottom: calc(((100% - 10px) / 2) * 1.5); /* Высота 150% от ширины */
                }
                
                .${plugin.component}_custom_grid {
                    padding: 0 10px 10px 10px;
                }
                
                .${plugin.component}_card_title {
                    font-size: 14px;
                }
            }
            
            /* Для планшетов - 4 колонки */
            @media screen and (min-width: 769px) and (max-width: 1200px) {
                .${plugin.component}_card_container {
                    width: calc((100% - 45px) / 4); /* 4 колонки */
                    padding-bottom: calc(((100% - 45px) / 4) * 1.5); /* Высота 150% от ширины */
                }
            }
            
            /* Для очень маленьких экранов */
            @media screen and (max-width: 480px) {
                .${plugin.component}_custom_grid {
                    padding: 0 8px 8px 8px;
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

            // Создаем контейнер для нашей сетки
            var grid = $(`<div class="${plugin.component}_custom_grid"></div>`);
            
            // Вычисляем количество колонок в зависимости от ширины экрана
            var isMobile = window.innerWidth <= 768;
            var isTablet = window.innerWidth > 768 && window.innerWidth <= 1200;
            var columns = isMobile ? 2 : (isTablet ? 4 : 6);
            
            // Вычисляем ширину одной колонки в процентах
            var columnWidth = isMobile ? 
                ((100 - 10) / 2) : 
                (isTablet ? ((100 - 45) / 4) : ((100 - 85) / 6));
            
            // Высота строки (150% от ширины колонки)
            var rowHeight = columnWidth * 1.5;
            
            // Высота отступа между строками
            var rowGap = isMobile ? 10 : (isTablet ? 15 : 15);
            
            // Ширина отступа между колонками
            var columnGap = isMobile ? 10 : (isTablet ? 15 : 15);

            channels.forEach(function (channel, index) {
                // Вычисляем позицию карточки
                var row = Math.floor(index / columns);
                var col = index % columns;
                
                // Позиционирование
                var left = col * (columnWidth + columnGap);
                var top = row * (rowHeight + rowGap);

                // Создаем контейнер для карточки
                var cardContainer = $(`<div class="${plugin.component}_card_container"></div>`);
                cardContainer.css({
                    'left': left + '%',
                    'top': top + 'px'
                });

                // Создаем карточку
                var card = $(`<div class="${plugin.component}_card" data-index="${index}"></div>`);
                
                // Создаем изображение или заглушку
                var imgElement;
                if (channel['tvg-logo']) {
                    imgElement = $(`<img class="${plugin.component}_card_img" src="${channel['tvg-logo']}" alt="${channel.Title}" />`);
                } else {
                    // Создаем заглушку с инициалами
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
                    
                    imgElement = $(`<div class="${plugin.component}_card_img" style="background-color: #${hex};">${fl}</div>`);
                }

                // Создаем заголовок
                var titleElement = $(`<div class="${plugin.component}_card_title">${channel.Title}</div>`);

                // Добавляем элементы в карточку
                card.append(imgElement);
                card.append(titleElement);

                // Добавляем обработчики событий
                card.on('click touchend', function(e) {
                    e.preventDefault();
                    e.stopPropagation();
                    // Воспроизведение канала
                    var video_data = {
                        title: channel.Title,
                        url: channel.Url,
                        plugin: plugin.component,
                        tv: true
                    };
                    Lampa.Player.play(video_data);
                });

                // Для навигации контроллером
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
                cardContainer.append(card);
                grid.append(cardContainer);
            });

            // Устанавливаем высоту контейнера сетки
            if (channels.length > 0) {
                var totalRows = Math.ceil(channels.length / columns);
                var gridHeight = totalRows * (rowHeight + rowGap) - rowGap; // Вычитаем последний отступ
                grid.css('height', gridHeight + 'px');
            }

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
