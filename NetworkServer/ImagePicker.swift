//
//  ImagePicker.swift
//  NetworkServer
//
//  Created by vesko on 30.11.21..
//

import Foundation
import SwiftUI
struct ImagePicker: UIViewControllerRepresentable{
    
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?
    
    func makeCoordinator() -> Coordinator{
        Coordinator(self)
    }
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
    
}
