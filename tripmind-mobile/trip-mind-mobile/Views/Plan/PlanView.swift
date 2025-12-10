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
            if chatViewModel.messages.isEmpty {
                VStack(spacing: DesignSystem.spacing6) {
                    Image(systemName: "airplane.departure")
                        .font(.system(size: 60))
                        .foregroundColor(DesignSystem.primaryColor)
                        .padding(.top, DesignSystem.spacing8)
                    
                    Text("Plan Your Trip")
                        .font(.system(size: DesignSystem.FontSize.xl2.value, weight: .bold))
                        .foregroundColor(DesignSystem.foreground)
                    
                    Text("Let's create a personalized itinerary for your next adventure")
                        .font(.system(size: DesignSystem.FontSize.base.value))
                        .foregroundColor(DesignSystem.mutedForeground)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, DesignSystem.spacing4)
                    
                    Button(action: {
                        Task {
                            await chatViewModel.startConversation()
                        }
                    }) {
                        Text("Start Planning")
                            .font(.system(size: DesignSystem.FontSize.base.value, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: DesignSystem.buttonHeightTouch)
                            .background(DesignSystem.primaryColor)
                            .foregroundColor(DesignSystem.primaryForeground)
                            .cornerRadius(DesignSystem.radiusMedium)
                    }
                    .padding(.horizontal, DesignSystem.spacing4)
                    .padding(.top, DesignSystem.spacing4)
                }
            } else {
                // Chat interface
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: DesignSystem.spacing4) {
                            ForEach(chatViewModel.messages) { message in
                                ChatBubbleView(message: message) { option in
                                    Task {
                                        await chatViewModel.selectOption(option)
                                    }
                                }
                                .id(message.id)
                            }
                            
                            if chatViewModel.isLoading {
                                HStack {
                                    ProgressView()
                                        .padding()
                                    Spacer()
                                }
                            }
                        }
                        .padding(DesignSystem.spacing4)
                    }
                    .onChange(of: chatViewModel.messages.count) { _ in
                        if let lastMessage = chatViewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                    .onChange(of: chatViewModel.isLoading) { loading in
                        if loading {
                            if let lastMessage = chatViewModel.messages.last {
                                withAnimation {
                                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                }
                
                // Input area
                ChatInputView(viewModel: chatViewModel)
                    .padding(DesignSystem.spacing4)
                    .background(DesignSystem.card)
                    .border(width: 1, edges: [.top], color: DesignSystem.border)
                // Footer actions shown when assistant reaches final step or generated trip exists
                if chatViewModel.generatedTripPlan != nil || chatViewModel.messages.last?.meta?.ui == "final" {
                    HStack(spacing: DesignSystem.spacing3) {
                        Button(action: {
                            // Show offered/generated trip preview (reuse existing sheet if available)
                            chatViewModel.showItineraryPreview = true
                        }) {
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

                        Button(action: {
                            // If we have a structured trip, save it; otherwise save fallback offered trip
                            Task {
                                if chatViewModel.generatedTripPlan != nil {
                                    await chatViewModel.saveGeneratedTrip()
                                } else if let last = chatViewModel.messages.last {
                                    await chatViewModel.saveOfferedTrip(summary: last.content)
                                }
                            }
                        }) {
                            Text("Save Trip")
                                .frame(maxWidth: .infinity)
                                .frame(height: DesignSystem.buttonHeightTouch)
                                .background(DesignSystem.primaryColor)
                                .foregroundColor(DesignSystem.primaryForeground)
                                .cornerRadius(DesignSystem.radiusMedium)
                        }

                        // Removed Done footer button; leave action moved to top toolbar
                    }
                    .padding(DesignSystem.spacing4)
                }
            }
        }
        .navigationTitle("Plan Trip")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $chatViewModel.showItineraryPreview) {
            // Prefer full TripPlan preview when available
            if let tripPlan = chatViewModel.generatedTripPlan {
                ItineraryPreviewView(tripPlan: tripPlan)
            } else if let last = chatViewModel.messages.last {
                // Fallback: show the offered summary from the assistant
                OfferedTripView(summary: last.content, viewModel: chatViewModel)
            } else {
                // Nothing to show - quick fallback placeholder
                VStack { Text("No offered trip available") }
            }
        }
        .alert(chatViewModel.saveStatusMessage ?? "", isPresented: $chatViewModel.showSaveAlert) {
            Button("OK", role: .cancel) { }
        }
        .toolbar {
            if !chatViewModel.messages.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Leave Chat") {
                        chatViewModel.leaveChat()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        PlanView()
            .environmentObject(AuthManager())
    }
}
