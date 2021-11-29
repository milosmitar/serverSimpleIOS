//
//  ServerConnection.swift
//  NetworkServer
//
//  Created by vesko on 22.11.21..
//
import Foundation
import Network
import SwiftUI

protocol ReceiveDelegate{
    func onReceive(data: Data)
}
class DataMessage : ObservableObject{
    @Published var message: Data?

}


@available(macOS 10.14, *)
class ServerConnection{
    @ObservedObject var dataMessage = DataMessage()
    var transferDataDelegate: TransferData?
    //The TCP maximum package size is 64K 65536
    let MTU = 251993
//    let MTU = 100000000

    private static var nextID: Int = 0
    let  connection: NWConnection
    let id: Int

    init(nwConnection: NWConnection, transferData: TransferData) {
        connection = nwConnection
        id = ServerConnection.nextID
        ServerConnection.nextID += 1
        self.transferDataDelegate = transferData
  
    }

    var didStopCallback: ((Error?) -> Void)? = nil

    func start() {
        print("connection \(id) will start")
        connection.stateUpdateHandler = self.stateDidChange(to:)
        setupReceive()
        connection.start(queue: .main)
    }

    private func stateDidChange(to state: NWConnection.State) {
        switch state {
        case .waiting(let error):
            connectionDidFail(error: error)
        case .ready:
            print("connection \(id) ready")
        case .failed(let error):
            connectionDidFail(error: error)
        default:
            break
        }
    }

    private func setupReceive() {
        connection.receive(minimumIncompleteLength: 1, maximumLength: MTU) { (data, _, isComplete, error) in
            if let data = data, !data.isEmpty {
//                let message = String(data: data, encoding: .utf8)
//                self.dataMessage.message = data
                self.transferDataDelegate?.onMessageReceive(data: data)
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "passData"),
//                                                object: nil, userInfo: ["info": data])
//                self.send(data: data)
            }
            if isComplete {
                self.connectionDidEnd()
            } else if let error = error {
                self.connectionDidFail(error: error)
            } else {
                self.setupReceive()
            }
        }
    }

//     @objc func passMessageNotification(_ notification: Notification){
//         print(notification)
//     }

    func send(data: Data) {
        self.connection.send(content: data, completion: .contentProcessed( { error in
            if let error = error {
                self.connectionDidFail(error: error)
                return
            }
            print("connection \(self.id) did send, data: \(data as NSData)")
        }))
    }

    func stop() {
        print("connection \(id) will stop")
    }



    private func connectionDidFail(error: Error) {
        print("connection \(id) did fail, error: \(error)")
        stop(error: error)
    }

    private func connectionDidEnd() {
        print("connection \(id) did end")
        stop(error: nil)
    }

    private func stop(error: Error?) {
        connection.stateUpdateHandler = nil
        connection.cancel()
        if let didStopCallback = didStopCallback {
            self.didStopCallback = nil
            didStopCallback(error)
        }
    }
}
