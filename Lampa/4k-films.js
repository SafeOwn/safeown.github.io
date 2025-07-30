(function () {
    const plugin = {
        name: 'M3U Loader',
        version: '1.0.0',
        description: 'Загрузка плейлиста M3U с обложками и адаптивным интерфейсом',
        init: function () {
            Lampa.Manifest.plugins.push({
                name: this.name,
                component: 'm3u_loader',
                title: 'M3U Плейлисты',
                icon: 'img/icons/menu/catalog.svg'
            });

            Lampa.Component.add('m3u_loader', this.render.bind(this));
        },

        render: function () {
            const html = $(`
                <div class="m3u-loader">
                    <div class="m3u-loader__header">Загрузка плейлиста...</div>
                    <div class="m3u-loader__content"></div>
                </div>
            `);

            const content = html.find('.m3u-loader__content');
            const playlistUrl = 'https://safeown.github.io/plvideo_4k_final.m3u';

            this.loadPlaylist(playlistUrl).then(channels => {
                html.find('.m3u-loader__header').text('Плейлист загружен');
                this.displayChannels(content, channels);
            }).catch(err => {
                html.find('.m3u-loader__header').text('Ошибка загрузки плейлиста');
                console.error(err);
            });

            return html;
        },

        loadPlaylist: async function (url) {
            const response = await fetch(url);
            const text = await response.text();

            const lines = text.split('\n');
            const channels = [];
            let currentChannel = null;

            for (let i = 0; i < lines.length; i++) {
                const line = lines[i].trim();

                if (line.startsWith('#EXTINF:')) {
                    const match = line.match(/tvg-logo="([^"]+)"/);
                    const logo = match ? match[1] : '';
                    const name = line.split(',').pop().trim();

                    currentChannel = { name, logo, url: '' };
                } else if (currentChannel && line.startsWith('http')) {
                    currentChannel.url = line;
                    channels.push(currentChannel);
                    currentChannel = null;
                }
            }

            return channels;
        },

        displayChannels: function (container, channels) {
            container.empty();

            const isMobile = Lampa.Utils.isMobile();
            const columns = isMobile ? 2 : 6;

            const grid = $(`<div class="m3u-grid" style="display: grid; grid-template-columns: repeat(${columns}, 1fr); gap: 15px;"></div>`);

            channels.forEach(channel => {
                const item = $(`
                    <div class="m3u-item" style="cursor: pointer; text-align: center;">
                        <img src="${channel.logo || 'img/empty.svg'}" style="width: 100%; height: auto; border-radius: 8px;" />
                        <div style="margin-top: 8px; font-size: 14px;">${channel.name}</div>
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
        }
    };

    plugin.init();
})();
