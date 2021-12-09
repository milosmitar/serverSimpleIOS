//
//  Message.swift
//  NetworkServer
//
//  Created by vesko on 30.11.21..
//

import Foundation

struct Message: Hashable{
    var id = UUID()
    var data : Data
    var recived: Bool
}
