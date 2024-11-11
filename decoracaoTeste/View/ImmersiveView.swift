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
    @Environment(AppModel.self) var appModel
    @State private var up: AnimationResource?
    @State private var down: AnimationResource?
    @State private var audioLibraryComponent = AudioLibraryComponent()
    
    var body: some View {
        RealityView { content in
            // Carregar a entidade USDZ com animação
            if let scene = try? await Entity(named: "Decora", in: realityKitContentBundle) {
                
                content.add(scene)

                
                for child in scene.children {
                    guard child.name == "pinguim" else { continue }
                    
                    if let animation = child.availableAnimations.last {
                        // Criar a animação de subida (0.0 a 2.0)
                        let upView = AnimationView(
                            source: animation.definition,
                            name: "up",
                            bindTarget: nil,
                            blendLayer: 0,
                            repeatMode: .autoReverse,
                            fillMode: [],
                            trimStart: 0.0,
                            trimEnd: 2.0,
                            trimDuration: 2.0,
                            offset: 0,
                            delay: 0,
                            speed: 2.0)
                        
                        up = try? AnimationResource.generate(with: upView)
                        
                        // Criar a animação de descida (2.0 a 4.0)
                        let downView = AnimationView(
                            source: animation.definition,
                            name: "down",
                            bindTarget: nil,
                            blendLayer: 0,
                            repeatMode: .autoReverse,
                            fillMode: [],
                            trimStart: 2.0,
                            trimEnd: 4.0,
                            trimDuration: 2.0,
                            offset: 0,
                            delay: 0,
                            speed: 5.0)
                        
                        down = try? AnimationResource.generate(with: downView)
                        
                        let resource = try! AudioFileResource.load(named: "bell.m4a", configuration: .init(shouldLoop: false))

                        audioLibraryComponent.resources["Punch"] = resource
                        
                        child.components.set(audioLibraryComponent)
                        // Tocar a animação com o áudio
                        
                        let punch = PlayAudioAction(audioResourceName: "Punch",
                                                              useControlledPlayback: false)
                        
                        let snapAudioAnimation = try! AnimationResource
                            .makeActionAnimation(for: punch,
                                                 delay: 0.0)
                        
                        let alignAnimationGroupResource
                        = try! AnimationResource.group(with: [down!,snapAudioAnimation])
                        
                        child.playAnimation(alignAnimationGroupResource)

                    } else {
                        print("Erro ao carregar a entidade ou animação")
                    }
                    
                }
            }
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
