//
//  ChatInputView.swift
//  trip-mind-mobile
//
//  Chat input component
//

import SwiftUI

struct ChatInputView: View {
    @ObservedObject var viewModel: ChatViewModel
    @State private var inputText = ""
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        HStack(spacing: DesignSystem.spacing3) {
            TextField("Type your message...", text: $inputText)
                .textFieldStyle(.roundedBorder)
                .focused($isInputFocused)
                .onSubmit {
                    sendMessage()
                }
            
            Button(action: sendMessage) {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(DesignSystem.primaryColor)
            }
            .disabled(inputText.isEmpty || viewModel.isLoading)
        }
    }
    
    private func sendMessage() {
        print("[ChatInputView.sendMessage] Starting message send")
        guard !inputText.isEmpty else {
            print("[ChatInputView.sendMessage] Input text is empty, returning")
            return
        }
        
        print("[ChatInputView.sendMessage] User input: \(inputText)")
        let userMessage = ChatMessage(role: .user, content: inputText)
        viewModel.messages.append(userMessage)
        print("[ChatInputView.sendMessage] User message appended to viewModel")
        
        let text = inputText
        inputText = ""
        print("[ChatInputView.sendMessage] Cleared input text")
        
        // Dismiss keyboard
        isInputFocused = false
        
        Task {
            print("[ChatInputView.sendMessage] Starting async sendMessage call")
            await viewModel.sendMessage(text)
            print("[ChatInputView.sendMessage] Async sendMessage completed")
        }
    }
}
