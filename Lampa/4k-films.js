// plugins/4k_iptv/index.js

(function () {
    'use strict';

    // --- ЖЕСТКО ЗАДАННЫЕ НАСТРОЙКИ ---
    const PLUGIN_COMPONENT = '4k_iptv'; // Внутреннее имя компонента
    const HARDCODED_NAME = '4kTV'; // Жестко заданное имя в меню
    const DEFAULT_PLAYLIST_URL = 'https://safeown.github.io/plvideo_4k_final.m3u'; // URL по умолчанию
    const SETTING_PLAYLIST_URL_NAME = PLUGIN_COMPONENT + '_playlist_url'; // Имя настройки для URL
    const SETTINGS_COMPONENT = PLUGIN_COMPONENT + '_settings'; // Имя компонента для настроек
    // -------------------------------

    // --- Основной объект плагина ---
    const plugin = {
        component: PLUGIN_COMPONENT,
        icon: "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 24\" fill=\"currentColor\"><path d=\"M8 5v14l11-7z\"/></svg>",
        name: HARDCODED_NAME
    };

    // --- Глобальные переменные ---
    let parsedItems = [];
    let encoder = $('<div/>');

    // --- Добавляем переводы ---
    Lampa.Lang.add({
        ru: {
            [PLUGIN_COMPONENT]: HARDCODED_NAME,
            [PLUGIN_COMPONENT + '_playlist_url']: 'URL плейлиста',
            [PLUGIN_COMPONENT + '_playlist_url_placeholder']: 'https://example.com/playlist.m3u',
            [SETTINGS_COMPONENT]: HARDCODED_NAME + ' Настройки',
            [PLUGIN_COMPONENT + '_menu_settings']: 'Настройки ' + HARDCODED_NAME,
            [PLUGIN_COMPONENT + '_save_settings']: 'Сохранить настройки'
        },
        en: {
            [PLUGIN_COMPONENT]: HARDCODED_NAME,
            [PLUGIN_COMPONENT + '_playlist_url']: 'Playlist URL',
            [PLUGIN_COMPONENT + '_playlist_url_placeholder']: 'https://example.com/playlist.m3u',
            [SETTINGS_COMPONENT]: HARDCODED_NAME + ' Settings',
            [PLUGIN_COMPONENT + '_menu_settings']: HARDCODED_NAME + ' Settings',
            [PLUGIN_COMPONENT + '_save_settings']: 'Save Settings'
        }
    });

    // --- Компонент страницы плагина ---
    function PluginPage(object) {
        this.activity = object;
        this.html = $('<div class="' + PLUGIN_COMPONENT + '-plugin-container"></div>');
        this.scroll = new Lampa.Scroll({ mask: true, over: true });
        this.last_focused_card = null;
    }

    PluginPage.prototype.create = function () {
        this.activity.loader(true);
        this.html.empty().append(this.scroll.render());
        this.loadAndParsePlaylist();
        return this.html;
    };

    PluginPage.prototype.loadAndParsePlaylist = function () {
        const playlistUrl = Lampa.Storage.get(SETTING_PLAYLIST_URL_NAME, DEFAULT_PLAYLIST_URL);
        console.log('[' + PLUGIN_COMPONENT + '] Loading playlist:', playlistUrl);

        if (!playlistUrl || typeof playlistUrl !== 'string' || !playlistUrl.trim().startsWith('http')) {
             console.error('[' + PLUGIN_COMPONENT + '] Invalid or empty playlist URL in settings.');
             this.showError('Invalid playlist URL. Check plugin settings.');
             return;
        }

        const network = new Lampa.Reguest();
        network.native(
            playlistUrl.trim(),
            (data) => {
                if (typeof data === 'string' && data.trim().startsWith('#EXTM3U')) {
                    parsedItems = this.parseM3U(data);
                    console.log('[' + PLUGIN_COMPONENT + '] Playlist loaded. Items:', parsedItems.length);
                    if (parsedItems.length > 0) {
                         this.buildPage();
                    } else {
                         this.showError('Playlist is empty.');
                    }
                } else {
                    console.error('[' + PLUGIN_COMPONENT + '] Data is not a valid M3U.');
                    this.showError('Loaded data is not a valid M3U playlist.');
                }
            },
            (error) => {
                console.error('[' + PLUGIN_COMPONENT + '] Playlist load error:', error);
                let errorMsg = 'Failed to load playlist.';
                if (error && error.status) errorMsg += ' HTTP ' + error.status;
                this.showError(errorMsg);
            },
            false,
            { dataType: 'text' }
        );
    };

    PluginPage.prototype.parseM3U = function (m3uString) {
        const lines = m3uString.split(/\r?\n/);
        const items = [];
        let currentItem = { title: '', url: '', 'tvg-logo': '' };

        for (let i = 0; i < lines.length; i++) {
            const line = lines[i].trim();
            if (line.startsWith('#EXTINF:')) {
                const titleMatch = line.match(/,(.*)$/);
                currentItem.title = titleMatch ? titleMatch[1].trim() : 'No Title';
                const logoMatch = line.match(/tvg-logo="([^"]*)"/i);
                currentItem['tvg-logo'] = logoMatch ? logoMatch[1] : '';
            } else if (line.startsWith('http') && line.includes('://')) {
                currentItem.url = line;
                if (currentItem.url) {
                    items.push({
                        title: currentItem.title || 'No Title',
                        url: currentItem.url,
                        'tvg-logo': currentItem['tvg-logo'] || ''
                    });
                    currentItem = { title: '', url: '', 'tvg-logo': '' };
                }
            }
        }
        return items;
    };

    PluginPage.prototype.buildPage = function () {
        const cards_container = $('<div class="' + PLUGIN_COMPONENT + '-cards-container"></div>');
        const styleId = PLUGIN_COMPONENT + '-styles';
        if (!$('#' + styleId).length) {
            $('body').append(`
                <style id="${styleId}">
                    .${PLUGIN_COMPONENT}-plugin-container { height: 100%; }
                    .${PLUGIN_COMPONENT}-cards-container {
                        display: flex; flex-wrap: wrap; padding: 1.5em; gap: 1.5em;
                    }
                    .${PLUGIN_COMPONENT}-card {
                        width: calc(50% - 0.75em); height: 250px;
                        position: relative; border-radius: 0.5em; overflow: hidden;
                        background-color: #2b2b2b; cursor: pointer; display: flex; flex-direction: column;
                        margin: 0 1.5em 1.5em 0;
                    }
                    .${PLUGIN_COMPONENT}-card:nth-child(2n) { margin-right: 0; }
                    .${PLUGIN_COMPONENT}-card__img-container {
                        width: 100%; flex-grow: 1; display: flex; align-items: center;
                        justify-content: center; background-color: #3a3a3a; overflow: hidden;
                        position: relative;
                    }
                    .${PLUGIN_COMPONENT}-card__img {
                        width: 100%; height: 100%; object-fit: cover; display: block;
                    }
                    .${PLUGIN_COMPONENT}-card__img-placeholder {
                        color: #aaa; font-size: 0.8em; text-align: center; padding: 0.5em;
                        box-sizing: border-box; display: flex; align-items: center;
                        justify-content: center; word-break: break-word;
                    }
                    .${PLUGIN_COMPONENT}-card__title {
                        padding: 0.5em; font-size: 1em; white-space: nowrap;
                        overflow: hidden; text-overflow: ellipsis;
                        background-color: rgba(0,0,0,0.5); margin: 0;
                    }
                    @media screen and (min-width: 768px) {
                        .${PLUGIN_COMPONENT}-card {
                            width: calc(16.666% - 1.25em); height: 300px;
                            margin: 0 1.5em 1.5em 0;
                        }
                        .${PLUGIN_COMPONENT}-card:nth-child(6n) { margin-right: 0; }
                    }
                </style>
            `);
        }

        parsedItems.forEach((item) => {
            let imgContent;
            const placeholderText = item.title.substring(0, 50) + (item.title.length > 50 ? '...' : '');
            if (item['tvg-logo']) {
                imgContent = `
                    <div class="${PLUGIN_COMPONENT}-card__img-container">
                        <img class="${PLUGIN_COMPONENT}-card__img" src="${item['tvg-logo']}" loading="lazy" alt="${encoder.text(item.title).html()}">
                        <div class="${PLUGIN_COMPONENT}-card__img-placeholder" style="display:none;">${encoder.text(placeholderText).html()}</div>
                    </div>
                `;
            } else {
                imgContent = `
                    <div class="${PLUGIN_COMPONENT}-card__img-container">
                        <div class="${PLUGIN_COMPONENT}-card__img-placeholder">${encoder.text(placeholderText).html()}</div>
                    </div>
                `;
            }

            const card = $(`
                <div class="${PLUGIN_COMPONENT}-card selector">
                    ${imgContent}
                    <div class="${PLUGIN_COMPONENT}-card__title">${encoder.text(item.title).html()}</div>
                </div>
            `);

            const imgElement = card.find(`.${PLUGIN_COMPONENT}-card__img`)[0];
            const placeholderElement = card.find(`.${PLUGIN_COMPONENT}-card__img-placeholder`);
            if (imgElement) {
                imgElement.onerror = () => {
                    console.log('[' + PLUGIN_COMPONENT + '] Image load error for:', item.title);
                    $(imgElement).hide();
                    placeholderElement.show();
                };
            }

            card.on('hover:enter', () => {
                console.log('[' + PLUGIN_COMPONENT + '] Playing:', item.title);
                Lampa.Player.play({ title: item.title, url: item.url });
            });

            cards_container.append(card);
        });

        this.scroll.append(cards_container);
        this.activity.loader(false);
        this.activity.toggle();
    };

    PluginPage.prototype.showError = function (message) {
        this.html.empty().append(`<div style="padding: 20px; color: #ff5555;">Error: ${message}</div>`);
        this.activity.loader(false);
        this.activity.toggle();
    };

    PluginPage.prototype.start = function () {
        Lampa.Controller.add('content', {
            toggle: () => {
                Lampa.Controller.collectionSet(this.scroll.render());
                Lampa.Controller.collectionFocus(this.last_focused_card || false, this.scroll.render());
            },
            left: () => { if (Navigator.canmove('left')) Navigator.move('left'); else Lampa.Controller.toggle('menu'); },
            right: () => { if (Navigator.canmove('right')) Navigator.move('right'); },
            up: () => { if (Navigator.canmove('up')) Navigator.move('up'); else Lampa.Controller.toggle('head'); },
            down: () => { if (Navigator.canmove('down')) Navigator.move('down'); },
            back: () => { Lampa.Activity.backward(); }
        });
        Lampa.Controller.toggle('content');
    };

    PluginPage.prototype.pause = function () { };
    PluginPage.prototype.stop = function () { };
    PluginPage.prototype.render = function () { return this.html; };
    PluginPage.prototype.destroy = function () {
        console.log('[' + PLUGIN_COMPONENT + '] Plugin page destroyed.');
        this.scroll.destroy();
        this.html.remove();
        const styleId = PLUGIN_COMPONENT + '-styles';
        $('#' + styleId).remove();
    };

    // --- Компонент для страницы настроек ---
    function SettingsPage(object) {
        this.activity = object;
        this.html = $('<div></div>');
        this.scroll = new Lampa.Scroll({ mask: true, over: true });
    }

    SettingsPage.prototype.create = function () {
        const settings_body = $('<div class="settings settings--iptv"></div>');
        const current_url = Lampa.Storage.get(SETTING_PLAYLIST_URL_NAME, DEFAULT_PLAYLIST_URL);

        const url_title = $('<div class="settings-param-title"><span>' + Lampa.Lang.translate(PLUGIN_COMPONENT + '_playlist_url') + '</span></div>');
        const url_input = $(`<div class="settings-param selector">
            <div class="settings-param__name">` + Lampa.Lang.translate(PLUGIN_COMPONENT + '_playlist_url') + `</div>
            <div class="settings-param__value">` + (current_url || '---') + `</div>
            <input class="settings-param__input" type="text" placeholder="` + Lampa.Lang.translate(PLUGIN_COMPONENT + '_playlist_url_placeholder') + `" value="` + (current_url || '') + `">
        </div>`);
        const url_value = url_input.find('.settings-param__value');
        const url_field = url_input.find('.settings-param__input');

        url_input.on('hover:enter', function(){
            Lampa.Input.edit({
                value: url_field.val(),
                free: true,
                title: Lampa.Lang.translate(PLUGIN_COMPONENT + '_playlist_url')
            }, function (new_value){
                url_field.val(new_value || '');
                url_value.text(new_value || '---');
                Lampa.Controller.toggle('content');
            });
        });

        const save_button = $('<div class="settings-param selector"><div class="settings-param__name">' + Lampa.Lang.translate(PLUGIN_COMPONENT + '_save_settings') + '</div></div>');
        save_button.on('hover:enter', () => {
            const new_url = url_field.val().trim();
            Lampa.Storage.set(SETTING_PLAYLIST_URL_NAME, new_url || '');
            Lampa.Notifications.show('Settings saved', 3000);
            console.log('[' + PLUGIN_COMPONENT + '] Settings saved. New URL:', new_url);
            Lampa.Controller.toggle('content');
        });

        settings_body.append(url_title).append(url_input).append(save_button);
        this.scroll.append(settings_body);
        this.html.append(this.scroll.render());

        this.activity.loader(false);
        this.activity.toggle();
        return this.html;
    };

    SettingsPage.prototype.start = function () {
        Lampa.Controller.add('content', {
            toggle: () => {
                Lampa.Controller.collectionSet(this.scroll.render());
                Lampa.Controller.collectionFocus(false, this.scroll.render());
            },
            up: () => { if (Navigator.canmove('up')) Navigator.move('up'); else Lampa.Controller.toggle('head'); },
            down: () => { if (Navigator.canmove('down')) Navigator.move('down'); },
            back: () => { Lampa.Activity.backward(); }
        });
        Lampa.Controller.toggle('content');
    };

    SettingsPage.prototype.pause = function () { };
    SettingsPage.prototype.stop = function () { };
    SettingsPage.prototype.render = function () { return this.html; };
    SettingsPage.prototype.destroy = function () {
        console.log('[' + PLUGIN_COMPONENT + '] Settings page destroyed.');
        this.scroll.destroy();
        this.html.remove();
    };

    // --- Инициализация ---
    function initPlugin() {
        console.log('[' + PLUGIN_COMPONENT + '] Initializing plugin.');

        Lampa.Component.add(plugin.component, PluginPage);
        Lampa.Component.add(SETTINGS_COMPONENT, SettingsPage);

        // Пункт меню для плагина
        const menuEl = $('<li class="menu__item selector js-' + plugin.component + '-menu0">'
                    + '<div class="menu__ico">' + plugin.icon + '</div>'
                    + '<div class="menu__text js-' + plugin.component + '-menu0-title">'
                        + encoder.text(plugin.name).html()
                    + '</div>'
                + '</li>')
        .on('hover:enter', function(){
            console.log('[' + PLUGIN_COMPONENT + '] Opening plugin page.');
            Lampa.Activity.push({ component: plugin.component });
        });

        // Пункт меню для настроек
        const settingsMenuEl = $('<li class="menu__item selector">'
                    + '<div class="menu__ico"><svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="currentColor"><path d="M12,15.5A3.5,3.5 0 0,1 8.5,12A3.5,3.5 0 0,1 12,8.5A3.5,3.5 0 0,1 15.5,12A3.5,3.5 0 0,1 12,15.5M19.43,12.97C19.47,12.65 19.5,12.33 19.5,12C19.5,11.67 19.47,11.34 19.43,11L21.54,9.37C21.73,9.22 21.78,8.95 21.66,8.73L19.66,5.27C19.54,5.05 19.27,4.96 19.05,5.05L16.56,6.05C16.04,5.66 15.5,5.32 14.87,5.07L14.5,2.42C14.46,2.18 14.25,2 14,2H10C9.75,2 9.54,2.18 9.5,2.42L9.13,5.07C8.5,5.32 7.96,5.66 7.44,6.05L4.95,5.05C4.73,4.96 4.46,5.05 4.34,5.27L2.34,8.73C2.21,8.95 2.27,9.22 2.46,9.37L4.57,11C4.53,11.34 4.5,11.67 4.5,12C4.5,12.33 4.53,12.65 4.57,12.97L2.46,14.63C2.27,14.78 2.21,15.05 2.34,15.27L4.34,18.73C4.46,18.95 4.73,19.03 4.95,18.95L7.44,17.94C7.96,18.34 8.5,18.68 9.13,18.93L9.5,21.58C9.54,21.82 9.75,22 10,22H14C14.25,22 14.46,21.82 14.5,21.58L14.87,18.93C15.5,18.67 16.04,18.34 16.56,17.94L19.05,18.95C19.27,19.03 19.54,18.95 19.66,18.73L21.66,15.27C21.78,15.05 21.73,14.78 21.54,14.63L19.43,12.97Z" /></svg></div>'
                    + '<div class="menu__text">' + encoder.text(Lampa.Lang.translate(PLUGIN_COMPONENT + '_menu_settings')).html() + '</div>'
                + '</li>')
        .on('hover:enter', function(){
            console.log('[' + PLUGIN_COMPONENT + '] Opening settings page.');
            Lampa.Activity.push({ component: SETTINGS_COMPONENT }); // Исправлено: было просто component: SETTINGS_COMPONENT
        });

        function pluginStart() {
            if (!!window['plugin_' + plugin.component + '_ready']) return;
            window['plugin_' + plugin.component + '_ready'] = true;
            var menu = $('.menu .menu__list').eq(0);
            menu.append(menuEl).append(settingsMenuEl);
            console.log('[' + PLUGIN_COMPONENT + '] Menu items added.');
        }

        if (!!window.appready) {
            pluginStart();
        } else {
            Lampa.Listener.follow('app', function(e){
                if (e.type === 'ready') pluginStart();
            });
        }
    }

    if (window.Lampa) {
        initPlugin();
    } else {
        window.addEventListener('load', function(){ initPlugin(); });
    }

})();
