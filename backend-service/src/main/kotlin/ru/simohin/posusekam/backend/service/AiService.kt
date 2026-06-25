package ru.simohin.posusekam.backend.service

import ru.simohin.posusekam.backendservice.dto.StoreProductsResponse

interface AiService {
    /**
     * Генерирует список продуктов на основе описания магазина, ограничений по категориям,
     * единицам измерения и целевому количеству товаров.
     *
     * @param storeDescription описание магазина или его ассортимента
     * @param allowedCategories список разрешенных категорий
     * @param allowedUnits список разрешенных единиц измерения
     * @param itemsCount количество товаров, которое необходимо сгенерировать
     * @return сгенерированный DTO ответа со списком продуктов
     */
    fun generateProductsList(
        storeDescription: String,
        allowedCategories: List<ProductCategory>,
        allowedUnits: List<ProductMeasureUnit>,
        itemsCount: Int
    ): StoreProductsResponse
}
