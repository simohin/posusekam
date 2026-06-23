import SwiftUI
import shared
import GoogleSignIn

struct UserProfile {
    let id: String
    let email: String
    let name: String?
    let avatarUrl: String?
    let provider: LoginProvider
    
    enum LoginProvider: String {
        case google = "Google"
        case apple = "Apple"
        case email = "Email"
        case unknown = "Неизвестный"
    }
}

struct JWTClaims: Codable {
    let sub: String
    let email: String
    let name: String?
    let picture: String?
    let iss: String?
    let provider: String?
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var userProfile: UserProfile? = nil
    
    // Households & Stores state
    @Published var households: [shared.Household] = []
    @Published var activeHousehold: shared.Household? = nil
    @Published var stores: [shared.Store] = []
    @Published var isLoadingData: Bool = false
    @Published var metadata: shared.AppMetadataDto? = nil
    
    private let repository: AuthRepository
    private let householdRepository: HouseholdRepository
    private let storeRepository: StoreRepository
    private let metadataRepository: MetadataRepository
    
    init(baseUrl: String) {
        self.repository = AuthRepository(baseUrl: baseUrl)
        self.householdRepository = HouseholdRepository(baseUrl: baseUrl)
        self.storeRepository = StoreRepository(baseUrl: baseUrl)
        self.metadataRepository = MetadataRepository(baseUrl: baseUrl)
        
        self.isAuthenticated = repository.isAuthenticated()
        if self.isAuthenticated {
            self.userProfile = decodeUserProfile(from: repository.getAccessToken())
            // Fetch initial data if already authenticated
            Task {
                await fetchHouseholds()
                await fetchMetadata()
            }
        }
    }
    
    func signInWithGoogle() {
        guard let rootViewController = getRootViewController() else {
            self.errorMessage = "Could not find root view controller"
            return
        }
        
        self.isLoading = true
        self.errorMessage = nil
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] signInResult, error in
            guard let self = self else { return }
            
            let extractedError = error
            let extractedIdToken = signInResult?.user.idToken?.tokenString
            
            Task { @MainActor in
                if let error = extractedError {
                    self.isLoading = false
                    if (error as NSError).code != GIDSignInError.canceled.rawValue {
                        self.errorMessage = error.localizedDescription
                    }
                    return
                }
                
                guard let idToken = extractedIdToken else {
                    self.isLoading = false
                    self.errorMessage = "Failed to get Google ID Token"
                    return
                }
                
                do {
                    _ = try await self.repository.authenticateWithGoogle(idToken: idToken)
                    self.isLoading = false
                    self.userProfile = self.decodeUserProfile(from: self.repository.getAccessToken())
                    self.isAuthenticated = true
                    // Fetch initial data upon login
                    await self.fetchHouseholds()
                    await self.fetchMetadata()
                } catch {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func logout() {
        repository.logout()
        self.userProfile = nil
        self.households = []
        self.activeHousehold = nil
        self.stores = []
        self.metadata = nil
        self.isAuthenticated = false
    }
    
    func fetchMetadata() async {
        do {
            let meta = try await metadataRepository.getMetadata()
            self.metadata = meta
        } catch {
            self.errorMessage = "Ошибка при загрузке метаданных: \(error.localizedDescription)"
            if error.localizedDescription.contains("401") {
                self.logout()
            }
        }
    }
    
    // --- Households CRUD ---
    
    func fetchHouseholds() async {
        self.isLoadingData = true
        self.errorMessage = nil
        do {
            let list = try await householdRepository.getHouseholds()
            self.households = list
            if let active = self.activeHousehold, list.contains(where: { $0.id == active.id }) {
                // keep current active
                if let updatedActive = list.first(where: { $0.id == active.id }) {
                    self.activeHousehold = updatedActive
                }
            } else {
                self.activeHousehold = list.first
            }
            await fetchStores()
        } catch {
            self.errorMessage = "Ошибка при загрузке домовладений: \(error.localizedDescription)"
            if error.localizedDescription.contains("401") {
                self.logout()
            }
        }
        self.isLoadingData = false
    }
    
    func createHousehold(name: String) async {
        self.isLoadingData = true
        self.errorMessage = nil
        do {
            let newHh = try await householdRepository.createHousehold(name: name)
            await fetchHouseholds()
            self.activeHousehold = newHh
            await fetchStores()
        } catch {
            self.errorMessage = "Не удалось создать домовладение: \(error.localizedDescription)"
        }
        self.isLoadingData = false
    }
    
    func updateHousehold(id: String, name: String) async {
        self.isLoadingData = true
        self.errorMessage = nil
        do {
            _ = try await householdRepository.updateHousehold(id: id, name: name)
            await fetchHouseholds()
        } catch {
            self.errorMessage = "Не удалось обновить домовладение: \(error.localizedDescription)"
        }
        self.isLoadingData = false
    }
    
    func deleteHousehold(id: String) async {
        self.isLoadingData = true
        self.errorMessage = nil
        do {
            try await householdRepository.deleteHousehold(id: id)
            if activeHousehold?.id == id {
                activeHousehold = nil
            }
            await fetchHouseholds()
        } catch {
            self.errorMessage = "Не удалось удалить домовладение: \(error.localizedDescription)"
        }
        self.isLoadingData = false
    }
    
    // --- Stores CRUD ---
    
    func fetchStores() async {
        guard let householdId = activeHousehold?.id else {
            self.stores = []
            return
        }
        self.isLoadingData = true
        self.errorMessage = nil
        do {
            let list = try await storeRepository.getStores(householdId: householdId)
            self.stores = list
        } catch {
            self.errorMessage = "Ошибка при загрузке магазинов: \(error.localizedDescription)"
            if error.localizedDescription.contains("401") {
                self.logout()
            }
        }
        self.isLoadingData = false
    }
    
    func selectHousehold(_ household: shared.Household) {
        self.activeHousehold = household
        Task {
            await fetchStores()
        }
    }
    
    func createStore(name: String, icon: String? = nil, color: String? = nil) async {
        guard let householdId = activeHousehold?.id else { return }
        self.isLoadingData = true
        self.errorMessage = nil
        do {
            _ = try await storeRepository.createStore(householdId: householdId, name: name, icon: icon, color: color)
            await fetchStores()
        } catch {
            self.errorMessage = "Не удалось создать магазин: \(error.localizedDescription)"
        }
        self.isLoadingData = false
    }
    
    func updateStore(id: String, name: String, icon: String? = nil, color: String? = nil) async {
        guard let householdId = activeHousehold?.id else { return }
        self.isLoadingData = true
        self.errorMessage = nil
        do {
            _ = try await storeRepository.updateStore(householdId: householdId, id: id, name: name, icon: icon, color: color)
            await fetchStores()
        } catch {
            self.errorMessage = "Не удалось обновить магазин: \(error.localizedDescription)"
        }
        self.isLoadingData = false
    }
    
    func deleteStore(id: String) async {
        guard let householdId = activeHousehold?.id else { return }
        self.isLoadingData = true
        self.errorMessage = nil
        do {
            try await storeRepository.deleteStore(householdId: householdId, id: id)
            await fetchStores()
        } catch {
            self.errorMessage = "Не удалось удалить магазин: \(error.localizedDescription)"
        }
        self.isLoadingData = false
    }
    
    // --- Helpers ---
    
    private func getRootViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return nil
        }
        return scene.windows.first?.rootViewController
    }
    
    private func decodeUserProfile(from token: String?) -> UserProfile? {
        guard let token = token else { return nil }
        let parts = token.components(separatedBy: ".")
        guard parts.count > 1 else { return nil }
        let payloadPart = parts[1]
        
        var base64 = payloadPart
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        let padding = base64.count % 4
        if padding > 0 {
            base64 += String(repeating: "=", count: 4 - padding)
        }
        
        guard let data = Data(base64Encoded: base64),
              let claims = try? JSONDecoder().decode(JWTClaims.self, from: data) else {
            return nil
        }
        
        let provider: UserProfile.LoginProvider
        if let providerClaim = claims.provider {
            provider = UserProfile.LoginProvider(rawValue: providerClaim) ?? .unknown
        } else if let issuer = claims.iss {
            if issuer.contains("google") || claims.email.contains("@gmail.com") {
                provider = .google
            } else if issuer.contains("apple") {
                provider = .apple
            } else {
                provider = .email
            }
        } else {
            provider = .unknown
        }
        
        return UserProfile(
            id: claims.sub,
            email: claims.email,
            name: claims.name ?? claims.email.components(separatedBy: "@").first,
            avatarUrl: claims.picture,
            provider: provider
        )
    }
}
