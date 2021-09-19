//
//  ConnectionMonitor.swift
//  SurfTask
//
//  Created by Артём Калинин on 15.09.2021.
//

import Foundation
import Network

final class ConnectionMonitor {
    static let shared = ConnectionMonitor()

    private let queue = DispatchQueue.global()
    private let monitor: NWPathMonitor

    private(set) var isConnected: Bool = true

    private(set) var connectionType: ConnectionType = .unknown

    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }

    private init() {
        monitor = NWPathMonitor()
    }

    public func startMonitoring() {
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }

            if path.status == .satisfied && self.isConnected == false {
                let connectedNotification = Notification.Name("connected")

                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: connectedNotification,
                                                    object: nil)
                }
                self.isConnected = true
            }

            if path.status != .unsatisfied && self.isConnected == true {
                let inNetworkNotification = Notification.Name("inNetwork")

                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: inNetworkNotification,
                                                object: nil)
                }
            }

            if path.status == .unsatisfied {
                let disconnectedNotification = Notification.Name("disconnected")

                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: disconnectedNotification,
                                                object: nil)
                }
                self.isConnected = false
            }

            self.getConnectionType(path)
        }
    }

    public func stopMonitoring() {
        monitor.cancel()
    }

    private func getConnectionType(_ path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
        } else {
            connectionType = .unknown
        }
    }
}
