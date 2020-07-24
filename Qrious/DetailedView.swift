//
//  DetailedView.swift
//  Qrious
//
//  Created by Navan Chauhan on 22/07/20.
//  Copyright © 2020 Navan Chauhan. All rights reserved.
//


import SwiftUI


struct DetailedView: View {
    //public var description: String
    //@State public var defined_type_name: String = "p"
    @EnvironmentObject var config: configuration
    @State private var description1: String = "Loading.."
    @State private var paperURL: String = "Fetching..."
    @State private var candidates: String = "Extracting Compounds"
    func fetch(articleURL: String) {
        //let url = URL(string: "\(articleURL)")!
        var request = URLRequest(url: URL(string: articleURL)!)

        request.httpMethod = "GET"
        print(request)
               // 2.
               URLSession.shared.dataTask(with: request) {(data, response, error) in
                   do {
                       if let todoData = data {
                           // 3.
                        //let decodedData = try JSONDecoder().decode([Paper].self, from: todoData)
                        let decodedData = try JSON(data: todoData)
                           DispatchQueue.main.async {
                            self.description1 = decodedData["description"].string!
                            self.paperURL = decodedData["figshare_url"].string!
                            print("Finding Answer")
                            self.candidates = String(BERT().findAnswer(for: self.config.question, in: self.description1))
                            //return decodedData
                            
                           }
                       } else {
                           print("No data")
                       }
                   } catch {
                       print("Error")
                   }
               }.resume()
        
    }
    let article: Todo
    var body: some View {
        NavigationView{
            VStack{
                Text(article.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .contextMenu {
                Button(action: {
                    UIPasteboard.general.string = self.article.title
                }) {
                    Text("Copy")
                    Image(systemName: "doc.on.doc")
                        }}
                
                Button("Paper URL") {
                    UIApplication.shared.open(URL(string: self.paperURL)!)
                }
                Text(self.config.question)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
                Text(self.candidates)
                Text("Abstract")
                    .font(.headline)
                    .fontWeight(.semibold)
                ScrollView(.vertical){
                    VStack{
                        Text((description1.replacingOccurrences(of: "<[^>]+>", with: "", options: String.CompareOptions.regularExpression, range: nil)).replacingOccurrences(of: "&[^;]+;", with: "", options: String.CompareOptions.regularExpression, range: nil))
                        //Text(description1.withoutHtml)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationBarTitle(Text(String(self.article.defined_type_name))
            .font(.largeTitle)
            .fontWeight(.black), displayMode: .inline)
        }.onAppear {
            self.fetch(articleURL: self.article.url)
        }
    }
}

#if DEBUG
struct DetailedView_Previews: PreviewProvider {
    static var previews: some View {
        DetailedView(
            article: Todo(
                id: 0,
                title: "Sample Paper Name",
                published_date: "Excatly",
                defined_type_name: "Lmao",
                url: "https://google.com"
                )
        )
    }
}
#endif

