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
                
                Tab("Планирование", systemImage: "cart.fill", value: 1) {
                    PurchasePlanningTab(authViewModel: authViewModel, activeSheet: $activeSheet)
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
                        Group {
                            if let avatarUrl = finalAvatarUrl, let url = URL(string: avatarUrl) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 32, height: 32)
                                            .clipShape(Circle())
                                    case .failure, .empty:
                                        Image(systemName: "person.crop.circle.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 32, height: 32)
                                            .foregroundColor(.blue)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.blue)
                                    .frame(width: 32, height: 32)
                            }
                        }
                    }
                    .buttonStyle(.plain)
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
                case .storeProducts(let store):
                    StoreProductsView(authViewModel: authViewModel, store: store)
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
    case storeProducts(shared.Store)
    
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
        case .storeProducts(let store):
            return "storeProducts-\(store.id)"
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
                                    .onTapGesture {
                                        activeSheet = .storeProducts(store)
                                    }
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

// MARK: - Purchase Planning Tab
// MARK: - Purchase Planning structures
struct PlanningItem: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let categoryName: String
    var amount: Double
    let unit: String
    var isNeeded: Bool
}

// MARK: - Purchase Planning Tab
struct PurchasePlanningTab: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Binding var activeSheet: OverviewSheetType?
    
    @State private var selectedStoreForPlanning: shared.Store? = nil
    
    private func getInitialList(for storeId: String) -> [PlanningItem]? {
        guard let list = authViewModel.shoppingLists.first(where: { $0.storeId == storeId && !$0.completed }) else {
            return nil
        }
        return list.items.map { item in
            PlanningItem(
                id: item.id,
                name: item.name,
                categoryName: item.categoryName,
                amount: item.amount,
                unit: item.unit,
                isNeeded: true
            )
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Выберите магазин для планирования покупок")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                if authViewModel.stores.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "storefront")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary.opacity(0.7))
                        Text("Нет доступных магазинов")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Создайте магазин на вкладке 'Обзор', чтобы начать планирование.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
                } else {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                        ForEach(authViewModel.stores, id: \.id) { store in
                            let activeList = authViewModel.shoppingLists.first(where: { $0.storeId == store.id && !$0.completed })
                            let isCompleted = activeList != nil
                            
                            Button(action: {
                                selectedStoreForPlanning = store
                            }) {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        // Иконка магазина
                                        ZStack {
                                            Circle()
                                                .fill(colorFromString(store.color).opacity(0.15))
                                                .frame(width: 44, height: 44)
                                            
                                            if let icon = store.icon, isEmoji(icon) {
                                                Text(icon)
                                                    .font(.title2)
                                            } else {
                                                Image(systemName: store.icon ?? "storefront.fill")
                                                    .font(.title3)
                                                    .foregroundColor(colorFromString(store.color))
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        // Статус завершенности
                                        if isCompleted {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                                .font(.title3)
                                        }
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(store.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                        
                                        if isCompleted, let itemCount = activeList?.items.count {
                                            Text("Запланировано: \(itemCount) тов.")
                                                .font(.caption)
                                                .foregroundColor(.green)
                                                .fontWeight(.semibold)
                                        } else {
                                            Text("Нажмите для планирования")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(isCompleted ? Color.green.opacity(0.05) : Color(uiColor: .secondarySystemGroupedBackground))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(isCompleted ? Color.green.opacity(0.3) : Color.clear, lineWidth: 1.5)
                                )
                                .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.top)
        }
        .navigationTitle("Планирование закупки")
        .sheet(isPresented: Binding<Bool>(
            get: { selectedStoreForPlanning != nil },
            set: { if !$0 { selectedStoreForPlanning = nil } }
        )) {
            if let store = selectedStoreForPlanning {
                PurchasePlanningFlowView(
                    store: store,
                    authViewModel: authViewModel,
                    initialList: getInitialList(for: store.id)
                ) { plannedItems in
                    Task {
                        let activeList = authViewModel.shoppingLists.first(where: { $0.storeId == store.id && !$0.completed })
                        let requests = plannedItems.map { item in
                            shared.CreateShoppingListItemRequest(
                                name: item.name,
                                categoryName: item.categoryName,
                                amount: item.amount,
                                unit: item.unit
                            )
                        }
                        
                        if let existingList = activeList {
                            if requests.isEmpty {
                                await authViewModel.deleteShoppingList(id: existingList.id)
                            } else {
                                await authViewModel.updateShoppingList(id: existingList.id, completed: false, items: requests)
                            }
                        } else {
                            if !requests.isEmpty {
                                await authViewModel.createShoppingList(storeId: store.id, items: requests)
                            }
                        }
                    }
                    selectedStoreForPlanning = nil
                }
            }
        }
        .task {
            await authViewModel.fetchStores()
        }
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
}

// MARK: - Purchase Planning Flow View
struct PurchasePlanningFlowView: View {
    let store: shared.Store
    @ObservedObject var authViewModel: AuthViewModel
    let initialList: [PlanningItem]?
    var onComplete: ([PlanningItem]) -> Void
    
    @Environment(\.dismiss) var dismiss
    
    @State private var planningItems: [PlanningItem] = []
    @State private var currentIndex: Int = 0
    @State private var showingSummary: Bool = false
    @State private var editingSingleItemIndex: Int? = nil
    @State private var showAddItemSheet: Bool = false
    @State private var isLoading: Bool = true
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Загрузка товаров магазина...")
                } else if showingSummary {
                    planningSummaryView
                } else if planningItems.isEmpty {
                    emptyStoreView
                } else if currentIndex < planningItems.count {
                    tinderSwipeView
                } else {
                    VStack {
                        ProgressView()
                        Text("Переход к итогам...")
                    }
                    .onAppear {
                        showingSummary = true
                    }
                }
            }
            .navigationTitle(store.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    let isEditing = editingSingleItemIndex != nil
                    Button(isEditing ? "Назад" : "Отмена") {
                        if isEditing {
                            editingSingleItemIndex = nil
                            showingSummary = true
                        } else {
                            dismiss()
                        }
                    }
                }
                if showingSummary {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Готово") {
                            onComplete(planningItems.filter { $0.isNeeded })
                        }
                        .fontWeight(.bold)
                    }
                }
            }
            .sheet(isPresented: $showAddItemSheet) {
                AddItemView(
                    authViewModel: authViewModel,
                    store: store,
                    planningItems: $planningItems
                ) { newItem in
                    withAnimation {
                        if let existingIdx = planningItems.firstIndex(where: { $0.name.lowercased() == newItem.name.lowercased() }) {
                            planningItems[existingIdx].isNeeded = true
                            planningItems[existingIdx].amount = newItem.amount
                        } else {
                            planningItems.append(newItem)
                        }
                    }
                    showAddItemSheet = false
                }
            }
            .task {
                isLoading = true
                await authViewModel.fetchProducts(storeId: store.id)
                await authViewModel.fetchCategories()
                await authViewModel.fetchMeasureUnits()
                
                if let initialList = initialList {
                    self.planningItems = initialList
                    let existingNames = Set(initialList.map { $0.name.lowercased() })
                    for product in authViewModel.products {
                        if !existingNames.contains(product.name.lowercased()) {
                            let categoryName = product.categories.first?.name ?? "Без категории"
                            self.planningItems.append(
                                PlanningItem(
                                    id: product.id,
                                    name: product.name,
                                    categoryName: categoryName,
                                    amount: 1.0,
                                    unit: product.unit,
                                    isNeeded: false
                                )
                            )
                        }
                    }
                    showingSummary = true
                } else {
                    self.planningItems = authViewModel.products.map { product in
                        let categoryName = product.categories.first?.name ?? "Без категории"
                        return PlanningItem(
                            id: product.id,
                            name: product.name,
                            categoryName: categoryName,
                            amount: 1.0,
                            unit: product.unit,
                            isNeeded: false
                        )
                    }
                    currentIndex = 0
                    showingSummary = false
                }
                isLoading = false
            }
        }
    }
    
    var tinderSwipeView: some View {
        VStack(spacing: 20) {
            let isEditing = editingSingleItemIndex != nil
            
            if isEditing {
                Text("Редактирование товара")
                    .font(.headline)
                    .padding(.top)
            } else {
                let progress = Double(currentIndex) / Double(planningItems.count)
                ProgressView(value: progress)
                    .progressViewStyle(.linear)
                    .padding(.horizontal)
                    .padding(.top)
                
                Text("Товар \(currentIndex + 1) из \(planningItems.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            ZStack {
                if !isEditing && currentIndex + 1 < planningItems.count {
                    let nextItem = planningItems[currentIndex + 1]
                    VStack(spacing: 0) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.gray.opacity(0.1))
                            Image(systemName: "basket.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.gray.opacity(0.3))
                        }
                        .frame(height: 240)
                        .cornerRadius(16)
                        .padding(12)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(nextItem.name)
                                .font(.title3)
                                .bold()
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            Text(nextItem.categoryName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                    .frame(height: 480)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(24)
                    .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                    .scaleEffect(0.95)
                    .offset(y: 10)
                    .opacity(0.7)
                }
                
                TinderCardView(item: $planningItems[currentIndex]) { isNeeded in
                    planningItems[currentIndex].isNeeded = isNeeded
                    withAnimation {
                        if isEditing {
                            editingSingleItemIndex = nil
                            showingSummary = true
                        } else {
                            currentIndex += 1
                            if currentIndex >= planningItems.count {
                                showingSummary = true
                            }
                        }
                    }
                }
                .id(planningItems[currentIndex].id)
            }
            .frame(height: 480)
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding(.bottom, 24)
    }
    
    var planningSummaryView: some View {
        VStack(spacing: 0) {
            let selectedItems = planningItems.filter { $0.isNeeded }
            
            if selectedItems.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "cart.badge.questionmark")
                        .font(.system(size: 64))
                        .foregroundColor(.secondary.opacity(0.7))
                    Text("В списке покупок ничего нет")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Вы можете добавить товары из каталога или создать новые.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    Button("Добавить товар") {
                        showAddItemSheet = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .padding(.top, 8)
                }
                .frame(maxHeight: .infinity)
            } else {
                List {
                    Section(header: Text("Выбранные товары (\(selectedItems.count))")) {
                        ForEach(selectedItems) { item in
                            Button(action: {
                                if let idx = planningItems.firstIndex(where: { $0.id == item.id }) {
                                    editingSingleItemIndex = idx
                                    currentIndex = idx
                                    showingSummary = false
                                }
                            }) {
                                HStack {
                                    Button(action: {
                                        if let idx = planningItems.firstIndex(where: { $0.id == item.id }) {
                                            withAnimation {
                                                planningItems[idx].isNeeded = false
                                            }
                                        }
                                    }) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                            .font(.title3)
                                    }
                                    .buttonStyle(.plain)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(item.name)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                        Text(item.categoryName)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.leading, 6)
                                    
                                    Spacer()
                                    
                                    Text(formatAmount(item.amount, unit: item.unit))
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .fontWeight(.semibold)
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.leading, 4)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    Section {
                        Button(action: {
                            showAddItemSheet = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.blue)
                                Text("Добавить товар...")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
    }
    
    var emptyStoreView: some View {
        VStack(spacing: 20) {
            Image(systemName: "cart.badge.plus")
                .font(.system(size: 64))
                .foregroundColor(.secondary.opacity(0.7))
            Text("В магазине пока нет товаров")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Для планирования закупки добавьте товары из каталога или создайте новые.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button("Добавить товар") {
                showAddItemSheet = true
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
        }
        .frame(maxHeight: .infinity)
    }
    

    
    private func formatAmount(_ amount: Double, unit: String) -> String {
        let isInteger = amount.truncatingRemainder(dividingBy: 1) == 0
        let valStr = isInteger ? String(Int(amount)) : String(format: "%.1f", amount)
        return "\(valStr) \(unit)"
    }
}

// MARK: - Tinder Card View
struct TinderCardView: View {
    @Binding var item: PlanningItem
    var onDecision: (Bool) -> Void
    
    @State private var translation: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            VStack(spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    VStack(spacing: 12) {
                        Image(systemName: "basket.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue.opacity(0.6))
                        
                        Text("Изображение товара")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(height: height * 0.44)
                .cornerRadius(16)
                .padding(12)
                
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.name)
                            .font(.title2)
                            .bold()
                            .foregroundColor(.primary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                        
                        Text(item.categoryName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Text("Количество:")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        HStack(spacing: 16) {
                            Button(action: {
                                if item.amount > 0.5 {
                                    item.amount -= 0.5
                                } else if item.amount > 0.1 {
                                    item.amount -= 0.1
                                }
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                            
                            Text(formatAmount(item.amount, unit: item.unit))
                                .font(.title3)
                                .fontWeight(.bold)
                                .frame(minWidth: 70)
                                .multilineTextAlignment(.center)
                            
                            Button(action: {
                                item.amount += 0.5
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Color(uiColor: .systemGray6))
                        .cornerRadius(12)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 40) {
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.spring()) {
                                translation = CGSize(width: -width * 1.5, height: 0)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                onDecision(false)
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.red.opacity(0.1))
                                    .frame(width: 56, height: 56)
                                Image(systemName: "xmark")
                                    .font(.title3)
                                    .bold()
                                    .foregroundColor(.red)
                            }
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: {
                            withAnimation(.spring()) {
                                translation = CGSize(width: width * 1.5, height: 0)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                onDecision(true)
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.green.opacity(0.1))
                                    .frame(width: 56, height: 56)
                                Image(systemName: "checkmark")
                                    .font(.title3)
                                    .bold()
                                    .foregroundColor(.green)
                            }
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                    }
                    .padding(.top, 8)
                }
                .padding([.horizontal, .bottom], 20)
            }
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            .overlay(
                ZStack {
                    if translation.width > 0 {
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.green, lineWidth: 6)
                        
                        Text("НАДО")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundColor(.green)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .border(Color.green, width: 4)
                            .cornerRadius(8)
                            .rotationEffect(.degrees(-15))
                            .opacity(Double(min(translation.width / (width / 3), 1)))
                    } else if translation.width < 0 {
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.red, lineWidth: 6)
                        
                        Text("НЕ НАДО")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundColor(.red)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .border(Color.red, width: 4)
                            .cornerRadius(8)
                            .rotationEffect(.degrees(15))
                            .opacity(Double(min(-translation.width / (width / 3), 1)))
                    }
                }
            )
            .offset(translation)
            .rotationEffect(.degrees(Double(translation.width / width * 25)))
            .gesture(
                DragGesture(minimumDistance: 10)
                    .onChanged { value in
                        translation = value.translation
                    }
                    .onEnded { value in
                        let threshold = width * 0.35
                        if value.translation.width > threshold {
                            withAnimation(.spring()) {
                                translation = CGSize(width: width * 1.5, height: value.translation.height)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                onDecision(true)
                            }
                        } else if value.translation.width < -threshold {
                            withAnimation(.spring()) {
                                translation = CGSize(width: -width * 1.5, height: value.translation.height)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                onDecision(false)
                            }
                        } else {
                            withAnimation(.spring()) {
                                translation = .zero
                            }
                        }
                    }
            )
        }
    }
    
    private func formatAmount(_ amount: Double, unit: String) -> String {
        let isInteger = amount.truncatingRemainder(dividingBy: 1) == 0
        let valStr = isInteger ? String(Int(amount)) : String(format: "%.1f", amount)
        return "\(valStr) \(unit)"
    }
}

// MARK: - Add Item View
struct AddItemView: View {
    @ObservedObject var authViewModel: AuthViewModel
    let store: shared.Store
    @Binding var planningItems: [PlanningItem]
    var onAdd: (PlanningItem) -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var showProductForm = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Button(action: {
                    showProductForm = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                        Text("Создать новый товар...")
                            .fontWeight(.semibold)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .padding()
                }
                
                Divider()
                
                catalogSelectionView
            }
            .navigationTitle("Добавить товар")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showProductForm) {
                ProductFormSheet(
                    authViewModel: authViewModel,
                    store: store,
                    productToEdit: nil,
                    onProductCreated: { productName in
                        let matchedCategory = authViewModel.categories.first
                        let newItem = PlanningItem(
                            id: UUID().uuidString,
                            name: productName,
                            categoryName: matchedCategory?.name ?? "Без категории",
                            amount: 1.0,
                            unit: "шт",
                            isNeeded: true
                        )
                        onAdd(newItem)
                        showProductForm = false
                        dismiss()
                    }
                )
            }
        }
    }
    
    var catalogSelectionView: some View {
        Group {
            let alreadyAddedNames = Set(planningItems.filter { $0.isNeeded }.map { $0.name.lowercased() })
            let availableProducts = authViewModel.products.filter { !alreadyAddedNames.contains($0.name.lowercased()) }
            
            if availableProducts.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "cart.badge.questionmark")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary.opacity(0.6))
                    Text("Все товары из каталога добавлены")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Вы можете создать новый товар, нажав на кнопку выше.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .frame(maxHeight: .infinity)
            } else {
                List(availableProducts, id: \.id) { product in
                    Button(action: {
                        let categoryName = product.categories.first?.name ?? "Без категории"
                        let newItem = PlanningItem(
                            id: product.id,
                            name: product.name,
                            categoryName: categoryName,
                            amount: 1.0,
                            unit: product.unit,
                            isNeeded: true
                        )
                        onAdd(newItem)
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(product.name)
                                    .foregroundColor(.primary)
                                Text(product.categories.first?.name ?? "Без категории")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "plus.circle")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
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
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 80, height: 80)
                                            .clipShape(Circle())
                                    case .failure, .empty:
                                        Image(systemName: "person.crop.circle.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 80, height: 80)
                                            .foregroundColor(.blue)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
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

// MARK: - Product Row Item & Category Group Structs
struct ProductRowItem: Identifiable {
    var id: String { "\(categoryId)-\(product.id)" }
    let categoryId: String
    let product: shared.Product
}

struct CategoryGroup: Identifiable {
    let id: String
    let name: String
    let icon: String?
    let items: [ProductRowItem]
}

// MARK: - Store Products View
struct StoreProductsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var authViewModel: AuthViewModel
    let store: shared.Store
    
    @State private var showProductForm = false
    @State private var productToEdit: shared.Product? = nil
    @State private var showAiPrompt = false
    @State private var storeDescription = ""
    
    // Grouped products helper
    private var groupedProducts: [CategoryGroup] {
        var groups: [CategoryGroup] = []
        
        // 1. Group by defined categories
        for category in authViewModel.categories {
            let matchingProducts = authViewModel.products.filter { product in
                product.categories.contains { $0.id == category.id }
            }
            if !matchingProducts.isEmpty {
                let rowItems = matchingProducts.map { ProductRowItem(categoryId: category.id, product: $0) }
                groups.append(CategoryGroup(
                    id: category.id,
                    name: category.name,
                    icon: category.icon,
                    items: rowItems
                ))
            }
        }
        
        // 2. Uncategorized products
        let uncategorizedProducts = authViewModel.products.filter { $0.categories.isEmpty }
        if !uncategorizedProducts.isEmpty {
            let rowItems = uncategorizedProducts.map { ProductRowItem(categoryId: "uncategorized", product: $0) }
            groups.append(CategoryGroup(
                id: "uncategorized",
                name: "Без категории",
                icon: "tag",
                items: rowItems
            ))
        }
        
        return groups
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if authViewModel.isLoadingData && authViewModel.products.isEmpty {
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Загрузка товаров...")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else if authViewModel.isAiGenerating {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("ИИ подбирает товары для магазина...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Это может занять до 15 секунд")
                            .font(.subheadline)
                            .foregroundColor(.secondary.opacity(0.8))
                    }
                    .padding()
                } else if authViewModel.products.isEmpty {
                    VStack(spacing: 24) {
                        Image(systemName: "cart.badge.plus")
                            .font(.system(size: 64))
                            .foregroundColor(.secondary.opacity(0.6))
                        
                        Text("В этом магазине пока нет товаров")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        Text("Вы можете добавить товары вручную или сгенерировать автоматический список с помощью ИИ на основе описания ассортимента.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        
                        Button(action: {
                            showAiPrompt = true
                        }) {
                            HStack {
                                Image(systemName: "sparkles")
                                Text("Сгенерировать с помощью ИИ")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .cornerRadius(16)
                            .shadow(color: Color.purple.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal, 32)
                        .padding(.top, 8)
                        
                        Button("Добавить товар вручную") {
                            productToEdit = nil
                            showProductForm = true
                        }
                        .font(.headline)
                        .foregroundColor(.blue)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(groupedProducts) { group in
                            Section(header: 
                                HStack(spacing: 6) {
                                    if let icon = group.icon {
                                        if icon.count == 1 {
                                            Text(icon)
                                        } else {
                                            Image(systemName: icon)
                                        }
                                    }
                                    Text(group.name)
                                }
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .textCase(nil)
                            ) {
                                ForEach(group.items) { item in
                                    let product = item.product
                                    HStack {
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text(product.name)
                                                .font(.body)
                                                .fontWeight(.semibold)
                                            
                                            HStack(spacing: 6) {
                                                Text(product.unit)
                                                    .font(.caption)
                                                    .fontWeight(.bold)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 3)
                                                    .background(Color.blue.opacity(0.1))
                                                    .foregroundColor(.blue)
                                                    .cornerRadius(6)
                                                
                                                ForEach(product.categories, id: \.id) { cat in
                                                    HStack(spacing: 3) {
                                                        if let icon = cat.icon {
                                                            Text(icon)
                                                        }
                                                        Text(cat.name)
                                                    }
                                                    .font(.caption)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 3)
                                                    .background(Color.purple.opacity(0.1))
                                                    .foregroundColor(.purple)
                                                    .cornerRadius(6)
                                                }
                                            }
                                        }
                                        Spacer()
                                    }
                                    .padding(.vertical, 4)
                                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                        Button {
                                            productToEdit = product
                                            showProductForm = true
                                        } label: {
                                            Label("Редактировать", systemImage: "pencil")
                                        }
                                        .tint(.blue)
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            Task {
                                                await authViewModel.deleteProduct(id: product.id, storeId: store.id)
                                            }
                                        } label: {
                                            Label("Удалить", systemImage: "trash")
                                        }
                                        .tint(.red)
                                    }
                                    .contextMenu {
                                        Button {
                                            productToEdit = product
                                            showProductForm = true
                                        } label: {
                                            Label("Редактировать", systemImage: "pencil")
                                        }
                                        
                                        Button(role: .destructive) {
                                            Task {
                                                await authViewModel.deleteProduct(id: product.id, storeId: store.id)
                                            }
                                        } label: {
                                            Label("Удалить", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle(store.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !authViewModel.products.isEmpty && !authViewModel.isAiGenerating {
                        Button(action: {
                            productToEdit = nil
                            showProductForm = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .task {
                await authViewModel.fetchProducts(storeId: store.id)
                await authViewModel.fetchCategories()
                await authViewModel.fetchMeasureUnits()
            }
            .sheet(isPresented: $showProductForm) {
                ProductFormSheet(
                    authViewModel: authViewModel,
                    store: store,
                    productToEdit: productToEdit
                )
            }
            .sheet(isPresented: $showAiPrompt) {
                AiGenerationPromptSheet(
                    isPresented: $showAiPrompt,
                    storeDescription: $storeDescription,
                    onGenerate: {
                        Task {
                            await authViewModel.generateProductsWithAi(
                                storeDescription: storeDescription,
                                storeId: store.id
                            )
                        }
                    }
                )
            }
        }
    }
}

// MARK: - AI Generation Prompt Sheet
struct AiGenerationPromptSheet: View {
    @Binding var isPresented: Bool
    @Binding var storeDescription: String
    @State private var desc = ""
    var onGenerate: () -> Void
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Описание ассортимента магазина")) {
                    TextEditor(text: $desc)
                        .frame(height: 120)
                        .overlay(
                            Group {
                                if desc.isEmpty {
                                    Text("Например: Магазин Красное и Белое, пиво, чипсы, орешки, сухарики, газировка, соки...")
                                        .font(.body)
                                        .foregroundColor(.gray.opacity(0.6))
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 8)
                                }
                            },
                            alignment: .topLeading
                        )
                }
                
                Section {
                    Button(action: {
                        storeDescription = desc
                        isPresented = false
                        onGenerate()
                    }) {
                        Text("Сгенерировать товары (10 шт)")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(desc.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.purple)
                    .disabled(desc.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .navigationTitle("Генерация через ИИ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Product Form Sheet
struct ProductFormSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var authViewModel: AuthViewModel
    let store: shared.Store
    let productToEdit: shared.Product?
    var onProductCreated: ((String) -> Void)? = nil
    
    @State private var name = ""
    @State private var selectedUnit = "шт"
    @State private var selectedCategoryIds: Set<String> = []
    
    // Add new entity states
    @State private var showAddCategory = false
    @State private var newCategoryName = ""
    @State private var newCategoryIcon = ""
    
    @State private var showAddUnit = false
    @State private var newUnitName = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Основная информация")) {
                    TextField("Название товара", text: $name)
                }
                
                Section(header: Text("Единица измерения")) {
                    Picker("Единица", selection: $selectedUnit) {
                        ForEach(authViewModel.measureUnits, id: \.name) { unit in
                            Text(unit.name).tag(unit.name)
                        }
                    }
                    
                    Button(action: {
                        showAddUnit = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Добавить свою единицу измерения")
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                Section(header: Text("Категории товара")) {
                    if authViewModel.categories.isEmpty {
                        Text("Категорий нет. Создайте новую ниже.")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    } else {
                        List {
                            ForEach(authViewModel.categories, id: \.id) { category in
                                HStack {
                                    if let icon = category.icon {
                                        Text(icon)
                                    }
                                    Text(category.name)
                                    Spacer()
                                    if selectedCategoryIds.contains(category.id) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if selectedCategoryIds.contains(category.id) {
                                        selectedCategoryIds.remove(category.id)
                                    } else {
                                        selectedCategoryIds.insert(category.id)
                                    }
                                }
                            }
                        }
                    }
                    
                    Button(action: {
                        showAddCategory = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Добавить новую категорию")
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle(productToEdit == nil ? "Добавить товар" : "Редактировать товар")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        Task {
                            let catIdsArray = Array(selectedCategoryIds)
                            if let editProduct = productToEdit {
                                await authViewModel.updateProduct(
                                    id: editProduct.id,
                                    name: name,
                                    unit: selectedUnit,
                                    categoryIds: catIdsArray,
                                    storeId: store.id
                                )
                            } else {
                                await authViewModel.createProduct(
                                    name: name,
                                    unit: selectedUnit,
                                    categoryIds: catIdsArray,
                                    storeId: store.id
                                )
                                onProductCreated?(name)
                            }
                            dismiss()
                        }
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                if let editProduct = productToEdit {
                    name = editProduct.name
                    selectedUnit = editProduct.unit
                    selectedCategoryIds = Set(editProduct.categories.map { $0.id })
                } else {
                    if let firstUnit = authViewModel.measureUnits.first {
                        selectedUnit = firstUnit.name
                    }
                }
            }
            .sheet(isPresented: $showAddUnit) {
                NavigationView {
                    Form {
                        TextField("Название (например: мл, бут)", text: $newUnitName)
                    }
                    .navigationTitle("Новая единица измерения")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Отмена") {
                                showAddUnit = false
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Добавить") {
                                Task {
                                    if let created = await authViewModel.createMeasureUnit(name: newUnitName) {
                                        selectedUnit = created.name
                                    }
                                    newUnitName = ""
                                    showAddUnit = false
                                }
                            }
                            .disabled(newUnitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddCategory) {
                NavigationView {
                    Form {
                        TextField("Название категории", text: $newCategoryName)
                        TextField("Эмодзи-иконка (необязательно)", text: $newCategoryIcon)
                    }
                    .navigationTitle("Новая категория")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Отмена") {
                                showAddCategory = false
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Добавить") {
                                Task {
                                    let iconVal = newCategoryIcon.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : newCategoryIcon
                                    if let created = await authViewModel.createCategory(name: newCategoryName, icon: iconVal) {
                                        selectedCategoryIds.insert(created.id)
                                    }
                                    newCategoryName = ""
                                    newCategoryIcon = ""
                                    showAddCategory = false
                                }
                            }
                            .disabled(newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                }
            }
        }
    }
}