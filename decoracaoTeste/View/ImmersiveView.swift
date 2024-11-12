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
    @State private var randomNumber: Int = Int.random(in: 1...9)
    @State private var timerStarted = false
    @State private var startTime: Date?
    @State private var lastNumber: Int = Int.random(in: 1...9)
    
    @State private var enviromentLoader = EnvironmentLoader()

    var body: some View {
        ZStack {
            RealityView { content in
                do {
                    let scene = try await enviromentLoader.getScene()
                    content.add(scene)
                    
                    // Inicia a animação para o pinguim ao carregar o número aleatório
                    playPenguinAnimation(in: scene)
                } catch {
                    print("Erro ao carregar a cena: \(error)")
                }
            }
            .gesture(
                TapGesture()
                    .targetedToAnyEntity()
                    .onEnded { value in
                        handlePenguinTap(entity: value.entity)
                    }
            )
            
            Text("\(randomNumber)")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(10)
        }
        .onAppear {
            startRandomNumberTimer()
        }
    }
    
    private func startRandomNumberTimer() {
        guard !timerStarted else { return }
        timerStarted = true
        startTime = Date()
        
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
            randomNumber = Int.random(in: 1...6)
            if randomNumber == lastNumber {
                randomNumber += randomNumber == 6 ? -1 : 1
            }
            lastNumber = randomNumber
            
            Task {
                do {
                    let scene = try await enviromentLoader.getScene()
                    await playPenguinAnimation(in: scene)
                } catch {
                    print("Erro ao carregar a cena para animação: \(error)")
                }
            }
            
            if let startTime = startTime, Date().timeIntervalSince(startTime) >= 200 {
                timer.invalidate()
                timerStarted = false
            }
        }
    }
    
    private func playPenguinAnimation(in scene: Entity) {
        for child in scene.children {
            guard child.name.hasPrefix("pinguim_") else { continue }
            
            if let numberString = child.name.split(separator: "_").last,
               let pinguimNumber = Int(numberString),
               pinguimNumber == randomNumber {
                
                if let animation = child.availableAnimations.last {
                    let upView = AnimationView(
                        source: animation.definition,
                        name: "up",
                        bindTarget: nil,
                        blendLayer: 0,
                        repeatMode: .autoReverse,
                        fillMode: [],
                        trimStart: 0.0,
                        trimEnd: 2.0,
                        trimDuration: 1.0,
                        offset: 0,
                        delay: 0,
                        speed: 1.0)
                    
                    up = try? AnimationResource.generate(with: upView)
                    
                    let downView = AnimationView(
                        source: animation.definition,
                        name: "down",
                        bindTarget: nil,
                        blendLayer: 0,
                        repeatMode: .autoReverse,
                        fillMode: [],
                        trimStart: 2.0,
                        trimEnd: 4.0,
                        trimDuration: 0.5,
                        offset: 0,
                        delay: 0,
                        speed: 2.0)
                    
                    down = try? AnimationResource.generate(with: downView)
                    
                    let resource = try! AudioFileResource.load(named: "bell.m4a", configuration: .init(shouldLoop: false))
                    audioLibraryComponent.resources["Punch"] = resource
                    child.components.set(audioLibraryComponent)
                    
                    let punch = PlayAudioAction(audioResourceName: "Punch", useControlledPlayback: false)
                    let snapAudioAnimation = try! AnimationResource
                        .makeActionAnimation(for: punch, delay: 1.0)
                    
                    let alignAnimationGroupResource = try! AnimationResource.group(with: /*[up!, down!]*/ [up!]
                        )
                    
                    child.playAnimation(alignAnimationGroupResource)
                } else {
                    print("Erro ao carregar a entidade ou animação")
                }
            }
        }
    }

    private func handlePenguinTap(entity: Entity?) {
        print("TAP no pinguim!")
        guard let entity = entity else { return }
        
//        entity.stopAllAnimations()
        
        if let numberString = entity.name.split(separator: "_").last,
           let tappedPenguinNumber = Int(numberString),
           tappedPenguinNumber == randomNumber ||  tappedPenguinNumber == lastNumber  {
            print("Entrou no if")
            
            if let downAnimation = down {
                entity.playAnimation(downAnimation)
                print("Animação de descida reproduzida para o pinguim \(tappedPenguinNumber)")
            } else {
                print("Não tem o down!")
            }
        } else {
            print("Não entrei no if")
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
