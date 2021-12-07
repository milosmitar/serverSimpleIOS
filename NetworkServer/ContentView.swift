//
//  ContentView.swift
//  NetworkServer
//
//  Created by vesko on 22.11.21..
//

import SwiftUI

protocol TransferData{
    func onMessageReceive(data: Data)
    func onServerConnected(message: String)
    func onCreateConnectionId(connectionId: Int)
}

struct ContentView: View, TransferData {
    func onCreateConnectionId(connectionId: Int) {
        self.connectionId = connectionId
    }
    
    @State private var text = Text("Hello world")
    @State var placeholder : String = " napisi text"
    @State private var passData = false
    @State private var image = Image(systemName: "photo")
    @State private var showImagePicker = false
    @State var write = ""
    @State var connectionStatus = Text("status")
    @State private var inputImage: UIImage?
    @State var messages : [Message] = []
    @State var server: Server?
    @State var connectionId : Int?
    
    
    let pub = NotificationCenter.default
        .publisher(for: NSNotification.Name("passData"))
    var body: some View {
        NavigationView{
            VStack{
                ScrollView(.vertical, showsIndicators: false){
                    VStack(alignment: .center){
                        ForEach(messages, id: \.self){ message in
                            ChatRow(message: message)
                        }
                    }
                }
                HStack{
                    cameraButton
                    TextField("message...", text: $write)
                        .padding(10)
                        .background(Color(red: 233.0/255, green: 234.0/255, blue: 243.0/255))
                        .cornerRadius(25)
                    Image(systemName: "paperplane.fill").font(.system(size: 20))
                        .foregroundColor((self.write.count > 0) ? Color.blue : Color.gray).rotationEffect(.degrees(45)).onTapGesture {
                            sendMessage(data: self.write.data(using: .ascii) ?? Data())
                        }
                }.padding()
                
            }
            .sheet(isPresented: $showImagePicker, onDismiss: loadImage){
                ImagePicker(image: self.$inputImage)
            }
            .navigationBarItems(leading: titleBar,trailing: connectionStatus)
            
        }
    }
    func loadImage(){
//        self.image.
//        sendMessage(data: )
        guard let inputImage = inputImage else {
            return
        }
        guard let data = inputImage.jpegData(compressionQuality: 1.0) else{
            return
        }
       sendMessage(data: data)
    }
    private func sendMessage(data: Data){
        
        if server != nil && connectionId != nil{
            server?.connectionSendData(data: data, connectionId: connectionId ?? 0)
        }
        
    }
    private var titleBar: some View{
        HStack{
            Button( "start server ".appending(InternetHelper.getIpAddress() ?? "unknown ip adress") ) {
                serverStart()
            }
            //            Text(self.connectionStatus).foregroundColor((self.connectionStatus.elementsEqual("connect")) ? Color.green : Color.red)
        }
    }
    private var cameraButton: Button<Image>{
        return Button(action:{
            self.showImagePicker = true
            
        }){
            Image(systemName: "camera")
        }
    }
    
    func showSpinningWheel(_ notification: NSNotification) {
        print(notification.userInfo ?? "")
        if let dict = notification.userInfo as NSDictionary? {
            if let message = dict["message"] as? String{
                print(message)
                // do something with your image
            }
        }
    }
    
    private func serverStart(){
        if #available(macOS 10.14, *) {
            
            server = Server(port: 9999, transferData: self)
            try! server!.start()
            
//            RunLoop.current.run()
            
        } else {
            let stderr = FileHandle.standardError
            let message = "Requires macOS 10.14 or newer"
            stderr.write(message.data(using: .utf8)!)
            exit(EXIT_FAILURE)
        }
        
    }
    func onServerConnected(message: String) {
        self.connectionStatus = Text(message)
        
    }
    func onMessageReceive(data: Data) {
        let message = Message(data: data)
        self.messages.append(message)
//        let uiimate = UIImage(data: data)
//        if(uiimate != nil){
//            self.image = Image(uiImage: uiimate!)
//        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    let parent: ImagePicker
    
    init(_ parent: ImagePicker) {
        self.parent = parent
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let uiImage = info[.originalImage] as? UIImage {
            parent.image = uiImage
            guard let data = uiImage.jpegData(compressionQuality:1.0)
                    
            else {
                return
            }
            sendImage(dataImage: data)
            //            initClient(server: "192.168.0.27", port: 9999)
        }
        parent.presentationMode.wrappedValue.dismiss()
    }
    func sendImage(dataImage: Data){
        
        
    }
    
    //    func initClient(server: String, port: UInt16) {
    //        let client = Client(host: server, port: port)
    //        client.start()
    ////        let uiimage = parent.image!.asUIImage()
    ////        let cgImage:CGImage = context.createCGImage(parent.image!, from:
    ////        cameraImage.extent)!     //cameraImage is grabbed from video frame
    ////        image = UIImage.init(cgImage: cgImage)
    ////        let data = UIImageJPEGRepresentation(image, 1.0)
    //
    //        client.connection.send(data: parent.image!.jpegData(compressionQuality: 0.000005)!)
    //        }
    
    
}
