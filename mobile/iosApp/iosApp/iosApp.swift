import SwiftUI
import shared

func isEmoji(_ character: String) -> Bool {
    guard let firstScalar = character.unicodeScalars.first else { return false }
    return firstScalar.properties.isEmoji && (firstScalar.properties.isEmojiPresentation || character.unicodeScalars.count > 1)
}

@main
struct iosApp: App {
    @StateObject private var authViewModel: AuthViewModel
    
    init() {
        guard let backendUrl = Bundle.main.object(forInfoDictionaryKey: "BackendURL") as? String else {
            fatalError("BackendURL is not configured in Info.plist")
        }
        _authViewModel = StateObject(wrappedValue: AuthViewModel(baseUrl: backendUrl))
    }
    
    var body: some Scene {
        WindowGroup {
            if authViewModel.isAuthenticated {
                if authViewModel.isLoadingData && authViewModel.households.isEmpty {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Загрузка данных...")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(uiColor: .systemGroupedBackground))
                } else if authViewModel.households.isEmpty {
                    OnboardingView(authViewModel: authViewModel)
                } else {
                    ContentView(authViewModel: authViewModel)
                }
            } else {
                LoginView(viewModel: authViewModel)
            }
        }
    }
}

// MARK: - Onboarding View
struct OnboardingView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var householdName = ""
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "house.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
                .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
            
            VStack(spacing: 12) {
                Text("Добро пожаловать!")
                    .font(.title)
                    .fontWeight(.bold)
                Text("Для начала работы необходимо создать ваше первое домовладение (например, 'Квартира' или 'Дача'), где будут располагаться магазины и товары.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Название домовладения")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                TextField("Например, Дом", text: $householdName)
                    .padding()
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                    )
            }
            .padding(.horizontal, 24)
            
            Button(action: {
                Task {
                    await authViewModel.createHousehold(name: householdName)
                }
            }) {
                Text("Создать домовладение")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(14)
            }
            .disabled(householdName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .padding(.horizontal, 24)
            
            Spacer()
        }
        .padding()
        .background(Color(uiColor: .systemGroupedBackground))
    }
}

// MARK: - Content View
struct ContentView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var selectedTab = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab contents with state preservation
            ZStack {
                OverviewTab(authViewModel: authViewModel)
                    .opacity(selectedTab == 0 ? 1 : 0)
                    .disabled(selectedTab != 0)
                
                CalculatorTab(authViewModel: authViewModel)
                    .opacity(selectedTab == 1 ? 1 : 0)
                    .disabled(selectedTab != 1)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom floating tab bar (integrated with the magic button)
            CustomFloatingTabBar(selectedTab: $selectedTab)
        }
    }
}

struct CustomFloatingTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 12) {
            // Main tabs capsule container
            HStack(spacing: 0) {
                // Tab 0: Обзор
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        selectedTab = 0
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "chart.pie.fill")
                            .font(.system(size: 20))
                        Text("Обзор")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(selectedTab == 0 ? .blue : .white.opacity(0.6))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(selectedTab == 0 ? Color.white.opacity(0.08) : Color.clear)
                    )
                }
                .padding(.leading, 8)
                .padding(.vertical, 6)
                
                // Tab 1: Вычисления
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        selectedTab = 1
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "function")
                            .font(.system(size: 20))
                        Text("Вычисления")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(selectedTab == 1 ? .blue : .white.opacity(0.6))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(selectedTab == 1 ? Color.white.opacity(0.08) : Color.clear)
                    )
                }
                .padding(.trailing, 8)
                .padding(.vertical, 6)
            }
            .background(
                Capsule()
                    .fill(Color(red: 0.11, green: 0.11, blue: 0.12))
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            )
            
            // Magic Action Button (Circle)
            Button(action: {}) {
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white.opacity(0.3))
                    .frame(width: 56, height: 56)
                    .background(
                        Circle()
                            .fill(Color(red: 0.11, green: 0.11, blue: 0.12))
                            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                    )
            }
            .disabled(true)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }
}

enum OverviewSheetType: Identifiable {
    case createStore
    case editStore(shared.Store)
    case profile
    
    var id: String {
        switch self {
        case .createStore:
            return "createStore"
        case .editStore(let store):
            return "editStore-\(store.id)"
        case .profile:
            return "profile"
        }
    }
}

// MARK: - Overview Tab
struct OverviewTab: View {
    @ObservedObject var authViewModel: AuthViewModel
    
    // States for Alerts
    @State private var showCreateHouseholdAlert = false
    @State private var newHouseholdName = ""
    
    @State private var showEditHouseholdAlert = false
    @State private var editingHouseholdName = ""
    
    @State private var showDeleteHouseholdConfirmation = false
    
    // States for Sheets
    @State private var activeSheet: OverviewSheetType? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // First Block: Мои сусеки (Магазины)
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Мои сусеки")
                                .font(.title2)
                                .fontWeight(.bold)
                            Spacer()
                            Button(action: {
                                activeSheet = .createStore
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)
                        
                        if authViewModel.stores.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "storefront")
                                    .font(.system(size: 44))
                                    .foregroundColor(.secondary.opacity(0.8))
                                Text("В этом домовладении еще нет магазинов")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Button("Добавить магазин") {
                                    activeSheet = .createStore
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.blue)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(30)
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                            .cornerRadius(24)
                            .padding(.horizontal)
                        } else {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                ForEach(authViewModel.stores, id: \.id) { store in
                                    StoreCard(store: store)
                                        .contextMenu {
                                            Button {
                                                activeSheet = .editStore(store)
                                            } label: {
                                                Label("Редактировать", systemImage: "pencil")
                                            }
                                            
                                            Button(role: .destructive) {
                                                Task {
                                                    await authViewModel.deleteStore(id: store.id)
                                                }
                                            } label: {
                                                Label("Удалить", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Info Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Управление покупками")
                            .font(.headline)
                        Text("В каждом магазине хранится собственный каталог продуктов и запасов. Категории и теги создаются в рамках домовладения и могут применяться к любым продуктам.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(20)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 90)
            }
            .navigationBarTitleDisplayMode(.inline)
            
            // Toolbar containing active household switcher
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        ForEach(authViewModel.households, id: \.id) { hh in
                            Button(action: {
                                authViewModel.selectHousehold(hh)
                            }) {
                                HStack {
                                    Text(hh.name)
                                    if hh.id == authViewModel.activeHousehold?.id {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                        Divider()
                        Button(action: {
                            showCreateHouseholdAlert = true
                        }) {
                            Label("Создать домовладение...", systemImage: "plus")
                        }
                        if let active = authViewModel.activeHousehold {
                            Button(action: {
                                editingHouseholdName = active.name
                                showEditHouseholdAlert = true
                            }) {
                                Label("Переименовать домовладение...", systemImage: "pencil")
                            }
                            Button(role: .destructive, action: {
                                showDeleteHouseholdConfirmation = true
                            }) {
                                Label("Удалить домовладение", systemImage: "trash")
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "house.fill")
                                .foregroundColor(.blue)
                            Text(authViewModel.activeHousehold?.name ?? "Выбрать домовладение")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        activeSheet = .profile
                    }) {
                        if let avatarUrl = authViewModel.userProfile?.avatarUrl, let url = URL(string: avatarUrl) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            
            // Households Alerts
            .alert("Новое домовладение", isPresented: $showCreateHouseholdAlert) {
                TextField("Название", text: $newHouseholdName)
                Button("Создать") {
                    Task {
                        await authViewModel.createHousehold(name: newHouseholdName)
                        newHouseholdName = ""
                    }
                }
                Button("Отмена", role: .cancel) {}
            }
            
            .alert("Переименовать домовладение", isPresented: $showEditHouseholdAlert) {
                TextField("Название", text: $editingHouseholdName)
                Button("Сохранить") {
                    if let active = authViewModel.activeHousehold {
                        Task {
                            await authViewModel.updateHousehold(id: active.id, name: editingHouseholdName)
                        }
                    }
                }
                Button("Отмена", role: .cancel) {}
            }
            
            .alert("Удалить домовладение?", isPresented: $showDeleteHouseholdConfirmation) {
                Button("Удалить", role: .destructive) {
                    if let active = authViewModel.activeHousehold {
                        Task {
                            await authViewModel.deleteHousehold(id: active.id)
                        }
                    }
                }
                Button("Отмена", role: .cancel) {}
            } message: {
                Text("Это удалит домовладение и все связанные магазины и продукты.")
            }
            
            // Sheets presentation (Store Form & Profile)
            .sheet(item: $activeSheet) { sheetType in
                switch sheetType {
                case .createStore:
                    StoreFormSheet(authViewModel: authViewModel, storeToEdit: nil) {
                        activeSheet = nil
                    }
                case .editStore(let store):
                    StoreFormSheet(authViewModel: authViewModel, storeToEdit: store) {
                        activeSheet = nil
                    }
                case .profile:
                    ProfileView(authViewModel: authViewModel)
                }
            }
        }
    }
}

// MARK: - Store Form Sheet
struct StoreFormSheet: View {
    @ObservedObject var authViewModel: AuthViewModel
    let storeToEdit: shared.Store?
    let onDismiss: () -> Void
    
    @State private var name: String = ""
    @State private var selectedIcon: String = "storefront.fill"
    @State private var selectedColor: String = "indigo"
    @State private var showIconPicker = false
    
    let colors = [
        ("Indigo", "indigo", Color.indigo),
        ("Blue", "blue", Color.blue),
        ("Teal", "teal", Color.teal),
        ("Green", "green", Color.green),
        ("Orange", "orange", Color.orange),
        ("Red", "red", Color.red),
        ("Pink", "pink", Color.pink)
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Основная информация")) {
                    TextField("Название магазина", text: $name)
                }
                
                Section(header: Text("Оформление")) {
                    Button(action: {
                        showIconPicker = true
                    }) {
                        HStack {
                            Text("Выбрать иконку")
                                .foregroundColor(.primary)
                            Spacer()
                            Group {
                                if isEmoji(selectedIcon) {
                                    Text(selectedIcon)
                                        .font(.system(size: 24))
                                } else {
                                    Image(systemName: selectedIcon)
                                        .font(.title3)
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(width: 44, height: 44)
                            .background(colorFromString(selectedColor))
                            .cornerRadius(12)
                            Image(systemName: "chevron.right")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Цвет")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                            ForEach(colors, id: \.1) { name, id, color in
                                Circle()
                                    .fill(color)
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.primary, lineWidth: selectedColor == id ? 2 : 0)
                                    )
                                    .onTapGesture {
                                        selectedColor = id
                                    }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle(storeToEdit == nil ? "Новый магазин" : "Редактировать магазин")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        onDismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(storeToEdit == nil ? "Добавить" : "Сохранить") {
                        Task {
                            if let store = storeToEdit {
                                await authViewModel.updateStore(id: store.id, name: name, icon: selectedIcon, color: selectedColor)
                            } else {
                                await authViewModel.createStore(name: name, icon: selectedIcon, color: selectedColor)
                            }
                            onDismiss()
                        }
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .sheet(isPresented: $showIconPicker) {
                IconPickerView(selectedIcon: $selectedIcon, selectedColor: colorFromString(selectedColor), metadata: authViewModel.metadata)
            }
            .onAppear {
                if let store = storeToEdit {
                    name = store.name
                    selectedIcon = store.icon ?? "storefront.fill"
                    selectedColor = store.color ?? "indigo"
                }
            }
        }
    }
    
    private func colorFromString(_ colorStr: String) -> Color {
        switch colorStr {
        case "indigo": return .indigo
        case "blue": return .blue
        case "teal": return .teal
        case "green": return .green
        case "orange": return .orange
        case "red": return .red
        case "pink": return .pink
        default: return .indigo
        }
    }
}

// MARK: - Icon Picker View
struct IconPickerView: View {
    @Binding var selectedIcon: String
    let selectedColor: Color
    let metadata: shared.AppMetadataDto?
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText = ""
    @State private var selectedTab = 0 // 0 = SF Symbols, 1 = Emojis
    
    var allItems: [shared.IconMetadataDto] {
        if let backendItems = metadata?.icons {
            return backendItems
        }
        
        // Static offline/loading fallback
        return [
            shared.IconMetadataDto(name: "storefront.fill", displayName: "Магазин", type: "SF_SYMBOL", category: "SHOPPING", keywords: "магазин супермаркет storefront market"),
            shared.IconMetadataDto(name: "cart.fill", displayName: "Тележка", type: "SF_SYMBOL", category: "SHOPPING", keywords: "тележка корзина cart trolley"),
            shared.IconMetadataDto(name: "bag.fill", displayName: "Пакет", type: "SF_SYMBOL", category: "SHOPPING", keywords: "пакет сумка bag shopper"),
            shared.IconMetadataDto(name: "basket.fill", displayName: "Корзинка", type: "SF_SYMBOL", category: "SHOPPING", keywords: "корзина корзинка basket"),
            shared.IconMetadataDto(name: "carrot.fill", displayName: "Морковь", type: "SF_SYMBOL", category: "FOOD", keywords: "морковь овощи carrot vegetable"),
            shared.IconMetadataDto(name: "fish.fill", displayName: "Рыба", type: "SF_SYMBOL", category: "FOOD", keywords: "рыба морепродукты fish seafood"),
            shared.IconMetadataDto(name: "house.fill", displayName: "Дом", type: "SF_SYMBOL", category: "HOUSEHOLD", keywords: "дом house home"),
            shared.IconMetadataDto(name: "hammer.fill", displayName: "Молоток", type: "SF_SYMBOL", category: "TOOLS", keywords: "молоток инструменты hammer tools"),
            shared.IconMetadataDto(name: "pills.fill", displayName: "Аптека", type: "SF_SYMBOL", category: "HEALTH", keywords: "таблетки лекарства pills medicine"),
            shared.IconMetadataDto(name: "heart.fill", displayName: "Любимое", type: "SF_SYMBOL", category: "MISC", keywords: "сердце любовь heart love"),
            
            shared.IconMetadataDto(name: "🥩", displayName: "Мясо", type: "EMOJI", category: "FOOD", keywords: "мясо стейк meat steak pork beef"),
            shared.IconMetadataDto(name: "🍗", displayName: "Курица", type: "EMOJI", category: "FOOD", keywords: "курица птица chicken poultry"),
            shared.IconMetadataDto(name: "🐟", displayName: "Рыба", type: "EMOJI", category: "FOOD", keywords: "рыба морепродукты fish seafood"),
            shared.IconMetadataDto(name: "🍞", displayName: "Хлеб", type: "EMOJI", category: "FOOD", keywords: "хлеб выпечка bread bakery"),
            shared.IconMetadataDto(name: "🥛", displayName: "Молоко", type: "EMOJI", category: "FOOD", keywords: "молоко сливки milk drink"),
            shared.IconMetadataDto(name: "🧀", displayName: "Сыр", type: "EMOJI", category: "FOOD", keywords: "сыр cheese food"),
            shared.IconMetadataDto(name: "🧼", displayName: "Мыло", type: "EMOJI", category: "HOUSEHOLD", keywords: "мыло гигиена soap clean"),
            shared.IconMetadataDto(name: "🧻", displayName: "Бумага", type: "EMOJI", category: "HOUSEHOLD", keywords: "туалетная бумага toilet paper roll"),
            shared.IconMetadataDto(name: "🔨", displayName: "Молоток", type: "EMOJI", category: "HOUSEHOLD", keywords: "молоток инструменты hammer tools"),
            shared.IconMetadataDto(name: "🚗", displayName: "Машина", type: "EMOJI", category: "MISC", keywords: "машина авто car auto"),
            shared.IconMetadataDto(name: "🛒", displayName: "Тележка", type: "EMOJI", category: "MISC", keywords: "тележка корзина cart shopping")
        ]
    }
    
    var filteredItems: [shared.IconMetadataDto] {
        let typeFilter = selectedTab == 0 ? "SF_SYMBOL" : "EMOJI"
        let baseItems = allItems.filter { $0.type == typeFilter }
        
        if searchText.isEmpty {
            return baseItems
        } else {
            let query = searchText.lowercased()
            return baseItems.filter { item in
                item.displayName.lowercased().contains(query) ||
                item.name.lowercased().contains(query) ||
                item.keywords.lowercased().contains(query)
            }
        }
    }
    
    var groupedItems: [String: [shared.IconMetadataDto]] {
        Dictionary(grouping: filteredItems) { $0.category }
    }
    
    var orderedCategories: [String] {
        let order = ["SHOPPING", "FOOD", "HOUSEHOLD", "TOOLS", "APPAREL", "HOBBIES", "SPORT", "HEALTH", "MISC"]
        let presentCategories = Array(groupedItems.keys)
        return order.filter { presentCategories.contains($0) } + presentCategories.filter { !order.contains($0) }
    }
    
    private func localizedCategoryName(_ cat: String) -> String {
        switch cat {
        case "SHOPPING": return "Покупки и магазины"
        case "FOOD": return "Еда и продукты"
        case "HOUSEHOLD": return "Хозтовары и быт"
        case "TOOLS": return "Инструменты и ремонт"
        case "APPAREL": return "Одежда и мода"
        case "HOBBIES": return "Хобби и техника"
        case "SPORT": return "Спорт и активный отдых"
        case "HEALTH": return "Аптека и здоровье"
        case "MISC": return "Разное"
        default: return "Другое"
        }
    }
    
    let columns = [
        GridItem(.adaptive(minimum: 65), spacing: 12)
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Тип иконки", selection: $selectedTab) {
                    Text("SF Symbols").tag(0)
                    Text("Эмодзи").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                .background(Color(uiColor: .systemGroupedBackground))
                
                ScrollView {
                    if filteredItems.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                            Text("Ничего не найдено")
                                .font(.headline)
                            Text("Попробуйте ввести другое название (например, мясо, хлеб, инструмент...)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 60)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity)
                    } else {
                        LazyVStack(alignment: .leading, spacing: 20) {
                            ForEach(orderedCategories, id: \.self) { category in
                                if let items = groupedItems[category], !items.isEmpty {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(localizedCategoryName(category))
                                            .font(.footnote)
                                            .fontWeight(.bold)
                                            .foregroundColor(.secondary)
                                            .textCase(.uppercase)
                                            .padding(.horizontal)
                                        
                                        LazyVGrid(columns: columns, spacing: 14) {
                                            ForEach(items, id: \.name) { item in
                                                VStack {
                                                    Group {
                                                        if selectedTab == 1 {
                                                            Text(item.name)
                                                                .font(.system(size: 28))
                                                        } else {
                                                            Image(systemName: item.name)
                                                                .font(.title2)
                                                                .foregroundColor(selectedIcon == item.name ? .white : .primary)
                                                        }
                                                    }
                                                    .frame(width: 58, height: 58)
                                                    .background(selectedIcon == item.name ? selectedColor : Color(uiColor: .secondarySystemGroupedBackground))
                                                    .cornerRadius(16)
                                                    .shadow(color: selectedIcon == item.name ? selectedColor.opacity(0.3) : Color.clear, radius: 6, x: 0, y: 3)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 16)
                                                            .stroke(Color.primary.opacity(0.1), lineWidth: selectedIcon == item.name ? 0 : 1)
                                                    )
                                                    .onTapGesture {
                                                        selectedIcon = item.name
                                                        dismiss()
                                                    }
                                                    
                                                    Text(item.displayName)
                                                        .font(.caption2)
                                                        .foregroundColor(.secondary)
                                                        .lineLimit(1)
                                                }
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                }
                .background(Color(uiColor: .systemGroupedBackground))
            }
            .navigationTitle("Выбор иконки")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Поиск (например, мясо, хлеб, спорт...)")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Store Card Widget
struct StoreCard: View {
    let store: shared.Store
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Group {
                    if let icon = store.icon, isEmoji(icon) {
                        Text(icon)
                            .font(.system(size: 24))
                    } else {
                        Image(systemName: store.icon ?? "storefront.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
                .frame(width: 44, height: 44)
                .background(gradientForStore())
                .cornerRadius(12)
                .shadow(color: colorFromString(store.color).opacity(0.15), radius: 4, x: 0, y: 2)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(store.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text("Сусек с товарами")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 3)
    }
    
    private func colorFromString(_ colorStr: String?) -> Color {
        switch colorStr {
        case "indigo": return .indigo
        case "blue": return .blue
        case "teal": return .teal
        case "green": return .green
        case "orange": return .orange
        case "red": return .red
        case "pink": return .pink
        default: return .indigo
        }
    }
    
    private func gradientForStore() -> LinearGradient {
        if let colorStr = store.color {
            let mainColor = colorFromString(colorStr)
            return LinearGradient(
                colors: [mainColor, mainColor.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        return gradientColorForName(store.name)
    }
    
    // Hash function to yield stable gradient colors for visual style
    private func gradientColorForName(_ name: String) -> LinearGradient {
        let hash = abs(name.hashValue)
        let colors: [[Color]] = [
            [.indigo, .purple],
            [.blue, .teal],
            [.orange, .red],
            [.green, .teal],
            [.pink, .purple]
        ]
        let selectedColors = colors[hash % colors.count]
        return LinearGradient(
            colors: selectedColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Calculator Tab
struct CalculatorTab: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var count: Int = 10
    @State private var result: [Int] = []
    @State private var showProfileSheet = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Количество чисел")) {
                    Stepper("Сгенерировать: \(count)", value: $count, in: 0...20)
                }
                
                Section {
                    Button(action: {
                        withAnimation {
                            let kotlinList = FibonacciKt.generateFibonacci(count: Int32(count))
                            result = kotlinList.map { Int(truncating: $0 as NSNumber) }
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text("Рассчитать последовательность")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Spacer()
                        }
                    }
                    .listRowBackground(Color.blue)
                }
                
                if !result.isEmpty {
                    Section(header: Text("Результат Фибоначчи")) {
                        Text(result.map { String($0) }.joined(separator: ", "))
                            .font(.system(.body, design: .monospaced))
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                            .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Вычисления")
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 90)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showProfileSheet = true
                    }) {
                        if let avatarUrl = authViewModel.userProfile?.avatarUrl, let url = URL(string: avatarUrl) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .sheet(isPresented: $showProfileSheet) {
                ProfileView(authViewModel: authViewModel)
            }
        }
    }
}

// MARK: - Profile View
struct ProfileView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(spacing: 12) {
                        HStack {
                            Spacer()
                            if let avatarUrl = authViewModel.userProfile?.avatarUrl, let url = URL(string: avatarUrl) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Image(systemName: "person.crop.circle.fill")
                                        .font(.system(size: 80))
                                        .foregroundColor(.blue)
                                }
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 80))
                                    .foregroundColor(.blue)
                                    .frame(width: 80, height: 80)
                            }
                            Spacer()
                        }
                        
                        VStack(spacing: 4) {
                            if let name = authViewModel.userProfile?.name {
                                Text(name)
                                    .font(.title3)
                                    .fontWeight(.bold)
                            }
                            Text(authViewModel.userProfile?.email ?? "")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.caption)
                                Text("\(authViewModel.userProfile?.provider.rawValue ?? "Google") Синхронизация")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                            .padding(.top, 4)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .listRowBackground(Color.clear)
                
                Section(header: Text("Настройки")) {
                    Toggle(isOn: .constant(false)) {
                        HStack {
                            Label("Уведомления", systemImage: "bell.fill")
                            Spacer()
                            Text("Скоро")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(.systemGray5))
                                .cornerRadius(6)
                        }
                    }
                    .disabled(true)
                    
                    Toggle(isOn: .constant(false)) {
                        HStack {
                            Label("Вход по Face ID", systemImage: "faceid")
                            Spacer()
                            Text("Скоро")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(.systemGray5))
                                .cornerRadius(6)
                        }
                    }
                    .disabled(true)
                }
                
                Section(header: Text("Приложение")) {
                    HStack {
                        Label("Версия", systemImage: "info.circle.fill")
                        Spacer()
                        Text("1.0.0 (Apple HIG)")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Button(role: .destructive, action: {
                        withAnimation {
                            authViewModel.logout()
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text("Выйти из аккаунта")
                                .fontWeight(.bold)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
}