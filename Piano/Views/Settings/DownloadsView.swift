//
//  DownloadsView.swift
//  Chord Studio
//
//  Created by Jin Zhang on 2026/6/24.
//

import SwiftUI
import BackgroundAssets

struct DownloadsView: View {
    @State var text: String = ""
    
    var body: some View {
        List {
            Text(text)
            HStack {
                Text("Marimba")
                Spacer()
                Button("Download") {
                    Task {
                        do {
                            let assetPack = try await AssetPackManager.shared.assetPack(withID: "marimba-sf2")
                            try await AssetPackManager.shared.ensureLocalAvailability(of: assetPack)

                            text = "Download complete"
                        } catch {
                            text = "Failed: \(error)"
                        }
                    }
                }
            }
        }
        .navigationTitle("Downloads")
        
    }
}

#Preview {
    DownloadsView()
}
