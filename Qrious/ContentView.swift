//
//  ContentView.swift
//  Qrious
//
//  Created by Navan Chauhan on 22/07/20.
//  Copyright © 2020 Navan Chauhan. All rights reserved.
//

import SwiftUI

struct Todo: Codable, Identifiable {
    public var id: Int
    public var title: String
    public var published_date: String
    public var defined_type_name: String
    public var url: String
    public var description1: String?
    public var paperURL: String?
    public var candidates: String?
    
}


// group=13668 ( Chemrxiv )
class FetchToDo: ObservableObject {
    @Published var query: String = ""
    @Published var todos = [Todo]()
     
    init() {
        //var request = URLRequest(url: URL(string: "https://api.figshare.com/v2/articles/search?search_for=\(q)&page_size=\(p)")!)
        var request = URLRequest(url: URL(string: "https://api.figshare.com/v2/articles/search?page_size=20")!)
        request.httpMethod = "POST"
        
        //let url = URL(string: "https://jsonplaceholder.typicode.com/todos")!
        URLSession.shared.dataTask(with: request) {(data, response, error) in
            do {
                if let todoData = data {
                    let decodedData = try JSONDecoder().decode([Todo].self, from: todoData)
                    DispatchQueue.main.async {
                        self.todos = decodedData
                    }
                } else {
                    print("No data")
                }
            } catch {
                print("Error")
            }
        }.resume()
    }
    func fetchAgain(q: String = "Hepatitis+B+Virus+Silico",p: String = "10",limit: Bool = false, prepints: Bool = false) {
        var s = "https://api.figshare.com/v2/articles/search?search_for=\(q.replacingOccurrences(of: " ", with: "+"))&page_size=\(p)"
        //var request = URLRequest(url: URL(string: "https://api.figshare.com/v2/articles/search?search_for=\(q)&page_size=\(p)")!)
        if limit {
            s += "&group=13668"
        }
        if prepints {
            s += "&item_type=12"
        }
        print(s, limit)
        var request = URLRequest(url: URL(string: s)!)
        request.httpMethod = "POST"
        
        //let url = URL(string: "https://jsonplaceholder.typicode.com/todos")!
        URLSession.shared.dataTask(with: request) {(data, response, error) in
            do {
                if let todoData = data {
                    let decodedData = try JSONDecoder().decode([Todo].self, from: todoData)
                    DispatchQueue.main.async {
                        self.todos = decodedData
                    }
                } else {
                    print("No data")
                }
            } catch {
                print("Error")
            }
        }.resume()
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ClearButton: ViewModifier
{
    @Binding var text: String
    public func body(content: Content) -> some View{
        ZStack(alignment: .trailing){
            content
            if !text.isEmpty{
                Button(action:{
                    self.text = ""
                }){
                    Image(systemName: "delete.left")
                        .foregroundColor(Color(UIColor.opaqueSeparator))
                }
                .padding(.trailing, 8)
            }
        }
    }
}

class configuration: ObservableObject {
    @Published var question: String = "Results show what are the compounds?"
}

struct ContentView: View {
    @State private var selection = 0
    @State private var advance = true
    @State public var query = "Covid-19 Compounds"
    @State public var noOfArticles = "15"
    @State private var executed = false
    @EnvironmentObject var config: configuration
    @State private var ques: String = configuration().question
    //"Results show what top compounds?"
    @State public var LimitToChemrxiv: Bool = false
    @State private var LimitToPreprints: Bool = false
    @ObservedObject var fetch = FetchToDo()
    //let bert = BERTQAFP16()
    var body: some View {
        TabView(selection: $selection){
            NavigationView{
                
                VStack{
                    /*
                    HStack{
                        
                    Text("Configuration")
                        .font(.title)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.leading)
                    
                    }*/
                Form{
                    
                    Section(header: Text("Search Query")){
                            TextField("Search Query",text: $query).modifier(ClearButton(text: $query))
                    }
                    
                    
                    Section(header: Text("Configuration")){
                        VStack{
                        HStack{
                            Text("No. Of Articles:")
                            TextField("No. Of Articles", text: $noOfArticles)
                                .modifier(ClearButton(text: $noOfArticles))
                        .keyboardType(.numberPad)
                        }.disabled(!advance)
                            HStack{
                                Toggle(isOn: $LimitToChemrxiv){
                                    Text("Limit to ChemRxiv")
                                }
                            }
                            HStack{
                                Toggle(isOn: $LimitToPreprints){
                                    Text("Limit to Preprints")
                                }
                            }
                        }
                    }
                        
                        Section(header: Text("Query for AI Model")){
                            TextField("Query for AI Model",text: $ques, onEditingChanged: {_ in self.config.question = self.ques}).modifier(ClearButton(text: $ques))
                            
                        }
                        
                    
                    Section{
                        Button(action: {
                            self.fetch.fetchAgain(q: self.query, p: String(self.noOfArticles), limit: self.LimitToChemrxiv, prepints: self.LimitToPreprints)
                            let impactMed = UIImpactFeedbackGenerator(style: .medium)
                            impactMed.impactOccurred()
                        }){
                            Text("Get Papers")
                        }
                    }
                    
                }
                    Text("OwO")
                        .frame(height: 50.0)
                }
            .navigationBarTitle(Text("Qrious"))
            }
                .tabItem {
                    VStack {
                        Image(systemName: "gear")
                        .font(.title) //Image("first")
                        Text("Configuration")
                    }
                }
                .tag(0)
            NavigationView{
            //Text(" View").font(.title)
                VStack {
                    List(fetch.todos) { todo in NavigationLink(destination:  DetailedView(article: todo)){
                               VStack(alignment: .leading) {
                                   Text(todo.title)
                                   Text("\(todo.published_date)")
                                       .font(.system(size: 11))
                                       .foregroundColor(Color.gray)
                            }}
                           }
                       }
            .navigationBarTitle("Articles")
            }
                
                .tabItem {
                    VStack {
                         Image(systemName: "list.bullet")
                            .font(.title)
                        Text("Articles")
                    }
                }
                .tag(1)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
