(function () {
    'use strict';

    var plugin = {
        component: '4k_films',
        name: '4K Фильмы'
    };

    function pluginPage(data) {
        var network = new Lampa.Reguest();
        var scroll = new Lampa.Scroll({mask: true, over: true});
        var html = $('<div></div>');
        var body = $('<div class="' + plugin.component + ' category-full"></div>');
        var info;
        var last;

        // Добавляем CSS стили для книжных постеров
        var styles = $(`
            <style>
            .${plugin.component}.category-full {
                padding-bottom: 10em;
            }
            .${plugin.component} .card__view {
                position: relative;
                background-color: #353535;
                border-radius: 1em;
                cursor: pointer;
                padding-bottom: 150% !important; /* Книжный формат 2:3 */
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
                font-size: 2em;
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
            var url = 'https://safeown.github.io/plvideo_4k_final.m3u';
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
                    _this.showError('Ошибка загрузки плейлиста');
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
                        plugin: plugin.component,
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
            // Удаляем стили при уничтожении
            $('style').filter(function() {
                return this.textContent.indexOf(plugin.component) !== -1;
            }).remove();
        };
    }

    // Инициализация плагина
    function initPlugin() {
        // Регистрируем компонент
        Lampa.Component.add(plugin.component, pluginPage);

        // Добавляем в меню
        function addToMenu() {
            var menu_item = $(`
                <li class="menu__item selector" data-component="${plugin.component}">
                    <div class="menu__ico">
                        <svg viewBox="0 0 24 24" width="24" height="24" fill="currentColor">
                            <path d="M18 3v2h-2V3H8v2H6V3H4v18h2v-2h2v2h8v-2h2v2h2V3h-2zM8 17H6v-2h2v2zm0-4H6v-2h2v2zm0-4H6V7h2v2zm10 8h-2v-2h2v2zm0-4h-2v-2h2v2zm0-4h-2V7h2v2z"/>
                        </svg>
                    </div>
                    <div class="menu__text">${plugin.name}</div>
                </li>
            `).on('hover:enter', function () {
                Lampa.Activity.push({
                    component: plugin.component
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
