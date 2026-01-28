import SwiftUI

struct PlanHomeView: View {
    @Environment(\.openURL) private var openURL

    private let destinations = SampleDestinations.destinations
    private let exploreTitle = ""

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: DesignSystem.spacing6) {
                header

                sectionTitle("YOUR TRIP")
                yourTripCard

                sectionTitle("MUST SEE")
                mustSeeRow

                sectionTitle("PRE-MADE PLANS")
                preMadePlans
            }
            .padding(.horizontal, DesignSystem.spacing4)
            .padding(.top, DesignSystem.spacing3)
            .padding(.bottom, DesignSystem.spacing6)
        }
        .background(DesignSystem.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }

    private var header: some View {
        HStack(alignment: .center, spacing: DesignSystem.spacing3) {
            HStack(spacing: 6) {
                Text("Explore")
                    .font(.system(size: DesignSystem.FontSize.xl2.value, weight: .bold))
                    .foregroundColor(DesignSystem.foreground)

                HStack(spacing: 4) {
                    Text(exploreTitle)
                        .font(.system(size: DesignSystem.FontSize.xl2.value, weight: .bold))
                        .foregroundColor(DesignSystem.primaryColor)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(DesignSystem.primaryColor)
                        .offset(y: 1)
                }
            }

            Spacer()

            Circle()
                .fill(DesignSystem.muted)
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(DesignSystem.mutedForeground)
                )
        }
        .padding(.top, DesignSystem.spacing2)
    }

    private var yourTripCard: some View {
        ZStack(alignment: .bottomTrailing) {

            // Background
            RoundedRectangle(cornerRadius: DesignSystem.radiusXLarge, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            DesignSystem.primaryColor.opacity(0.95),
                            DesignSystem.primaryColor.opacity(0.55),
                            DesignSystem.card.opacity(0.10)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    // Dark scrim for text contrast
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.28),
                            Color.black.opacity(0.08),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.radiusXLarge, style: .continuous))
                )
                .overlay(
                    // Soft highlight border
                    RoundedRectangle(cornerRadius: DesignSystem.radiusXLarge, style: .continuous)
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                )
                .overlay(
                    // Existing border to match your system
                    RoundedRectangle(cornerRadius: DesignSystem.radiusXLarge, style: .continuous)
                        .stroke(DesignSystem.border, lineWidth: 1)
                        .opacity(0.35)
                )
                .frame(height: 132)
                .shadow(radius: 14, y: 8)

            // Content
            HStack(alignment: .center, spacing: DesignSystem.spacing4) {

                VStack(alignment: .leading, spacing: 10) {

                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.95))

                        Text("Plan with AI")
                            .font(.system(size: DesignSystem.FontSize.lg.value, weight: .bold))
                            .foregroundColor(.white)

                        // Little chip for hierarchy (optional)
                        Text("NEW")
                            .font(.system(size: 11, weight: .bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.16))
                            .foregroundColor(.white.opacity(0.95))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule().stroke(Color.white.opacity(0.18), lineWidth: 1)
                            )
                    }
                    .shadow(color: Color.black.opacity(0.25), radius: 10, y: 4)

                    Text("Personalized itinerary in minutes")
                        .font(.system(size: DesignSystem.FontSize.sm.value, weight: .semibold))
                        .foregroundColor(.white.opacity(0.92))
                        .shadow(color: Color.black.opacity(0.22), radius: 10, y: 4)

                    // A small supporting line to improve readability & value prop
                    Text("Tell us your dates, budget, and vibe — we’ll handle the rest.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.82))
                        .lineLimit(2)
                        .shadow(color: Color.black.opacity(0.18), radius: 10, y: 4)
                }
                .padding(.leading, DesignSystem.spacing4)

                Spacer()

                NavigationLink {
                    PlanView()
                } label: {
                    HStack(spacing: 8) {
                        Text("Start")
                            .font(.system(size: DesignSystem.FontSize.base.value, weight: .bold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                            .offset(y: 0.5)
                    }
                    .padding(.horizontal, 18)
                    .frame(height: 46)
                    .foregroundColor(.white)
                    .background(
                        // Premium glass button
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.white.opacity(0.18))
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color.black.opacity(0.12))
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.white.opacity(0.22), lineWidth: 1)
                    )
                    .shadow(radius: 10, y: 6)
                }
                .padding(.trailing, DesignSystem.spacing4)
            }
            .padding(.vertical, 18)
        }
    }


    private var mustSeeRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.spacing4) {
                ForEach(destinations.prefix(8)) { destination in
                    MustSeeCard(destination: destination) {
                        openURL(destination.link)
                    }
                }
            }
            .padding(.vertical, 2)
        }
    }

    private var preMadePlans: some View {
        let lastThree = Array(destinations.suffix(3))

        return VStack(spacing: DesignSystem.spacing4) {
            ForEach(Array(lastThree.enumerated()), id: \.offset) { index, destination in
                PreMadePlanRow(
                    destination: destination,
                    priceText: index == 0 ? "$499" : (index == 1 ? "$699" : "$899")
                ) {
                    openURL(destination.link)
                }
            }
        }
    }


    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: DesignSystem.FontSize.sm.value, weight: .bold))
            .foregroundColor(DesignSystem.mutedForeground)
            .tracking(1.2)
            .padding(.top, DesignSystem.spacing2)
    }
}

private struct MustSeeCard: View {
    let destination: Destination
    let onAdd: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                DestinationImage(assetName: destination.src)
                    .frame(width: 230, height: 130)
                    .clipped()

                LinearGradient(
                    colors: [Color.black.opacity(0.35), Color.clear],
                    startPoint: .topLeading,
                    endPoint: .center
                )
                .frame(width: 230, height: 130)
            }

            HStack(alignment: .center, spacing: DesignSystem.spacing3) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(shortTitle(destination.title))
                        .font(.system(size: DesignSystem.FontSize.base.value, weight: .semibold))
                        .foregroundColor(DesignSystem.foreground)
                        .lineLimit(1)
                    Text(destination.category)
                        .font(.system(size: DesignSystem.FontSize.xs.value, weight: .medium))
                        .foregroundColor(DesignSystem.mutedForeground)
                        .lineLimit(1)
                }

                Spacer()

                Button(action: onAdd) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .bold))
                        .frame(width: 36, height: 36)
                        .background(DesignSystem.primaryColor)
                        .foregroundColor(DesignSystem.primaryForeground)
                        .cornerRadius(10)
                }
            }
            .padding(DesignSystem.spacing3)
        }
        .background(DesignSystem.card)
        .cornerRadius(DesignSystem.radiusXLarge)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.radiusXLarge)
                .stroke(DesignSystem.border, lineWidth: 1)
        )
        .frame(width: 230)
    }

    private func shortTitle(_ text: String) -> String {
        // Keeps the UI closer to the screenshot card style.
        if text.count <= 26 { return text }
        return String(text.prefix(26)) + "…"
    }
}

private struct PreMadePlanRow: View {
    let destination: Destination
    let priceText: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: DesignSystem.spacing4) {
                DestinationImage(assetName: destination.src)
                    .frame(width: 84, height: 84)
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.radiusLarge))

                VStack(alignment: .leading, spacing: 6) {
                    Text(titleFrom(destination.title))
                        .font(.system(size: DesignSystem.FontSize.base.value, weight: .semibold))
                        .foregroundColor(DesignSystem.foreground)
                        .lineLimit(1)

                    Text("Check out this beautiful spot at its best!")
                        .font(.system(size: DesignSystem.FontSize.sm.value))
                        .foregroundColor(DesignSystem.mutedForeground)
                        .lineLimit(2)

                    Text(priceText)
                        .font(.system(size: DesignSystem.FontSize.base.value, weight: .bold))
                        .foregroundColor(DesignSystem.primaryColor)
                }

                Spacer(minLength: 0)
            }
            .padding(DesignSystem.spacing4)
            .background(DesignSystem.card)
            .cornerRadius(DesignSystem.radiusXLarge)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.radiusXLarge)
                    .stroke(DesignSystem.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func titleFrom(_ s: String) -> String {
        // "Discover X" -> "X", etc.
        let prefixes = ["Discover ", "Marvel at ", "Step inside the ", "Uncover the ", "Explore ", "Admire the ", "Visit the ", "Walk the ", "See the ", "Experience the ", "Admire the ", "Conquer ", "Unlock the mystery of "]
        for p in prefixes {
            if s.hasPrefix(p) { return String(s.dropFirst(p.count)) }
        }
        return s
    }
}

private struct DestinationImage: View {
    let assetName: String

    var body: some View {
        if let uiImage = loadAssetImage(named: assetName) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else if let url = URL(string: assetName), ["http", "https"].contains(url.scheme?.lowercased() ?? "") {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        LinearGradient(
                            colors: [DesignSystem.primaryColor.opacity(0.25), DesignSystem.muted],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        ProgressView()
                    }
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    missingAssetPlaceholder
                @unknown default:
                    missingAssetPlaceholder
                }
            }
        } else {
            missingAssetPlaceholder
        }
    }

    private func loadAssetImage(named raw: String) -> UIImage? {
        for candidate in assetCandidates(from: raw) {
            if let img = UIImage(named: candidate) {
                return img
            }
        }
        return nil
    }

    /// Supports:
    /// - "chichen"
    /// - "hero/chichen"
    /// - "/hero/chichen.webp"
    private func assetCandidates(from raw: String) -> [String] {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return [] }

        // If it's an URL, don't treat as asset
        if let url = URL(string: trimmed), url.scheme != nil { return [] }

        var candidates: [String] = []
        candidates.append(trimmed)

        // Normalize "/hero/chichen.webp" -> "hero/chichen"
        var normalized = trimmed
        if normalized.hasPrefix("/") { normalized.removeFirst() }

        if let dot = normalized.lastIndex(of: ".") {
            normalized = String(normalized[..<dot])
        }
        candidates.append(normalized)

        // Also try just the basename: "hero/chichen" -> "chichen"
        if let last = normalized.split(separator: "/").last {
            candidates.append(String(last))
        }

        // Also try namespaced hero path if user created "hero/" folder namespace
        if !normalized.contains("/") {
            candidates.append("hero/\(normalized)")
        }

        // Unique + stable order
        var seen = Set<String>()
        return candidates.filter { seen.insert($0).inserted }
    }

    private var missingAssetPlaceholder: some View {
        ZStack {
            LinearGradient(
                colors: [
                    DesignSystem.primaryColor.opacity(0.35),
                    DesignSystem.muted
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 8) {
                Image(systemName: "photo")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundColor(DesignSystem.mutedForeground.opacity(0.7))

                Text(assetName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(DesignSystem.mutedForeground.opacity(0.85))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.black.opacity(0.12))
                    .clipShape(Capsule())
            }
        }
    }
}

#Preview {
    NavigationStack {
        PlanHomeView()
    }
}


