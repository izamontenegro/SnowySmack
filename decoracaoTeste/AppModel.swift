//
//  AppModel.swift
//  decoracaoTeste
//
//  Created by Izadora de Oliveira Albuquerque Montenegro on 07/11/24.
//

import SwiftUI

/// Maintains app-wide state
@MainActor
@Observable
class AppModel {
    let immersiveSpaceID = "ImmersiveSpace"
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    var immersiveSpaceState = ImmersiveSpaceState.closed
}
