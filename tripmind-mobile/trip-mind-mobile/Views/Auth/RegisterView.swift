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
        VStack(spacing: DesignSystem.spacing6) {
            // Header
            VStack(spacing: DesignSystem.spacing2) {
                Text("Create Account")
                    .font(.system(size: DesignSystem.FontSize.xl2.value, weight: .bold))
                    .foregroundColor(DesignSystem.foreground)
                
                Text("Start planning your trips")
                    .font(.system(size: DesignSystem.FontSize.base.value))
                    .foregroundColor(DesignSystem.mutedForeground)
            }
            .padding(.top, DesignSystem.spacing8)
            .padding(.bottom, DesignSystem.spacing4)
            
            // Form
            VStack(spacing: DesignSystem.spacing4) {
                VStack(alignment: .leading, spacing: DesignSystem.spacing2) {
                    Text("Name")
                        .font(.system(size: DesignSystem.FontSize.sm.value))
                        .foregroundColor(DesignSystem.mutedForeground)
                    
                    TextField("Enter your name", text: $name)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.words)
                        .textContentType(.name)
                }
                
                VStack(alignment: .leading, spacing: DesignSystem.spacing2) {
                    Text("Email")
                        .font(.system(size: DesignSystem.FontSize.sm.value))
                        .foregroundColor(DesignSystem.mutedForeground)
                    
                    TextField("Enter your email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .textInputAutocapitalization(.never)
                        .textContentType(.emailAddress)
                }
                
                VStack(alignment: .leading, spacing: DesignSystem.spacing2) {
                    Text("Password")
                        .font(.system(size: DesignSystem.FontSize.sm.value))
                        .foregroundColor(DesignSystem.mutedForeground)
                    
                    SecureField("Enter your password", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.newPassword)
                }
                
                VStack(alignment: .leading, spacing: DesignSystem.spacing2) {
                    Text("Confirm Password")
                        .font(.system(size: DesignSystem.FontSize.sm.value))
                        .foregroundColor(DesignSystem.mutedForeground)
                    
                    SecureField("Confirm your password", text: $confirmPassword)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.newPassword)
                }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(.system(size: DesignSystem.FontSize.sm.value))
                        .foregroundColor(DesignSystem.destructive)
                        .padding(.top, DesignSystem.spacing2)
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
                // Only disable while loading so taps always produce feedback
                .disabled(isLoading)
                .padding(.top, DesignSystem.spacing2)
            }
            .padding(.horizontal, DesignSystem.spacing4)
            
            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
        // If auth succeeds, pop this screen (root likely swaps to MainTabView anyway)
        .onChange(of: authManager.isAuthenticated) { isAuthed in
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
