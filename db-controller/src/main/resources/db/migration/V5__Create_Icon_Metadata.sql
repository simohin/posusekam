-- Создание таблицы метаданных иконок
CREATE TABLE icon_metadata (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) UNIQUE NOT NULL,
    display_name VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL,
    category VARCHAR(50) NOT NULL,
    keywords TEXT NOT NULL
);

-- Shopping & Retail
INSERT INTO icon_metadata (name, display_name, type, category, keywords) VALUES
('storefront.fill', 'Магазин', 'SF_SYMBOL', 'SHOPPING', 'магазин супермаркет лавка маркет универмаг витрина ларек storefront market shop'),
('cart.fill', 'Тележка', 'SF_SYMBOL', 'SHOPPING', 'тележка корзина телега покупки супермаркет cart trolley shopping'),
('bag.fill', 'Пакет', 'SF_SYMBOL', 'SHOPPING', 'пакет сумка шопер покупки bag shopper package'),
('basket.fill', 'Корзинка', 'SF_SYMBOL', 'SHOPPING', 'корзина лукошко корзинка продукты basket'),
('shippingbox.fill', 'Коробка', 'SF_SYMBOL', 'SHOPPING', 'коробка ящик посылка склад короб доставка почта box package shipping'),
('tag.fill', 'Ценник', 'SF_SYMBOL', 'SHOPPING', 'тег бирка этикетка скидка акция цена ценник tag label price'),
('creditcard.fill', 'Карта', 'SF_SYMBOL', 'SHOPPING', 'карта кредитка оплата деньги банк безнал credit card payment money bank'),
('gift.fill', 'Подарок', 'SF_SYMBOL', 'SHOPPING', 'подарок презент праздник сюрприз коробка gift present surprise'),
('percent', 'Процент', 'SF_SYMBOL', 'SHOPPING', 'процент скидка акция распродажа дешево percent discount sale'),
('barcode', 'Штрихкод', 'SF_SYMBOL', 'SHOPPING', 'штрихкод код сканер цена товар barcode'),
('banknote.fill', 'Банкнота', 'SF_SYMBOL', 'SHOPPING', 'купюра деньги наличные кэш валюта доллар рубль banknote cash money'),
('coins.fill', 'Монеты', 'SF_SYMBOL', 'SHOPPING', 'монеты деньги мелочь золото сдача coins cents money cash');

-- Food & Groceries
INSERT INTO icon_metadata (name, display_name, type, category, keywords) VALUES
('carrot.fill', 'Морковь', 'SF_SYMBOL', 'FOOD', 'морковь овощи еда веган грядка полезно carrot vegetable food'),
('leaf.fill', 'Лист', 'SF_SYMBOL', 'FOOD', 'лист зелень чай веган салат трава природа растение leaf green tea'),
('fish.fill', 'Рыба', 'SF_SYMBOL', 'FOOD', 'рыба морепродукты мясо рыбалка река океан еда fish seafood'),
('wineglass.fill', 'Бокал', 'SF_SYMBOL', 'FOOD', 'бокал вино бар алкоголь ресторан стекло напитки wine glass alcohol'),
('mug.fill', 'Пиво', 'SF_SYMBOL', 'FOOD', 'кружка пиво чай кофе бар паб бокал mug beer ale pub'),
('cup.and.saucer.fill', 'Чашка', 'SF_SYMBOL', 'FOOD', 'чашка чай кофе блюдце кафе завтрак кружка cup tea coffee cafe'),
('birthday.cake.fill', 'Торт', 'SF_SYMBOL', 'FOOD', 'торт пирог пирожное сладкое десерт день рождения праздник выпечка cake birthday'),
('fork.knife', 'Приборы', 'SF_SYMBOL', 'FOOD', 'приборы вилка нож еда ресторан столовая кухня посуда fork knife food cutlery'),
('takeoutbag.and.cup.and.straw.fill', 'Фастфуд', 'SF_SYMBOL', 'FOOD', 'фастфуд еда с собой макдональдс бургер кофе доставка кола стакан takeout fastfood burger'),
('oven.fill', 'Плита', 'SF_SYMBOL', 'FOOD', 'плита кухня готовка варка плитка cook stove kitchen oven'),
('archivebox.fill', 'Холодильник', 'SF_SYMBOL', 'FOOD', 'холодильник кухня холод хранение заморозка fridge refrigerator archivebox'),
('drop.fill', 'Бутылка', 'SF_SYMBOL', 'FOOD', 'бутылка вино алкоголь напитки водка пиво сок bottle wine alcohol drink drop');

-- Household & Life
INSERT INTO icon_metadata (name, display_name, type, category, keywords) VALUES
('house.fill', 'Дом', 'SF_SYMBOL', 'HOUSEHOLD', 'дом дача коттедж здание жилье квартира house home building'),
('bed.double.fill', 'Кровать', 'SF_SYMBOL', 'HOUSEHOLD', 'кровать спальня сон отель мебель спать bed double sleep room'),
('sofa.fill', 'Диван', 'SF_SYMBOL', 'HOUSEHOLD', 'диван гостиная мебель отдых кресло sofa couch furniture'),
('lamp.floor.fill', 'Торшер', 'SF_SYMBOL', 'HOUSEHOLD', 'лампа торшер свет мебель освещение светильник lamp light floor'),
('shower.fill', 'Душ', 'SF_SYMBOL', 'HOUSEHOLD', 'душ ванная вода гигиена мытье shower water bathroom'),
('bathtub.fill', 'Ванна', 'SF_SYMBOL', 'HOUSEHOLD', 'ванна ванная купание гигиена мытье bath bathtub bathroom'),
('key.fill', 'Ключ', 'SF_SYMBOL', 'HOUSEHOLD', 'ключ замок дверь сейф доступ key door lock'),
('lock.fill', 'Замок', 'SF_SYMBOL', 'HOUSEHOLD', 'замок безопасность сейф защита закрыто lock safe security'),
('teddybear.fill', 'Игрушка', 'SF_SYMBOL', 'HOUSEHOLD', 'мишка игрушка ребенок детское плюшевый медведь toy teddy bear kid child'),
('house.and.flag.fill', 'Усадьба', 'SF_SYMBOL', 'HOUSEHOLD', 'дача усадьба загородный дом флаг участок коттедж house flag land'),
('toilet', 'Туалет', 'SF_SYMBOL', 'HOUSEHOLD', 'туалет санузел уборная гигиена бумага унитаз toilet restroom wc');

-- Tools & Construction
INSERT INTO icon_metadata (name, display_name, type, category, keywords) VALUES
('hammer.fill', 'Молоток', 'SF_SYMBOL', 'TOOLS', 'молоток инструменты ремонт стройка гвоздь hammer tools repair'),
('screwdriver.fill', 'Отвертка', 'SF_SYMBOL', 'TOOLS', 'отвертка инструменты ремонт монтаж шуруп screwdriver tools repair'),
('wrench.fill', 'Ключ', 'SF_SYMBOL', 'TOOLS', 'ключ гаечный ремонт авто сантехника инструменты wrench spanner repair auto'),
('gear', 'Настройки', 'SF_SYMBOL', 'TOOLS', 'шестеренка настройки механизм ремонт детали шестерня gear settings cog wheel'),
('ruler.fill', 'Линейка', 'SF_SYMBOL', 'TOOLS', 'линейка метр измерение ремонт чертеж рулетка ruler scale measure'),
('scissors', 'Ножницы', 'SF_SYMBOL', 'TOOLS', 'ножницы шитье канцелярия стрижка резать scissors cut paper fabric'),
('paintpalette.fill', 'Краски', 'SF_SYMBOL', 'TOOLS', 'палитра краски рисование искусство декор ремонт paint palette art color'),
('brush.fill', 'Кисть', 'SF_SYMBOL', 'TOOLS', 'кисть маляр ремонт покраска рисование стена кисточка brush paint art'),
('flashlight.on.fill', 'Фонарь', 'SF_SYMBOL', 'TOOLS', 'фонарик свет темнота туризм поход батарейка flashlight torch light'),
('car.fill', 'Машина', 'SF_SYMBOL', 'TOOLS', 'машина автомобиль гараж автосервис запчасти колеса car vehicle auto garage'),
('bolt.fill', 'Энергия', 'SF_SYMBOL', 'TOOLS', 'болт молния энергия электричество зарядка ток питание свет bolt energy power lightning');

-- Apparel & Fashion
INSERT INTO icon_metadata (name, display_name, type, category, keywords) VALUES
('tshirt.fill', 'Одежда', 'SF_SYMBOL', 'APPAREL', 'футболка одежда вещи гардероб мода стиль майка tshirt clothes wear fashion'),
('shoe.fill', 'Обувь', 'SF_SYMBOL', 'APPAREL', 'обувь кроссовки ботинки туфли спорт кеды сапоги shoe sneakers boots foot'),
('comb.fill', 'Груминг', 'SF_SYMBOL', 'APPAREL', 'расческа волосы красота уход парикмахер comb hair beauty style'),
('crown.fill', 'Люкс', 'SF_SYMBOL', 'APPAREL', 'корона роскошь золото украшения ювелир элита королева король crown gold luxury jewel'),
('eyeglasses', 'Очки', 'SF_SYMBOL', 'APPAREL', 'очки зрение оптика аксессуары линзы eyeglasses glasses optic read'),
('handbag.fill', 'Сумка', 'SF_SYMBOL', 'APPAREL', 'сумка сумочка аксессуары женское мода handbag bag fashion purse'),
('hat.backpack.fill', 'Рюкзак', 'SF_SYMBOL', 'APPAREL', 'рюкзак шляпа туризм одежда поход портфель ранец backpack hat travel bag');

-- Hobbies & Entertainment
INSERT INTO icon_metadata (name, display_name, type, category, keywords) VALUES
('tv.fill', 'ТВ', 'SF_SYMBOL', 'HOBBIES', 'телевизор тв экран видео гостиная кино tv television screen movie show'),
('gamecontroller.fill', 'Игры', 'SF_SYMBOL', 'HOBBIES', 'джойстик геймпад приставка игры консоль джостик плойка xbox nintendo play game controller gamepad console'),
('headphones', 'Наушники', 'SF_SYMBOL', 'HOBBIES', 'наушники музыка звук аудио наушники беспроводные headphones music audio sound'),
('book.fill', 'Книги', 'SF_SYMBOL', 'HOBBIES', 'книга чтение учебник библиотека знания литература учебники book read library school study'),
('music.note', 'Музыка', 'SF_SYMBOL', 'HOBBIES', 'нота музыка песня радио аудио трек мелодия music note song audio melody'),
('guitar.fill', 'Гитара', 'SF_SYMBOL', 'HOBBIES', 'гитара инструмент музыка рок акустика гитарный guitar music rock instrument'),
('camera.fill', 'Камера', 'SF_SYMBOL', 'HOBBIES', 'камера фотоаппарат фото видео объектив снимок фотик camera photo video shot'),
('printer.fill', 'Печать', 'SF_SYMBOL', 'HOBBIES', 'принтер печать бумага офис документы копия сканер printer print paper office doc'),
('desktopcomputer', 'Компьютер', 'SF_SYMBOL', 'HOBBIES', 'компьютер пк монитор офис работа дисплей моноблок desktop computer pc monitor office'),
('laptopcomputer', 'Ноутбук', 'SF_SYMBOL', 'HOBBIES', 'ноутбук ноут компьютер работа учеба макбук laptop computer macbook notebook work'),
('iphone', 'Смартфон', 'SF_SYMBOL', 'HOBBIES', 'телефон айфон смартфон связь звонок мобильный iphone phone mobile cell call'),
('puzzlepiece.fill', 'Пазл', 'SF_SYMBOL', 'HOBBIES', 'пазл деталь игрушки хобби мозаика puzzle piece toy hobby game');

-- Sport & Outdoor
INSERT INTO icon_metadata (name, display_name, type, category, keywords) VALUES
('football.fill', 'Спорт', 'SF_SYMBOL', 'SPORT', 'футбол мяч спорт игра матч стадион тренировка football ball soccer sport'),
('bicycle', 'Велосипед', 'SF_SYMBOL', 'SPORT', 'велосипед велик транспорт спорт прогулка велосипедный велобайк bicycle bike cycle'),
('tent.fill', 'Палатка', 'SF_SYMBOL', 'SPORT', 'палатка кемпинг туризм поход лес природа костер tent camping travel forest'),
('umbrella.fill', 'Зонт', 'SF_SYMBOL', 'SPORT', 'зонт зонтик дождь погода осень сырость защита от дождя umbrella rain weather'),
('sun.max.fill', 'Солнце', 'SF_SYMBOL', 'SPORT', 'солнце лето жара погода пляж тепло свет sun summer hot weather'),
('cloud.rain.fill', 'Осадки', 'SF_SYMBOL', 'SPORT', 'облако дождь погода туча сырость пасмурно cloud rain weather wet'),
('snowflake', 'Снег', 'SF_SYMBOL', 'SPORT', 'снежинка снег зима холод мороз лед лыжи snowflake snow winter cold ice'),
('flame.fill', 'Огонь', 'SF_SYMBOL', 'SPORT', 'огонь костер пламя тепло обогрев печка пожар flame fire hot burn stove'),
('binoculars.fill', 'Бинокль', 'SF_SYMBOL', 'SPORT', 'бинокль охота туризм обзор птицы binoculars hunt travel view');

-- Pharmacy & Health
INSERT INTO icon_metadata (name, display_name, type, category, keywords) VALUES
('pills.fill', 'Аптека', 'SF_SYMBOL', 'HEALTH', 'таблетки лекарства пилюли аптека здоровье витамины рецепт больница pills medicine pharmacy health vitamins'),
('cross.case.fill', 'Аптечка', 'SF_SYMBOL', 'HEALTH', 'аптечка чемодан медицина доктор первая помощь крест скорая cross case medical doctor aid'),
('bandage.fill', 'Пластырь', 'SF_SYMBOL', 'HEALTH', 'пластырь бинт рана медицина первая помощь bandage plaster medical'),
('stethoscope', 'Доктор', 'SF_SYMBOL', 'HEALTH', 'стетоскоп врач медицина здоровье больница поликлиника терапевт stethoscope doctor medical health clinic'),
('heart.text.square.fill', 'Рецепт', 'SF_SYMBOL', 'HEALTH', 'рецепт медкарта здоровье сердце доктор обследование анализы heart medical record health prescription card');

-- Miscellaneous SF Symbols
INSERT INTO icon_metadata (name, display_name, type, category, keywords) VALUES
('heart.fill', 'Любимое', 'SF_SYMBOL', 'MISC', 'сердце любовь избранное лайк нравится симпатия heart love like favorite'),
('star.fill', 'Звезда', 'SF_SYMBOL', 'MISC', 'закладка сохранить книга избранное пометка bookmark save read'),
('bookmark.fill', 'Закладка', 'SF_SYMBOL', 'MISC', 'звезда рейтинг избранное популярно оценка топ star favorite rating top'),
('bell.fill', 'Звонок', 'SF_SYMBOL', 'MISC', 'колокольчик уведомление звонок напоминание будильник оповещение bell notification alarm ring alert'),
('magnifyingglass', 'Поиск', 'SF_SYMBOL', 'MISC', 'лупа поиск найти разглядеть magnifying glass search find zoom'),
('info.circle.fill', 'Инфо', 'SF_SYMBOL', 'MISC', 'инфо информация справка помощь детали о приложении info details information help'),
('doc.fill', 'Документ', 'SF_SYMBOL', 'MISC', 'документ файл лист бумага отчет договор doc file paper page report'),
('folder.fill', 'Папка', 'SF_SYMBOL', 'MISC', 'папка файлы документы архив каталоги хранилище folder file catalog directory storage');

-- Emojis - Food & Drinks
INSERT INTO icon_metadata (name, display_name, type, category, keywords) VALUES
('🥩', 'Мясо', 'EMOJI', 'FOOD', 'мясо стейк говядина свинина свиной баранина отбивная филе еда порция meat steak pork beef food'),
('🍗', 'Курица', 'EMOJI', 'FOOD', 'курица птица окорочок ножка гриль еда птица куриный цыпленок chicken poultry food'),
('🐟', 'Рыба', 'EMOJI', 'FOOD', 'рыба лосось морепродукты форель филе улов еда рыбалка fish seafood food'),
('🍞', 'Хлеб', 'EMOJI', 'FOOD', 'хлеб батон булка выпечка тесто пекарня хлебобулочные хлебный bread bakery'),
('🥛', 'Молоко', 'EMOJI', 'FOOD', 'молоко кефир стакан напиток молочный сливки корова milk drink'),
('🧀', 'Сыр', 'EMOJI', 'FOOD', 'сыр молочные сырный моцарелла пармезан еда cheese food'),
('🥚', 'Яйца', 'EMOJI', 'FOOD', 'яйцо яйца яичница белок желток завтрак egg eggs'),
('🍎', 'Яблоко', 'EMOJI', 'FOOD', 'яблоко фрукт фрукты красное плод сад apple fruit red'),
('🍌', 'Банан', 'EMOJI', 'FOOD', 'банан фрукт фрукты желтый бананы banana fruit yellow'),
('🥕', 'Морковь', 'EMOJI', 'FOOD', 'морковь овощи морковка веган полезно carrot vegetable'),
('🥔', 'Картофель', 'EMOJI', 'FOOD', 'картофель картошка овощи фри пюре веган potato vegetable'),
('🍅', 'Помидор', 'EMOJI', 'FOOD', 'помидор томат овощи салат веган помидоры tomato vegetable'),
('🥒', 'Огурец', 'EMOJI', 'FOOD', 'огурец огурцы овощи салат веган свежий cucumber vegetable'),
('🍄', 'Грибы', 'EMOJI', 'FOOD', 'гриб грибы шампиньон лес mushroom'),
('🍬', 'Конфеты', 'EMOJI', 'FOOD', 'конфета конфеты сладости сладкое карамель леденец candy sweet'),
('🍰', 'Пирожное', 'EMOJI', 'FOOD', 'пирожное торт десерт сладкое выпечка кусок торта cake sweet bakery'),
('☕', 'Кофе', 'EMOJI', 'FOOD', 'кофе чай чашка напиток кафе эспрессо капучино кружка coffee tea drink cup'),
('🥤', 'Напитки', 'EMOJI', 'FOOD', 'газировка кола сок напиток стакан трубочка лимонад drink soda juice'),
('🍷', 'Вино', 'EMOJI', 'FOOD', 'вино бокал бутылка алкоголь бар ресторан красный белый wine glass alcohol'),
('🍺', 'Пиво', 'EMOJI', 'FOOD', 'пиво бокал кружка эль бар паб пивной алкоголь beer ale mug alcohol');

-- Emojis - Household & Goods
INSERT INTO icon_metadata (name, display_name, type, category, keywords) VALUES
('🧼', 'Мыло', 'EMOJI', 'HOUSEHOLD', 'мыло гигиена чистота ванная пена мыть soap clean hygiene bathroom'),
('🧻', 'Бумага', 'EMOJI', 'HOUSEHOLD', 'туалетная бумага рулон салфетки гигиена чистота toilet paper roll hygiene'),
('🧹', 'Веник', 'EMOJI', 'HOUSEHOLD', 'веник метла уборка чистота прибираться мусор broom clean sweep'),
('🧺', 'Корзина', 'EMOJI', 'HOUSEHOLD', 'корзина белье стирка корзинка вещи лукошко laundry basket wash'),
('🧯', 'Огнетушитель', 'EMOJI', 'HOUSEHOLD', 'огнетушитель пожар безопасность защита тушение fire extinguisher safety'),
('🕯️', 'Свеча', 'EMOJI', 'HOUSEHOLD', 'свеча свет огарок воск уют candle light wax'),
('🔌', 'Электрика', 'EMOJI', 'HOUSEHOLD', 'вилка розетка провод ток электричество зарядка штекер plug wire electricity'),
('💡', 'Лампочка', 'EMOJI', 'HOUSEHOLD', 'лампочка свет идея электричество освещение люстра bulb light lamp'),
('🔑', 'Ключ', 'EMOJI', 'HOUSEHOLD', 'ключ замок дверь сейф доступ key door lock'),
('📦', 'Коробка', 'EMOJI', 'HOUSEHOLD', 'коробка посылка склад ящик доставка почта box package delivery'),
('🎁', 'Подарок', 'EMOJI', 'HOUSEHOLD', 'подарок презент праздник сюрприз коробка gift present surprise'),
('🔨', 'Молоток', 'EMOJI', 'HOUSEHOLD', 'молоток инструменты ремонт стройка гвоздь hammer tools repair'),
('🔧', 'Ключ гаечный', 'EMOJI', 'HOUSEHOLD', 'ключ гаечный ремонт авто инструменты wrench spanner repair'),
('🪛', 'Отвертка', 'EMOJI', 'HOUSEHOLD', 'отвертка инструменты ремонт монтаж шуруп screwdriver tools repair'),
('🎒', 'Рюкзак', 'EMOJI', 'HOUSEHOLD', 'рюкзак портфель школа туризм сумка backpack travel bag school'),
('👕', 'Одежда', 'EMOJI', 'HOUSEHOLD', 'футболка одежда вещи гардероб мода майка tshirt clothes wear'),
('👟', 'Обувь', 'EMOJI', 'HOUSEHOLD', 'обувь кроссовки кеды спорт бег shoe sneakers running'),
('🕶️', 'Очки', 'EMOJI', 'HOUSEHOLD', 'очки солнцезащитные зрение оптика линзы glasses sunglasses optic'),
('💊', 'Таблетки', 'EMOJI', 'HOUSEHOLD', 'таблетки пилюли лекарство аптека здоровье капсулы pills medicine health'),
('🩹', 'Пластырь', 'EMOJI', 'HOUSEHOLD', 'пластырь бинт рана медицина первая помощь bandage plaster medical');

-- Emojis - Miscellaneous
INSERT INTO icon_metadata (name, display_name, type, category, keywords) VALUES
('🐶', 'Собака', 'EMOJI', 'MISC', 'собака пес животные домашние корм питомец пес dog pet animal'),
('🐱', 'Кошка', 'EMOJI', 'MISC', 'кошка кот животные домашние корм питомец котенок cat pet animal'),
('🌸', 'Цветы', 'EMOJI', 'MISC', 'цветок цветы растение букет подарок сад весна flower bouquet garden'),
('🚗', 'Машина', 'EMOJI', 'MISC', 'машина автомобиль гараж авто поездка car vehicle auto trip'),
('🚲', 'Велик', 'EMOJI', 'MISC', 'велосипед велик транспорт спорт прогулка bicycle bike'),
('📚', 'Книги', 'EMOJI', 'MISC', 'книги учебники чтение библиотека знания литература books read library'),
('🧸', 'Игрушка', 'EMOJI', 'MISC', 'мишка игрушка ребенок детское плюшевый медведь toy teddy bear kid'),
('🎮', 'Игры', 'EMOJI', 'MISC', 'джойстик геймпад приставка консоль игры плойка game controller gamepad'),
('🎨', 'Краски', 'EMOJI', 'MISC', 'палитра краски рисование искусство декор paint palette art color'),
('⚽', 'Мяч', 'EMOJI', 'MISC', 'мяч спорт футбол игра матч soccer ball sport football'),
('💻', 'Ноутбук', 'EMOJI', 'MISC', 'ноутбук ноут компьютер работа пк дисплей laptop computer pc work'),
('📱', 'Телефон', 'EMOJI', 'MISC', 'телефон айфон смартфон связь звонок мобильный phone smartphone mobile'),
('💰', 'Деньги', 'EMOJI', 'MISC', 'деньги мешок валюта богатство золото монеты money cash gold'),
('💳', 'Карта', 'EMOJI', 'MISC', 'карта кредитка оплата безнал банк credit card payment bank'),
('✉️', 'Письмо', 'EMOJI', 'MISC', 'письмо конверт почта сообщение e-mail envelope mail message'),
('✏️', 'Карандаш', 'EMOJI', 'MISC', 'карандаш ручка учеба рисовать pencil pen study write'),
('💼', 'Портфель', 'EMOJI', 'MISC', 'портфель дипломат работа офис бизнес briefcase office business'),
('🛒', 'Тележка', 'EMOJI', 'MISC', 'тележка корзина супермаркет покупки cart shopping'),
('🏠', 'Дом', 'EMOJI', 'MISC', 'дом дача здание жилье квартира house home building'),
('🏪', 'Магазин', 'EMOJI', 'MISC', 'магазин супермаркет маркет киоск convenience store shop');
