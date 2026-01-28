//
//  RegisterView.swift
//  trip-mind-mobile
//
//  Registration screen
//

import SwiftUI

struct RegisterView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            AuthBackground()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: DesignSystem.spacing6) {
                    VStack(spacing: DesignSystem.spacing2) {
                        Text("Create Account")
                            .font(.system(size: DesignSystem.FontSize.xl2.value, weight: .bold))
                            .foregroundColor(DesignSystem.foreground)
                        
                        Text("Start planning your next adventure.")
                            .font(.system(size: DesignSystem.FontSize.sm.value))
                            .foregroundColor(DesignSystem.mutedForeground)
                    }
                    .padding(.top, DesignSystem.spacing8)
                    
                    AuthCard {
                        VStack(spacing: DesignSystem.spacing4) {
                            AuthField(
                                title: "Name",
                                placeholder: "Your name",
                                text: $name,
                                textContentType: .name,
                                autocapitalization: .words
                            )
                            
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
                                placeholder: "Create a password",
                                text: $password,
                                textContentType: .newPassword
                            )
                            
                            AuthSecureField(
                                title: "Confirm Password",
                                placeholder: "Re-enter your password",
                                text: $confirmPassword,
                                textContentType: .newPassword
                            )
                            
                            if let errorMessage = errorMessage {
                                Text(errorMessage)
                                    .font(.system(size: DesignSystem.FontSize.sm.value))
                                    .foregroundColor(DesignSystem.destructive)
                            }
                            
                            Button(action: handleRegister) {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Register")
                                        .font(.system(size: DesignSystem.FontSize.base.value, weight: .semibold))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: DesignSystem.buttonHeightTouch)
                            .background(DesignSystem.primaryColor)
                            .foregroundColor(DesignSystem.primaryForeground)
                            .cornerRadius(DesignSystem.radiusMedium)
                            .disabled(isLoading)
                        }
                    }
                    .padding(.horizontal, DesignSystem.spacing4)
                    
                    Spacer()
                        .frame(height: DesignSystem.spacing8)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        // If auth succeeds, pop this screen (root likely swaps to MainTabView anyway)
        .onChange(of: authManager.isAuthenticated) { _, isAuthed in
            if isAuthed {
                dismiss()
            }
        }
    }
    
    // Trimmed helpers used in validation and submission
    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private var trimmedEmail: String {
        email.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private var isEmailValid: Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: trimmedEmail)
    }
    
    private func validateForm() -> String? {
        if trimmedName.isEmpty { return "Please enter your name" }
        if trimmedEmail.isEmpty { return "Please enter your email" }
        if !isEmailValid { return "Please enter a valid email address" }
        if password.count < 6 { return "Password must be at least 6 characters" }
        if password != confirmPassword { return "Passwords do not match" }
        return nil
    }
    
    private func handleRegister() {
        if let validationError = validateForm() {
            errorMessage = validationError
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await authManager.register(
                    name: trimmedName,
                    email: trimmedEmail.lowercased(),
                    password: password
                )
                await MainActor.run {
                    isLoading = false
                }
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
        RegisterView()
            .environmentObject(AuthManager())
    }
}
