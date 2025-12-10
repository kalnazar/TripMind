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
        VStack(spacing: DesignSystem.spacing6) {
            // Logo/Title
            VStack(spacing: DesignSystem.spacing2) {
                Image(systemName: "airplane.departure")
                    .font(.system(size: 60))
                    .foregroundColor(DesignSystem.primaryColor)
                
                Text("TripMind")
                    .font(.system(size: DesignSystem.FontSize.xl3.value, weight: .bold))
                    .foregroundColor(DesignSystem.foreground)
            }
            .padding(.top, DesignSystem.spacing8)
            .padding(.bottom, DesignSystem.spacing4)
            
            // Form
            VStack(spacing: DesignSystem.spacing4) {
                VStack(alignment: .leading, spacing: DesignSystem.spacing2) {
                    Text("Email")
                        .font(.system(size: DesignSystem.FontSize.sm.value))
                        .foregroundColor(DesignSystem.mutedForeground)
                    
                    TextField("Enter your email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .textInputAutocapitalization(.never)
                }
                
                VStack(alignment: .leading, spacing: DesignSystem.spacing2) {
                    Text("Password")
                        .font(.system(size: DesignSystem.FontSize.sm.value))
                        .foregroundColor(DesignSystem.mutedForeground)
                    
                    SecureField("Enter your password", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.password)
                }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(.system(size: DesignSystem.FontSize.sm.value))
                        .foregroundColor(DesignSystem.destructive)
                        .padding(.top, DesignSystem.spacing2)
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
                .padding(.top, DesignSystem.spacing2)
            }
            .padding(.horizontal, DesignSystem.spacing4)
            
            // Register link
            HStack {
                Text("Don't have an account?")
                    .font(.system(size: DesignSystem.FontSize.sm.value))
                    .foregroundColor(DesignSystem.mutedForeground)
                
                NavigationLink("Register", destination: RegisterView())
                    .font(.system(size: DesignSystem.FontSize.sm.value, weight: .semibold))
                    .foregroundColor(DesignSystem.primaryColor)
            }
            .padding(.top, DesignSystem.spacing4)
            
            Spacer()
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
