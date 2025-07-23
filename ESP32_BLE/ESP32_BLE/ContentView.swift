//
//  ContentView.swift
//  ESP32_BLE
//
//  Created by Yusuke Mizuno on 2025/07/21.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var ble = BLEManager()

    var body: some View {
        VStack(spacing: 30) {
            Text(ble.isConnected ? "接続中" : "接続待ち...")
                .font(.title)
            
            Button("LED ON") {
                ble.send("1")
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            

            Button("LED OFF") {
                ble.send("0")
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)

        }
        .padding()
    }
}
