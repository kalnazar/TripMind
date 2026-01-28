//
//  LoginView.swift
//  trip-mind-mobile
//
//  Login screen
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showRegister = false
    
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        ZStack {
            AuthBackground()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: DesignSystem.spacing6) {
                    VStack(spacing: DesignSystem.spacing2) {
                        Image(systemName: "airplane.departure")
                            .font(.system(size: 54, weight: .semibold))
                            .foregroundColor(DesignSystem.primaryColor)
                        
                        Text("Welcome back")
                            .font(.system(size: DesignSystem.FontSize.xl2.value, weight: .bold))
                            .foregroundColor(DesignSystem.foreground)
                        
                        Text("Sign in to continue planning with TripMind.")
                            .font(.system(size: DesignSystem.FontSize.sm.value))
                            .foregroundColor(DesignSystem.mutedForeground)
                    }
                    .padding(.top, DesignSystem.spacing8)
                    
                    AuthCard {
                        VStack(spacing: DesignSystem.spacing4) {
                            AuthField(
                                title: "Email",
                                placeholder: "you@tripmind.com",
                                text: $email,
                                keyboardType: .emailAddress,
                                textContentType: .emailAddress,
                                autocapitalization: .never
                            )
                            
                            AuthSecureField(
                                title: "Password",
                                placeholder: "Enter your password",
                                text: $password,
                                textContentType: .password
                            )
                            
                            if let errorMessage = errorMessage {
                                Text(errorMessage)
                                    .font(.system(size: DesignSystem.FontSize.sm.value))
                                    .foregroundColor(DesignSystem.destructive)
                            }
                            
                            Button(action: handleLogin) {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Login")
                                        .font(.system(size: DesignSystem.FontSize.base.value, weight: .semibold))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: DesignSystem.buttonHeightTouch)
                            .background(DesignSystem.primaryColor)
                            .foregroundColor(DesignSystem.primaryForeground)
                            .cornerRadius(DesignSystem.radiusMedium)
                            .disabled(isLoading || email.isEmpty || password.isEmpty)
                        }
                    }
                    .padding(.horizontal, DesignSystem.spacing4)
                    
                    HStack(spacing: 6) {
                        Text("Don’t have an account?")
                            .font(.system(size: DesignSystem.FontSize.sm.value))
                            .foregroundColor(DesignSystem.mutedForeground)
                        
                        NavigationLink("Register", destination: RegisterView())
                            .font(.system(size: DesignSystem.FontSize.sm.value, weight: .semibold))
                            .foregroundColor(DesignSystem.primaryColor)
                    }
                    .padding(.bottom, DesignSystem.spacing8)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func handleLogin() {
        guard !email.isEmpty, !password.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await authManager.login(email: email, password: password)
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        LoginView()
            .environmentObject(AuthManager())
    }
}
