(function () {
    'use strict';

    var plugin_info = {
        component: 'm3u_loader',
        name: 'M3U Плейлисты',
        icon: '<svg viewBox="0 0 24 24" width="24" height="24" fill="currentColor"><path d="M3 9v6h4l5 5V4L7 9H3zm13.5 3c0-1.77-1.02-3.29-2.5-4.03v8.05c1.48-.73 2.5-2.25 2.5-4.02zM14 3.23v2.06c2.89.86 5 3.54 5 6.71s-2.11 5.85-5 6.71v2.06c4.01-.91 7-4.49 7-8.77s-2.99-7.86-7-8.77z"/></svg>'
    };

    function PluginPage(data) {
        var network = new Lampa.Reguest();
        var scroll = new Lampa.Scroll({ mask: true, over: true });
        var html = $(`<div></div>`);
        var body = $(`<div class="${plugin_info.component}"></div>`);
        var info;
        var last;

        this.create = function () {
            this.activity.loader(true);

            info = $(`<div class="info"><div class="info__title">${plugin_info.name}</div><div class="info__create">Загрузка...</div></div>`);
            html.append(info);

            scroll.render().addClass('layer--wheight').data('mheight', info);
            html.append(scroll.render());
            scroll.append(body);

            this.loadPlaylist();

            return this.render();
        };

        this.loadPlaylist = function () {
            var url = 'https://safeown.github.io/plvideo_4k_final.m3u';
            var _this = this;

            network.native(
                url,
                function (data) {
                    if (typeof data === 'string' && data.trim().startsWith('#EXTM3U')) {
                        var channels = _this.parseM3U(data);
                        info.find('.info__create').text(`Загружено: ${channels.length} каналов`);
                        _this.displayChannels(channels);
                    } else {
                        _this.showError('Неверный формат');
                    }
                    _this.activity.loader(false);
                    _this.activity.toggle();
                },
                function (xhr) {
                    console.error("Ошибка загрузки:", xhr);
                    _this.showError('Ошибка загрузки');
                    _this.activity.loader(false);
                    _this.activity.toggle();
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
                    var logoMatch = line.match(/tvg-logo="([^"]+)"/);
                    var nameMatch = line.split(',').pop();

                    var logo = logoMatch ? logoMatch[1] : '';
                    var name = nameMatch ? nameMatch.trim() : 'Без названия';

                    currentChannel = {
                        name: name,
                        logo: logo,
                        url: ''
                    };
                } else if (currentChannel && line.startsWith('http')) {
                    currentChannel.url = line;
                    channels.push(currentChannel);
                    currentChannel = null;
                }
            }
            return channels;
        };

        this.displayChannels = function (channels) {
            body.empty();

            // Определяем количество колонок
            var isMobile = Lampa.Utils.isMobile();
            var columns = isMobile ? 2 : 6;
            
            // Принудительно устанавливаем стиль для книжного вида
            var grid_styles = `display: grid; grid-template-columns: repeat(${columns}, 1fr); gap: 15px; padding: 0 20px 20px;`;
            var grid = $(`<div style="${grid_styles}"></div>`);

            channels.forEach(function (channel, index) {
                // Используем стандартный шаблон карточки
                var card = Lampa.Template.get('card', {
                    title: channel.name,
                    release_year: ''
                });

                card.addClass('card--collection');
                // Устанавливаем ширину карточки
                card.css('width', `calc(${100 / columns}% - 10px)`); 
                
                // --- НАЧАЛО ВСТАВКИ: Установка книжного вида ---
                var cardView = card.find('.card__view');
                cardView.css({
                    'padding-bottom': '150%', // Книжный формат 2:3
                    'height': '0',
                    'position': 'relative',
                    'overflow': 'hidden'
                });
                // --- КОНЕЦ ВСТАВКИ ---

                var img = card.find('.card__img')[0];
                
                // Ленивая загрузка
                if ('loading' in HTMLImageElement.prototype) {
                    img.loading = (index < 12 ? 'eager' : 'lazy');
                }
                
                img.onload = function () {
                    card.addClass('card--loaded');
                };
                
                img.onerror = function (e) {
                    // Заглушка при ошибке загрузки
                    card.find('.card__img').replaceWith('<div class="card__img" style="background-color: #333; display: flex; align-items: center; justify-content: center; font-size: 2em; color: #666;">📺</div>');
                    card.addClass('card--loaded');
                };

                if (channel.logo) {
                    img.src = channel.logo;
                } else {
                    img.onerror();
                }

                // Обработчики событий
                card.on('hover:focus hover:hover', function (e) {
                    last = card[0];
                    scroll.update(card, true);
                }).on('hover:enter', function () {
                    // Воспроизведение
                    var video_data = {
                        title: channel.name,
                        url: channel.url,
                        plugin: plugin_info.component,
                        tv: true
                    };
                    Lampa.Player.play(video_data);
                });

                grid.append(card);
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
        };
    }

    // Инициализация плагина
    function initPlugin() {
        // Регистрируем компонент
        Lampa.Component.add(plugin_info.component, PluginPage);

        // Добавляем в меню
        function addToMenu() {
            var menu_item = $(`
                <li class="menu__item selector" data-component="${plugin_info.component}">
                    <div class="menu__ico">${plugin_info.icon}</div>
                    <div class="menu__text">${plugin_info.name}</div>
                </li>
            `).on('hover:enter', function () {
                Lampa.Activity.push({
                    component: plugin_info.component
                });
            });

            $('.menu .menu__list').first().append(menu_item);
        }

        // Ждем готовности приложения
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

    initPlugin();

})();
