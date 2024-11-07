//
//  ImmersiveView.swift
//  decoracaoTeste
//
//  Created by Izadora de Oliveira Albuquerque Montenegro on 07/11/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {

    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let immersiveContentEntity = try? await Entity(named: "Decora", in: realityKitContentBundle) {
                content.add(immersiveContentEntity)

                // Put skybox here.  See example in World project available at
                // https://developer.apple.com/
            }
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
