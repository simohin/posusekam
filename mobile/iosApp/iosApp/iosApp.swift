import SwiftUI
import shared

@main
struct iosApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var count: Int = 10
    @State private var result: [Int] = []

    var body: some View {
        VStack(spacing: 20) {
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
                result = kotlinList.map { Int(truncating: $0 as! NSNumber) }
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