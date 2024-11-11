import RealityKit
import Foundation

public struct pontuarComponent: Component, Codable {
    var count: Int = 0 {
        didSet {
            NotificationCenter.default.post(name: .updateCountNotification, object: count)
        }
    }
    
    public init() {}
}


public extension Notification.Name {
    static let updateCountNotification = Notification.Name("updateCountNotification")
}
