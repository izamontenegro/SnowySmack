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
    @Environment(\.openWindow) private var openWindow
    
    @State private var up: AnimationResource?
    @State private var down: AnimationResource?
    @State private var audioLibraryComponent = AudioLibraryComponent()
    @State private var randomNumber: Int = Int.random(in: 1...9)
    @State private var timerStarted = false
    @State private var startTime: Date?
    @State private var lastNumber: Int = Int.random(in: 1...9)
    @Binding var score: Int
    @State private var buracosAtivos: [Bool] = Array(repeating: false, count: 6)
    @State private var enviromentLoader = EnvironmentLoader()

    var body: some View {
        ZStack {
            RealityView { content in
                do {
                    let scene = try await enviromentLoader.getScene()
                    content.add(scene)
                    
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
            
            Text("\(score)")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(10)
//                .frame(depth: 1, alignment: .back)
//                .padding3D(.back, -1000)
//                .frame(depth: 10)
            
        }
        .onAppear {
            startRandomNumberTimer()
            openWindow(id: "teste")
        }
    }
    
    private func startRandomNumberTimer() {
        guard !timerStarted else { return }
        timerStarted = true
        startTime = Date()
        var intervalo = 2.0
        
        Timer.scheduledTimer(withTimeInterval: TimeInterval(intervalo), repeats: true) { timer in
            randomNumber = Int.random(in: 1...6)
            if randomNumber == lastNumber {
                randomNumber = (randomNumber == 6) ? randomNumber - 1 : randomNumber + 1
            }
            lastNumber = randomNumber
            
            // Mantém o buraco sorteado ativo, sem resetar outros
            buracosAtivos[randomNumber - 1] = true
            if let startTime = startTime, Date().timeIntervalSince(startTime) >= 10 {
                intervalo += 0.5
            } else if let startTime = startTime, Date().timeIntervalSince(startTime) >= 20{
                intervalo += 0.5
            }
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
               buracosAtivos[pinguimNumber - 1] {
                
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
                        trimDuration: 2.0,
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
                        trimDuration: 1.0,
                        offset: 0,
                        delay: 0,
                        speed: 3.0)
                    
                    down = try? AnimationResource.generate(with: downView)
                    
                    let resource = try! AudioFileResource.load(named: "bell.m4a", configuration: .init(shouldLoop: false))
                    audioLibraryComponent.resources["Punch"] = resource
                    child.components.set(audioLibraryComponent)
                    
                    let punch = PlayAudioAction(audioResourceName: "Punch", useControlledPlayback: false)
                    let snapAudioAnimation = try! AnimationResource
                        .makeActionAnimation(for: punch, delay: 1.0)
                    
                    let alignAnimationGroupResource = try! AnimationResource.group(with: [up!])
                    
                    child.playAnimation(alignAnimationGroupResource)
                } else {
                    print("Erro ao carregar a entidade ou animação")
                }
            }
        }
    }

    private func handlePenguinTap(entity: Entity?) {
        print("TAP no pinguim!")
        
        let resource = try! AudioFileResource.load(named: "bell.m4a", configuration: .init(shouldLoop: false))
        
        guard let entity = entity else { return }
        
        if let numberString = entity.name.split(separator: "_").last,
           let tappedPenguinNumber = Int(numberString),
           buracosAtivos[tappedPenguinNumber - 1] {
            
            if let downAnimation = down {
                entity.playAnimation(downAnimation)
                print("Animação de descida reproduzida para o pinguim \(tappedPenguinNumber)")
                entity.playAudio(resource)
                score+=10
                buracosAtivos[tappedPenguinNumber - 1] = false
            } else {
                print("Não tem o down!")
            }
        } else {
            print("Pinguim não está ativo, ação ignorada.")
        }
    }
}


