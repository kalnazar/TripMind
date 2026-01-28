//
//  AuthComponents.swift
//  trip-mind-mobile
//
//  Shared UI pieces for authentication screens
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct AuthBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    DesignSystem.primaryColor.opacity(0.12),
                    Color.white,
                    DesignSystem.muted.opacity(0.6)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            Circle()
                .fill(DesignSystem.primaryColor.opacity(0.18))
                .frame(width: 220, height: 220)
                .offset(x: -140, y: -180)
            
            Circle()
                .fill(Color.blue.opacity(0.12))
                .frame(width: 240, height: 240)
                .offset(x: 160, y: -160)
            
            RoundedRectangle(cornerRadius: 60, style: .continuous)
                .fill(DesignSystem.primaryColor.opacity(0.08))
                .frame(width: 200, height: 120)
                .rotationEffect(.degrees(18))
                .offset(x: -120, y: 280)
        }
        .ignoresSafeArea()
    }
}

struct AuthCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(DesignSystem.spacing6)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(DesignSystem.card)
            .cornerRadius(DesignSystem.radiusXLarge)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.radiusXLarge)
                    .stroke(DesignSystem.border, lineWidth: 1)
            )
            .shadow(color: DesignSystem.border.opacity(0.6), radius: 18, x: 0, y: 10)
    }
}

struct AuthField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    var autocapitalization: TextInputAutocapitalization = .never
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: DesignSystem.FontSize.sm.value, weight: .semibold))
                .foregroundColor(DesignSystem.mutedForeground)
            
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(autocapitalization)
                .autocorrectionDisabled()
                .textContentType(textContentType)
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(DesignSystem.muted.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(DesignSystem.border, lineWidth: 1)
                )
        }
    }
}

struct AuthSecureField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var textContentType: UITextContentType? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: DesignSystem.FontSize.sm.value, weight: .semibold))
                .foregroundColor(DesignSystem.mutedForeground)
            
            SecureField(placeholder, text: $text)
                .textContentType(textContentType)
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(DesignSystem.muted.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(DesignSystem.border, lineWidth: 1)
                )
        }
    }
}
