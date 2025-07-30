(function () {
    const plugin = {
        name: 'm3u_loader',
        version: '1.0.0',
        description: 'Загрузка M3U плейлиста с обложками',

        init: function () {
            // Регистрация плагина в системе
            if (typeof Lampa !== 'undefined') {
                Lampa.Listener.follow('app', (e) => {
                    if (e.type === 'ready') {
                        this.addMenuItem();
                    }
                });
            }
        },

        addMenuItem: function () {
            Lampa.Manifest.plugins.push({
                name: this.name,
                component: 'm3u_loader',
                title: 'M3U Плейлисты',
                icon: 'img/icons/menu/catalog.svg'
            });

            Lampa.Component.add('m3u_loader', this.component.bind(this));
        },

        component: function () {
            const comp = new Lampa.Component();
            
            comp.create = function () {
                this.activity = new Lampa.Activity({
                    component: 'm3u_loader',
                    template: this.template.bind(this),
                    onBack: () => {
                        Lampa.Activity.out();
                    }
                });

                this.activity.render();

                this.loadContent();

                return this.activity;
            };

            comp.template = function () {
                return $(`
                    <div class="m3u-loader">
                        <div class="m3u-loader__header" style="padding: 20px; text-align: center; font-size: 18px;">
                            Загрузка плейлиста...
                        </div>
                        <div class="m3u-loader__content" style="padding: 0 20px 20px;"></div>
                    </div>
                `);
            };

            comp.loadContent = function () {
                const playlistUrl = 'https://safeown.github.io/plvideo_4k_final.m3u';
                
                this.activity.loader(true);

                this.loadPlaylist(playlistUrl)
                    .then(channels => {
                        this.activity.loader(false);
                        this.displayChannels(channels);
                    })
                    .catch(err => {
                        this.activity.loader(false);
                        this.activity.render().find('.m3u-loader__header').text('Ошибка загрузки плейлиста');
                        console.error('M3U Loader Error:', err);
                    });
            };

            comp.loadPlaylist = async function (url) {
                try {
                    const response = await fetch(url);
                    if (!response.ok) throw new Error('Network response was not ok');
                    
                    const text = await response.text();
                    const lines = text.split('\n');
                    const channels = [];
                    let currentChannel = null;

                    for (let i = 0; i < lines.length; i++) {
                        const line = lines[i].trim();

                        if (line.startsWith('#EXTINF:')) {
                            const logoMatch = line.match(/tvg-logo="([^"]+)"/);
                            const nameMatch = line.split(',').pop();
                            
                            const logo = logoMatch ? logoMatch[1] : '';
                            const name = nameMatch ? nameMatch.trim() : 'Без названия';

                            currentChannel = { name, logo, url: '' };
                        } else if (currentChannel && line.startsWith('http')) {
                            currentChannel.url = line;
                            channels.push(currentChannel);
                            currentChannel = null;
                        }
                    }

                    return channels;
                } catch (error) {
                    throw new Error('Failed to load playlist: ' + error.message);
                }
            };

            comp.displayChannels = function (channels) {
                const container = this.activity.render().find('.m3u-loader__content');
                const header = this.activity.render().find('.m3u-loader__header');
                
                header.text(`Загружено каналов: ${channels.length}`);
                
                container.empty();

                const isMobile = window.innerWidth < 768;
                const columns = isMobile ? 2 : 6;

                const grid = $(`<div class="m3u-grid" style="display: grid; grid-template-columns: repeat(${columns}, 1fr); gap: 15px;"></div>`);

                channels.forEach((channel, index) => {
                    const item = $(`
                        <div class="m3u-item" data-index="${index}" style="cursor: pointer; text-align: center; margin-bottom: 10px;">
                            <div style="position: relative; overflow: hidden; border-radius: 8px;">
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

                    item.on('click', () => {
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
    };

    // Инициализация плагина после загрузки Lampa
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', () => plugin.init());
    } else {
        plugin.init();
    }
})();
