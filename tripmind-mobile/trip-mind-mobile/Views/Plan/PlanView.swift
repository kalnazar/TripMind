//
//  PlanView.swift
//  trip-mind-mobile
//
//  AI chat-based trip planning
//

import SwiftUI

struct PlanView: View {
    @StateObject private var chatViewModel = ChatViewModel()
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        VStack(spacing: 0) {
            // Always show chat interface
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: DesignSystem.spacing4) {
                        ForEach(chatViewModel.messages) { message in
                            ChatBubbleView(message: message) { option in
                                Task { await chatViewModel.selectOption(option) }
                            }
                            .id(message.id)
                        }

                        if chatViewModel.isLoading {
                            HStack {
                                ProgressView().padding()
                                Spacer()
                            }
                        }
                    }
                    .padding(DesignSystem.spacing4)
                }
                .onChange(of: chatViewModel.messages.count) { _, _ in
                        if let last = chatViewModel.messages.last {
                            withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                        }
                }
                    .onChange(of: chatViewModel.isLoading) { _, loading in
                        if loading, let last = chatViewModel.messages.last {
                            withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                        }
                    }
            }

            // Input area
            ChatInputView(viewModel: chatViewModel)
                .padding(DesignSystem.spacing4)
                .background(DesignSystem.card)
                .border(width: 1, edges: [.top], color: DesignSystem.border)

            // Footer actions
            if chatViewModel.generatedTripPlan != nil || chatViewModel.messages.last?.meta?.ui == "final" {
                HStack(spacing: DesignSystem.spacing3) {
                    Button {
                        chatViewModel.showItineraryPreview = true
                        if chatViewModel.generatedTripPlan == nil && !chatViewModel.isLoading {
                            Task { await chatViewModel.generateItineraryFromAnswers() }
                        }
                    } label: {
                        Text("View Offered Trip")
                            .frame(maxWidth: .infinity)
                            .frame(height: DesignSystem.buttonHeightTouch)
                            .background(DesignSystem.card)
                            .foregroundColor(DesignSystem.foreground)
                            .cornerRadius(DesignSystem.radiusMedium)
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignSystem.radiusMedium)
                                    .stroke(DesignSystem.border, lineWidth: 1)
                            )
                    }
                }
                .padding(DesignSystem.spacing4)
            }
        }
        .navigationTitle("Plan Trip")
        .navigationBarTitleDisplayMode(.large)
        .task {
            // Runs once per view instance; start conversation automatically
            if chatViewModel.messages.isEmpty && !chatViewModel.isLoading {
                await chatViewModel.startConversation()
            }
        }
        .sheet(isPresented: $chatViewModel.showItineraryPreview) {
            if let tripPlan = chatViewModel.generatedTripPlan {
                ItineraryPreviewView(tripPlan: tripPlan)
            } else if chatViewModel.isLoading {
                VStack(spacing: DesignSystem.spacing4) {
                    ProgressView()
                        .scaleEffect(1.1)
                    Text("Generating your itinerary…")
                        .font(.system(size: DesignSystem.FontSize.base.value))
                        .foregroundColor(DesignSystem.mutedForeground)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(DesignSystem.background)
            } else if let last = chatViewModel.messages.last {
                OfferedTripView(summary: last.content, viewModel: chatViewModel)
            } else {
                VStack { Text("No offered trip available") }
            }
        }
        .alert(chatViewModel.saveStatusMessage ?? "", isPresented: $chatViewModel.showSaveAlert) {
            Button("OK", role: .cancel) { }
        }
    }
}
