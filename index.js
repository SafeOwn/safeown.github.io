(function () {
    'use strict';

    // Имя плагина
    const PLUGIN_NAME = 'M3U Loader';

    // Добавляем переводы
    Lampa.Lang.add({
        ru: {
            'm3u_loader': 'M3U Плеер',
            'm3u_search': 'Поиск в M3U'
        },
        en: {
            'm3u_loader': 'M3U Player',
            'm3u_search': 'Search in M3U'
        }
        // Добавьте другие языки при необходимости
    });

    // Основной класс плагина
    function M3ULoader() {
        this.playlist = [];
    }

    M3ULoader.prototype.init = function () {
        console.log('Plugin M3U Loader initialized');

        // Добавляем пункт в главное меню
        Lampa.Manifest.plugins.push({
            name: 'm3u_loader',
            title: Lampa.Lang.translate('m3u_loader'),
            // Используем стандартную иконку, можно заменить на свою
            icon: '<svg viewBox="0 0 24 24" fill="currentColor"><path d="M8 5v14l11-7z"/></svg>',
            page: () => this.openPage()
        });

        // Интеграция в глобальный поиск
        Lampa.Search.addSource({
            title: Lampa.Lang.translate('m3u_search'),
            search: (query, call) => this.search(query, call)
        });
    };

    M3ULoader.prototype.openPage = function () {
        const page = Lampa.Page.build('m3u_loader');
        page.title = Lampa.Lang.translate('m3u_loader');

        // --- Загрузка и парсинг плейлиста ---
        const playlistURL = 'https://iptv-org.github.io/iptv/categories/movies.m3u'; // Пример URL
        // ВАЖНО: Убедитесь, что URL доступен и не блокируется CORS для вашего домена.
        // Для тестирования лучше использовать публичные плейлисты или настроить CORS-прокси.

        const network = new Lampa.Reguest(); // Используем встроенный HTTP клиент Lampa

        network.native( // Используем native для прямого запроса
            playlistURL,
            (data) => { // Успех
                if (typeof data === 'string' && data.trim().startsWith('#EXTM3U')) {
                    this.playlist = this.parseM3U(data);
                    this.renderItems(page);
                } else {
                     console.error('M3ULoader: Полученные данные не являются корректным M3U плейлистом.');
                     this.showError(page, 'Полученные данные не являются корректным M3U плейлистом.');
                }
            },
            (error) => { // Ошибка
                console.error('M3ULoader: Ошибка загрузки плейлиста:', error);
                 this.showError(page, 'Ошибка загрузки плейлиста: ' + (error.statusText || error.message || 'Неизвестная ошибка'));
            },
            false, // cache
            { dataType: 'text' } // Ожидаем текстовый ответ
        );
        // --- Конец загрузки ---

        Lampa.Activity.push({
            page: page,
            title: Lampa.Lang.translate('m3u_loader')
        });
    };

    M3ULoader.prototype.parseM3U = function(m3uString) {
         const lines = m3uString.split('\n');
         let items = [];
         let currentTitle = '';
         let currentUrl = '';

         for (let i = 0; i < lines.length; i++) {
             const line = lines[i].trim();

             if (line.startsWith('#EXTINF:')) {
                 // Извлекаем название
                 const titleMatch = line.match(/,(.*)$/);
                 currentTitle = titleMatch ? titleMatch[1].trim() : 'Без названия';
             } else if (line.startsWith('http') && line.includes('://')) { // Более точная проверка URL
                 currentUrl = line;
                 if (currentUrl) { // Добавляем только если есть URL
                     items.push({
                         title: currentTitle || 'Без названия',
                         url: currentUrl
                         // Можно добавить другие поля, если они есть в EXTINF
                     });
                     // Сброс для следующего элемента
                     currentTitle = '';
                     currentUrl = '';
                 }
             }
             // Игнорируем другие строки (#EXTM3U, #EXTGRP и т.д.)
         }
         console.log('M3ULoader: Распарсено элементов:', items.length);
         return items;
    };

    M3ULoader.prototype.renderItems = function(page) {
         const container = Lampa.Template.get('items', {
             items: this.playlist,
             card_events: (item) => {
                 console.log('M3ULoader: Воспроизведение', item.title, item.url);
                 Lampa.Player.play({
                     url: item.url,
                     title: item.title
                     // Добавьте другие параметры плеера, если нужно (poster, subtitles и т.д.)
                 });
             }
         });

         // Очищаем страницу и добавляем контент
         page.render().empty();
         page.append(container.render());
    };

     M3ULoader.prototype.showError = function(page, message) {
          const errorEl = $(`<div style="padding: 20px; color: red;">Ошибка: ${message}</div>`);
          page.render().empty();
          page.append(errorEl);
     };

    M3ULoader.prototype.search = function (query, callback) {
        if (!this.playlist || this.playlist.length === 0) {
             callback([]); // Нечего искать
             return;
        }

        const results = this.playlist.filter(item =>
            item.title.toLowerCase().includes(query.toLowerCase())
        ).map(item => ({
            title: item.title,
            // year: 0, // Если есть год, добавьте
            // genres: ['M3U'], // Если есть жанры, добавьте
            // poster: item.poster || '', // Если есть постер, добавьте
            onEnter: () => {
                Lampa.Player.play({
                    url: item.url,
                    title: item.title
                });
            }
        }));

        callback(results);
    };

    // Инициализация плагина после загрузки Lampa
    if (window.Lampa) {
        new M3ULoader().init();
    } else {
        window.addEventListener('load', () => {
            new M3ULoader().init();
        });
    }

})();
