Lampa.Plugin.add('m3u_loader', {
    init: function () {
        // Добавляем пункт меню
        Lampa.Manifest.menu.push({
            title: 'M3U Плейлисты',
            component: 'm3u_loader_main',
            icon: 'img/icons/menu/catalog.svg'
        });

        // Регистрируем компонент
        Lampa.Component.add('m3u_loader_main', this.mainComponent.bind(this));
    },

    mainComponent: function () {
        var comp = new Lampa.Component();
        
        comp.create = function () {
            this.activity = new Lampa.Activity({
                component: 'm3u_loader_main',
                template: this.template.bind(this)
            });

            this.activity.render();

            this.loadPlaylist();

            return this.activity;
        };

        comp.template = function () {
            return $(`
                <div class="m3u-loader">
                    <div class="m3u-loader__header" style="padding: 20px; text-align: center;">
                        Загрузка плейлиста...
                    </div>
                    <div class="m3u-loader__content" style="padding: 0 20px;"></div>
                </div>
            `);
        };

        comp.loadPlaylist = function () {
            var url = 'https://safeown.github.io/plvideo_4k_final.m3u';
            var _this = this;
            
            this.activity.loader(true);

            fetch(url)
                .then(function(response) {
                    if (!response.ok) {
                        throw new Error('Network response was not ok');
                    }
                    return response.text();
                })
                .then(function(text) {
                    _this.activity.loader(false);
                    var channels = _this.parseM3U(text);
                    _this.displayChannels(channels);
                })
                .catch(function(error) {
                    _this.activity.loader(false);
                    _this.activity.render().find('.m3u-loader__header').text('Ошибка загрузки: ' + error.message);
                    console.error('M3U Loader Error:', error);
                });
        };

        comp.parseM3U = function(text) {
            var lines = text.split('\n');
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

        comp.displayChannels = function(channels) {
            var container = this.activity.render().find('.m3u-loader__content');
            var header = this.activity.render().find('.m3u-loader__header');
            
            header.text('Каналов загружено: ' + channels.length);
            
            container.empty();

            // Определяем количество колонок
            var isMobile = window.innerWidth < 768;
            var columns = isMobile ? 2 : 6;

            var grid = $('<div class="m3u-grid" style="display: grid; grid-template-columns: repeat(' + columns + ', 1fr); gap: 15px;"></div>');

            channels.forEach(function(channel, index) {
                var item = $(`
                    <div class="m3u-item" style="cursor: pointer; text-align: center; margin-bottom: 15px;">
                        <div style="position: relative; border-radius: 8px; overflow: hidden; background: #333;">
                            <img src="${channel.logo || 'img/empty.svg'}" 
                                 style="width: 100%; height: auto; display: block;" 
                                 onerror="this.src='img/empty.svg'"
                            />
                        </div>
                        <div style="margin-top: 8px; font-size: 12px; padding: 0 4px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                            ${channel.name}
                        </div>
                    </div>
                `);

                item.on('click', function() {
                    Lampa.Player.play({
                        url: channel.url,
                        title: channel.name,
                        poster: channel.logo
                    });
                });

                grid.append(item);
            });

            container.append(grid);
        };

        return comp.create();
    }
});

// Инициализируем плагин
Lampa.Plugin.init('m3u_loader');
