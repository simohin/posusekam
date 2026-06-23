import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Adaptive Apple system background
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                // Subtle brand ambient glow
                VStack {
                    Circle()
                        .fill(Color.blue.opacity(colorScheme == .dark ? 0.15 : 0.08))
                        .frame(width: 350, height: 350)
                        .blur(radius: 60)
                        .offset(x: -100, y: -150)
                    Spacer()
                    Circle()
                        .fill(Color.teal.opacity(colorScheme == .dark ? 0.12 : 0.06))
                        .frame(width: 300, height: 300)
                        .blur(radius: 50)
                        .offset(x: 100, y: 150)
                }
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Spacer()
                    
                    // Brand Header
                    VStack(spacing: 12) {
                        Image(systemName: "banknote.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .teal],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                            .padding(.bottom, 8)
                        
                        Text("POSUSEKAM")
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .tracking(1.5)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        colorScheme == .dark ? .white : .black,
                                        .blue
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("Сберегай по сусекам")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 20)
                    
                    // Features / Card styled with Apple HIG Materials
                    VStack(alignment: .leading, spacing: 18) {
                        FeatureRow(
                            icon: "lock.shield.fill",
                            iconColor: .green,
                            title: "Безопасный вход",
                            subtitle: "Авторизация через Google с шифрованием данных"
                        )
                        
                        FeatureRow(
                            icon: "arrow.triangle.2.circlepath",
                            iconColor: .blue,
                            title: "Мгновенная синхронизация",
                            subtitle: "Ваши накопления доступны на всех устройствах"
                        )
                        
                        FeatureRow(
                            icon: "chart.pie.fill",
                            iconColor: .orange,
                            title: "Умная аналитика",
                            subtitle: "Отслеживайте цели и прогресс накоплений"
                        )
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(uiColor: .secondarySystemGroupedBackground))
                            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.06), radius: 15, x: 0, y: 8)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.primary.opacity(0.04), lineWidth: 1)
                    )
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    
                    // Action Section
                    VStack(spacing: 16) {
                        if let errorMessage = viewModel.errorMessage {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                Text(errorMessage)
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 24)
                            .transition(.opacity.combined(with: .scale))
                        }
                        
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                .scaleEffect(1.2)
                                .frame(height: 54)
                        } else {
                            Button(action: {
                                withAnimation {
                                    viewModel.signInWithGoogle()
                                }
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "g.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                    
                                    Text("Войти с Google")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(
                                            LinearGradient(
                                                colors: [.blue, .cyan],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                )
                                .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            .buttonStyle(ScaleButtonStyle())
                            .padding(.horizontal, 24)
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
        }
    }
}

// Helper Views for HIG styling
struct FeatureRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(iconColor)
                .cornerRadius(10)
                .shadow(color: iconColor.opacity(0.3), radius: 4, x: 0, y: 2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
