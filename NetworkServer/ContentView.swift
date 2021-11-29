//
//  ContentView.swift
//  NetworkServer
//
//  Created by vesko on 22.11.21..
//

import SwiftUI

protocol TransferData{
    func onMessageReceive(data: Data)
}

struct ContentView: View, TransferData {
    func onMessageReceive(data: Data) {
        let uiimate = UIImage(data: data)
        if(uiimate != nil){
        self.image = Image(uiImage: uiimate!)
        }
    }
    
    @EnvironmentObject private var message: DataMessage
    @State private var text = Text("Hello world")
    @State var placeholder : String = " napisi text"
    @State private var passData = false
    @State private var image = Image(systemName: "photo")
    @State private var showImagePicker = false
    @State var write = ""
    @State var connectionStatus = "connect"
  
    
    let pub = NotificationCenter.default
                .publisher(for: NSNotification.Name("passData"))
    var body: some View {
        NavigationView{
            VStack( spacing: 50){
                image.resizable().scaledToFit()
            text.padding()
            .onTapGesture {
                serverStart()
            }
                TextEditor(text: $placeholder).padding().cornerRadius(10).frame(height: 100).colorMultiply(Color.blue)

                Image(systemName: "paperplane.fill").onTapGesture {

                }
                    .font(.largeTitle)
            }
//            VStack{
//
//                HStack{
//                    cameraButton
//                    TextField("message...", text: $write)
//                        .padding(10)
//                        .background(Color(red: 233.0/255, green: 234.0/255, blue: 243.0/255))
//                        .cornerRadius(25)
//                    Image(systemName: "paperplane.fill").font(.system(size: 20))
//                        .foregroundColor((self.write.count > 0) ? Color.blue : Color.gray).rotationEffect(.degrees(50))
//                }.padding()
//            }
            .navigationBarItems(leading: titleBar)
//            .onAppear(perform: {
//                
//                NotificationCenter.default.addObserver(forName:  NSNotification.Name(rawValue: "passData"), object: nil, queue: nil,  using:{ notification in
//			                    if let userInfo = notification.userInfo, let info = userInfo["info"] {
//                                   
////                                    var buffer = [UInt8](repeating: 0, count: data.count)
////                                    inputStream.read(&buffer, maxLength: data.count)
////                                    
////                                    while(inputStream.hasBytesAvailable)
////                                    let data = info as! Data
////                                    if(data.count > 0){
////                                        var buffer = [UInt8](repeating: 0, count: data.count)
////                                        inputStream.read(&buffer, maxLength: data.count)
////                                        print(inputStream)
////                                    }else{
////                                        print("zavrseno")
////                                    }
//                                    
//                                    print("pozvan")
//                                    let uiimate = UIImage(data: info as! Data)
//                                    if(uiimate != nil){
//                                    self.image = Image(uiImage: uiimate!)
//                                    }
//                      print(info)
//                   }
//                })
//            })
           
        }
    }
    private var titleBar: some View{
        HStack{
            Text(self.connectionStatus).foregroundColor((self.connectionStatus.elementsEqual("connect")) ? Color.green : Color.red)
        }
    }
    private var cameraButton: Button<Image>{
        return Button(action:{ self.showImagePicker = true}){
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
    func passDataFunc(){
//       guard let message = message else {
//           return
//       }
//       text = Text(message)
   }
    private func serverStart(){
        if #available(macOS 10.14, *) {
            
//        initServer(port: 9999)
            let server = Server(port: 9999, transferData: self)
            try! server.start()
            
        RunLoop.current.run()

        } else {
          let stderr = FileHandle.standardError
          let message = "Requires macOS 10.14 or newer"
          stderr.write(message.data(using: .utf8)!)
          exit(EXIT_FAILURE)
        }
        
    }
   
//    func initServer(port: UInt16) {
//        let server = Server(port: port)
//        try! server.start()
//    }
}
struct PassDataToContent{
    
    @Binding var text: Text?
    
   
}
extension PassDataToContent: ReceiveDelegate{
    func onReceive(data: Data) {
        text = Text(String(data: data, encoding: .utf8) ?? "")
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
