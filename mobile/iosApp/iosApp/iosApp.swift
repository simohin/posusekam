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
                Text("Для начала работы необходимо создать ваш первый дом (например, 'Квартира' или 'Дача'), где будут располагаться магазины и товары.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Название дома")
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
                Text("Создать дом")
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
    @State private var showMagicAlert = false
    @State private var activeSheet: OverviewSheetType? = nil
    @State private var showDeleteHouseholdConfirmation = false

    var body: some View {
        let tabBinding = Binding<Int>(
            get: { selectedTab },
            set: { newValue in
                if newValue == 2 {
                    showMagicAlert = true
                } else {
                    selectedTab = newValue
                }
            }
        )
        
        NavigationStack {
            TabView(selection: tabBinding) {
                Tab("Обзор", systemImage: "chart.pie.fill", value: 0) {
                    OverviewTab(authViewModel: authViewModel, activeSheet: $activeSheet)
                }
                
                Tab("Вычисления", systemImage: "function", value: 1) {
                    CalculatorTab(authViewModel: authViewModel, activeSheet: $activeSheet)
                }
                
                Tab("Магия", systemImage: "wand.and.stars.inverse", value: 2, role: .search) {
                    Color.clear
                }
            }
            .tint(.blue)
            .navigationBarTitleDisplayMode(.inline)
            
            // Toolbar containing active household switcher and profile avatar
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        ForEach(authViewModel.households, id: \.id) { hh in
                            Group {
                                if let icon = hh.icon, isEmoji(icon) {
                                    Button(action: {
                                        authViewModel.selectHousehold(hh)
                                    }) {
                                        Text("\(icon)  \(hh.name)\(hh.id == authViewModel.activeHousehold?.id ? " ✓" : "")")
                                    }
                                } else {
                                    Button(action: {
                                        authViewModel.selectHousehold(hh)
                                    }) {
                                        Label("\(hh.name)\(hh.id == authViewModel.activeHousehold?.id ? " ✓" : "")", systemImage: hh.icon ?? "house.fill")
                                    }
                                }
                            }
                        }
                        Divider()
                        Button(action: {
                            activeSheet = .createHousehold
                        }) {
                            Label("Создать дом...", systemImage: "plus")
                        }
                        if let active = authViewModel.activeHousehold {
                            Button(action: {
                                activeSheet = .editHousehold(active)
                            }) {
                                Label("Редактировать дом...", systemImage: "pencil")
                            }
                            Button(role: .destructive, action: {
                                showDeleteHouseholdConfirmation = true
                            }) {
                                Label("Удалить дом", systemImage: "trash")
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Group {
                                if let icon = authViewModel.activeHousehold?.icon {
                                    if isEmoji(icon) {
                                        Text(icon)
                                    } else {
                                        Image(systemName: icon)
                                            .foregroundColor(.blue)
                                    }
                                } else {
                                    Image(systemName: "house.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                            Text(authViewModel.activeHousehold?.name ?? "Выбрать дом")
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
                        let finalAvatarUrl = authViewModel.userInfo?.avatarUrl ?? authViewModel.userProfile?.avatarUrl
                        if let avatarUrl = finalAvatarUrl, let url = URL(string: avatarUrl) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.blue)
                            }
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.blue)
                                .frame(width: 32, height: 32)
                        }
                    }
                }
            }
            
            .alert("Удалить дом?", isPresented: $showDeleteHouseholdConfirmation) {
                Button("Удалить", role: .destructive) {
                    if let active = authViewModel.activeHousehold {
                        Task {
                            await authViewModel.deleteHousehold(id: active.id)
                        }
                    }
                }
                Button("Отмена", role: .cancel) {}
            } message: {
                Text("Это удалит дом и все связанные магазины и продукты.")
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
                case .createHousehold:
                    HouseholdFormSheet(authViewModel: authViewModel, householdToEdit: nil) {
                        activeSheet = nil
                    }
                case .editHousehold(let household):
                    HouseholdFormSheet(authViewModel: authViewModel, householdToEdit: household) {
                        activeSheet = nil
                    }
                }
            }
        }
        .alert("Волшебная функция", isPresented: $showMagicAlert) {
            Button("ОК", role: .cancel) {}
        } message: {
            Text("Скоро здесь появится интеллектуальный подбор действий и управление покупками с помощью ИИ!")
        }
    }
}

enum OverviewSheetType: Identifiable {
    case createStore
    case editStore(shared.Store)
    case profile
    case createHousehold
    case editHousehold(shared.Household)
    
    var id: String {
        switch self {
        case .createStore:
            return "createStore"
        case .editStore(let store):
            return "editStore-\(store.id)"
        case .profile:
            return "profile"
        case .createHousehold:
            return "createHousehold"
        case .editHousehold(let household):
            return "editHousehold-\(household.id)"
        }
    }
}

// MARK: - Overview Tab
struct OverviewTab: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Binding var activeSheet: OverviewSheetType?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // First Block: Мои магазины (Магазины)
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Мои магазины")
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
                            Text("В этом доме еще нет магазинов")
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
                if !authViewModel.hidePurchaseManagement {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("Управление покупками")
                                .font(.headline)
                            Spacer()
                            Button(action: {
                                authViewModel.updateHidePurchaseManagement(hide: true)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                                    .font(.title3)
                            }
                        }
                        
                        Text("В каждом магазине хранится собственный каталог продуктов и запасов. Категории и теги создаются в рамках дома и могут применяться к любым продуктам.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            authViewModel.updateHidePurchaseManagement(hide: true)
                        }) {
                            Text("Не показывать больше")
                                .font(.footnote)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                        }
                        .padding(.top, 4)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(20)
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("")
    }
}

// MARK: - Household Form Sheet
struct HouseholdFormSheet: View {
    @ObservedObject var authViewModel: AuthViewModel
    let householdToEdit: shared.Household?
    let onDismiss: () -> Void
    
    @State private var name: String = ""
    @State private var selectedIcon: String = "house.fill"
    @State private var showIconPicker = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Основная информация")) {
                    TextField("Название дома", text: $name)
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
                            .background(Color.blue)
                            .cornerRadius(12)
                            Image(systemName: "chevron.right")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle(householdToEdit == nil ? "Новый дом" : "Редактировать дом")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        onDismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(householdToEdit == nil ? "Добавить" : "Сохранить") {
                        Task {
                            if let hh = householdToEdit {
                                await authViewModel.updateHousehold(id: hh.id, name: name, icon: selectedIcon)
                            } else {
                                await authViewModel.createHousehold(name: name, icon: selectedIcon)
                            }
                            onDismiss()
                        }
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .sheet(isPresented: $showIconPicker) {
                IconPickerView(selectedIcon: $selectedIcon, selectedColor: .blue, metadata: authViewModel.metadata)
            }
            .onAppear {
                if let hh = householdToEdit {
                    name = hh.name
                    selectedIcon = hh.icon ?? "house.fill"
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
            
            Text(store.name)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(1)
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
    @Binding var activeSheet: OverviewSheetType?
    @State private var count: Int = 10
    @State private var result: [Int] = []
    
    var body: some View {
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
    }
}

// MARK: - Profile View
struct ProfileView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showResetSuccessAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    let finalAvatarUrl = authViewModel.userInfo?.avatarUrl ?? authViewModel.userProfile?.avatarUrl
                    let finalName: String = {
                        if let displayName = authViewModel.userInfo?.displayName, !displayName.isEmpty {
                            return displayName
                        }
                        if let first = authViewModel.userInfo?.firstName, !first.isEmpty {
                            let last = authViewModel.userInfo?.lastName ?? ""
                            let full = "\(first) \(last)".trimmingCharacters(in: .whitespacesAndNewlines)
                            if !full.isEmpty { return full }
                        }
                        return authViewModel.userProfile?.name ?? "Пользователь"
                    }()
                    
                    VStack(spacing: 12) {
                        HStack {
                            Spacer()
                            if let avatarUrl = finalAvatarUrl, let url = URL(string: avatarUrl) {
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
                            Text(finalName)
                                .font(.title3)
                                .fontWeight(.bold)
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
                    
                    Button(action: {
                        authViewModel.resetUserSettings()
                        showResetSuccessAlert = true
                    }) {
                        Label("Сбросить настройки", systemImage: "arrow.counterclockwise.circle")
                            .foregroundColor(.red)
                    }
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
            .alert("Сброс выполнен", isPresented: $showResetSuccessAlert) {
                Button("ОК", role: .cancel) {}
            } message: {
                Text("Все настройки успешно сброшены до значений по умолчанию.")
            }
        }
    }
}