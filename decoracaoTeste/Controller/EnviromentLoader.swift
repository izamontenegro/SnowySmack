//
//  EnviromentLoader.swift
//  decoracaoTeste
//
//  Created by honorio on 12/11/24.
//

import Foundation
import SwiftUI
import RealityKit
import RealityKitContent

actor EnvironmentLoader {
    // Weak reference to the loaded environment
    private var entity: Entity?

    // Returning the cached Entity or loading it otherwise
    func getScene() async throws -> Entity {
        // Se já temos a entidade em cache, retorna ela
        if let entity = entity { return entity }
        
        // Caso contrário, carrega a entidade
        let entity = try await Entity(named: "Decora", in: realityKitContentBundle)
        
        // Armazena a entidade carregada na propriedade fraca
        self.entity = entity
        
        return entity
    }
    
    // Função principal dentro do actor
    func getChild(named name: String) async throws -> Entity {
        // Garante que a entidade esteja carregada
        let loadedEntity = try await getScene()

        // Filtra as children com uma função auxiliar que executa no Main Actor
        return await filterChild(on: loadedEntity, named: name)!
    }

    // Função auxiliar para a filtragem das children isolada no Main Actor
    @MainActor
    private func filterChild(on entity: Entity, named name: String) -> Entity? {
        return entity.children.first { $0.name == name }
    }
}
