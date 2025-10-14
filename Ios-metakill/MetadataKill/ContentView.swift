// Placeholder ContentView
// The actual ContentView implementation is in Sources/App/Views/ContentView.swift
// This file can be deleted once the App module exports are properly configured

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "shield.lefthalf.filled")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("MetadataKill")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Privacy-focused metadata removal")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("🎉 Build Successful!")
                .font(.headline)
                .foregroundColor(.green)
                .padding(.top, 20)
            
            Text("The app will use the full UI from the App module once dependencies are resolved.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
