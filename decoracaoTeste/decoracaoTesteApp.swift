//
//  decoracaoTesteApp.swift
//  decoracaoTeste
//
//  Created by Izadora de Oliveira Albuquerque Montenegro on 07/11/24.
//

import SwiftUI

@main
struct decoracaoTesteApp: App {

    @State private var appModel = AppModel()
    @State private var score: Int = 0
    
    var body: some Scene {
//        ImmersiveSpace {
//            ContentView()
//        }
//        .immersionStyle(selection: .constant(.mixed), in: .mixed)
        
        WindowGroup {
            if appModel.immersiveSpaceState == .closed {
                           ContentView()
                               .environment(appModel)
                       }
        }
        .windowStyle(.volumetric)
        
        WindowGroup(id: "teste") {
            Text("\(score)")
        }
        .defaultWindowPlacement { content, context in
            if let lastWindow = context.windows.last {
                return WindowPlacement(.above(lastWindow))
            }
            return WindowPlacement(.none)
        }

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView(score: $score)
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
