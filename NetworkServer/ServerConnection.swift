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

@available(macOS 10.14, *)
class ServerConnection{
    var transferDataDelegate: TransferData?
    //The TCP maximum package size is 64K 65536
    let MTU = 251993
    //    let MTU = 100000000
    
    private static var nextID: Int = 0
    let  connection: NWConnection
    let id: Int
    var receivedDataCount: UInt32? = nil
    var displayData = Data()
    //    var inputStream: InputStream
    
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
            //            var inputStream: InputStream
            if let data = data, !data.isEmpty {
                if self.receivedDataCount == nil {
                    
                    let count = data.withUnsafeBytes{
                        [UInt8](UnsafeBufferPointer(start: $0, count: 4))
                    }
                    let cutingData = data
                    let rawData = cutingData.dropFirst(4)

                    let countData = Data(bytes: count)
                    self.receivedDataCount = UInt32(bigEndian: countData.withUnsafeBytes { $0.pointee })

                    self.displayData.append(rawData)

                    if(self.receivedDataCount! > UInt32(data.count)){
                    self.receivedDataCount = self.receivedDataCount! - UInt32(cutingData.count)
                    }else{
                        self.transferDataDelegate?.onMessageReceive(data: self.displayData)
                        self.displayData = Data()
                        self.receivedDataCount = nil
                    }
                    print(rawData)

                }else if(self.receivedDataCount! > 0 && self.receivedDataCount! > UInt32(data.count)){

                    self.displayData.append(data)
                    self.receivedDataCount = self.receivedDataCount! - UInt32(data.count)
                }else{
                    self.displayData.append(data)
                    self.transferDataDelegate?.onMessageReceive(data: self.displayData)
                    self.displayData = Data()
                    self.receivedDataCount = nil
                }
                
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
    
    func send(data: Data) {
        let dataLength = data.count
        
        let value: UInt32 = UInt32(dataLength)
        var finalData = withUnsafeBytes(of: value.bigEndian, Array.init)
        finalData.append(contentsOf: data)
        
        self.connection.send(content: finalData, completion: .contentProcessed( { error in
            if let error = error {
                self.connectionDidFail(error: error)
                return
            }
                print("connection did send, data: \(data as NSData)")
        }))
//        self.connection.send(content: data, completion: .contentProcessed( { error in
//            if let error = error {
//                self.connectionDidFail(error: error)
//                return
//            }
//            print("connection \(self.id) did send, data: \(data as NSData)")
//        }))
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
