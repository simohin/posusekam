import SwiftUI
import shared

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
                ContentView(authViewModel: authViewModel)
            } else {
                LoginView(viewModel: authViewModel)
            }
        }
    }
}

struct ContentView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var count: Int = 10
    @State private var result: [Int] = []

    var body: some View {
        VStack(spacing: 20) {
            // Logout bar
            HStack {
                Spacer()
                Button(action: {
                    authViewModel.logout()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.right.square")
                        Text("Выйти")
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
                }
                .padding(.top, 10)
                .padding(.trailing, 10)
            }
            
            Text("POSUSEKAM")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Kotlin Multiplatform + SwiftUI")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Stepper("Generate: \(count) numbers", value: $count, in: 0...20)
                .padding()
            
            Button(action: {
                // Вызываем функцию из общего Kotlin-кода
                let kotlinList = FibonacciKt.generateFibonacci(count: Int32(count))
                // Конвертируем Kotlin List в Swift Array
                result = kotlinList.map { Int(truncating: $0 as NSNumber) }
            }) {
                Text("Generate Fibonacci")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.indigo)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            if !result.isEmpty {
                ScrollView {
                    Text(result.map { String($0) }.joined(separator: ", "))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.indigo)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            } else {
                Spacer()
            }
        }
        .padding()
    }
}