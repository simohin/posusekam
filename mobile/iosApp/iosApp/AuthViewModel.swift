import SwiftUI
import shared
import GoogleSignIn

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let repository: AuthRepository
    
    init(baseUrl: String) {
        self.repository = AuthRepository(baseUrl: baseUrl)
        self.isAuthenticated = repository.isAuthenticated()
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
                    self.isAuthenticated = true
                } catch {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func logout() {
        repository.logout()
        self.isAuthenticated = false
    }
    
    private func getRootViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return nil
        }
        return scene.windows.first?.rootViewController
    }
}
