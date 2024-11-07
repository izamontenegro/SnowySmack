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

    var body: some Scene {
        ImmersiveSpace {
            ContentView()
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
        
//        WindowGroup {
//            ContentView()
//                .environment(appModel)
//        }
//        .windowStyle(.volumetric)
//
//        ImmersiveSpace(id: appModel.immersiveSpaceID) {
//            ImmersiveView()
//                .environment(appModel)
//                .onAppear {
//                    appModel.immersiveSpaceState = .open
//                }
//                .onDisappear {
//                    appModel.immersiveSpaceState = .closed
//                }
//        }
//        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
