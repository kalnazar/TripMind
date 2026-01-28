//
//  ChatBubbleView.swift
//  trip-mind-mobile
//
//  Chat message bubble component
//

import SwiftUI

struct ChatBubbleView: View {
    let message: ChatMessage
    var onOptionSelected: ((ChatOption) -> Void)?
    
    var body: some View {
        HStack {
            if message.role == .user {
                Spacer()
            }
            
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: DesignSystem.spacing2) {
                Text(message.content)
                    .font(.system(size: DesignSystem.FontSize.base.value))
                    .foregroundColor(message.role == .user ? DesignSystem.primaryForeground : DesignSystem.foreground)
                    .padding(DesignSystem.spacing3)
                    .background(
                        message.role == .user
                            ? DesignSystem.primaryColor
                            : DesignSystem.muted
                    )
                    .cornerRadius(DesignSystem.radiusLarge)
                
                // Options buttons
                if let meta = message.meta, let options = meta.options, message.role == .assistant {
                    VStack(alignment: .leading, spacing: DesignSystem.spacing2) {
                        ForEach(options) { option in
                            Button(action: {
                                onOptionSelected?(option)
                            }) {
                                HStack {
                                    if let emoji = option.emoji {
                                        Text(emoji)
                                    }
                                    Text(option.label)
                                        .font(.system(size: DesignSystem.FontSize.base.value))
                                    
                                    if let subtitle = option.subtitle {
                                        Text(subtitle)
                                            .font(.system(size: DesignSystem.FontSize.sm.value))
                                            .foregroundColor(DesignSystem.mutedForeground)
                                    }
                                }
                                .padding(.horizontal, DesignSystem.spacing4)
                                .padding(.vertical, DesignSystem.spacing3)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(DesignSystem.card)
                                .foregroundColor(DesignSystem.foreground)
                                .cornerRadius(DesignSystem.radiusMedium)
                                .overlay(
                                    RoundedRectangle(cornerRadius: DesignSystem.radiusMedium)
                                        .stroke(DesignSystem.border, lineWidth: 1)
                                )
                            }
                        }
                    }
                    .padding(.top, DesignSystem.spacing2)
                }
            }
            .frame(maxWidth: (UIScreen.current?.bounds.width ?? 0) * 0.75, alignment: message.role == .user ? .trailing : .leading)
            
            if message.role == .assistant {
                Spacer()
            }
        }
    }
}

#Preview {
    VStack {
        ChatBubbleView(message: ChatMessage(
            role: .user,
            content: "I want to plan a trip to Paris"
        ))
        
        ChatBubbleView(message: ChatMessage(
            role: .assistant,
            content: "Great! What's your budget?",
            meta: ChatMeta(
                ui: "budget",
                options: [
                    ChatOption(label: "Low", value: "Low", emoji: "💵"),
                    ChatOption(label: "Medium", value: "Medium", emoji: "💳"),
                    ChatOption(label: "High", value: "High", emoji: "💎")
                ]
            )
        ))
    }
    .padding()
}
