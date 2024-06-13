//
//  ContentView.swift
//  watchSesame Watch App
//
//  Created by Killian CASTREC on 12/06/2024.
//

import SwiftUI

struct ContentView: View {
    // Exemple de variable avec les entrées
    let doorEntries: [(String, String)] = [
        ("Gate Entry", "Portail d'entrée"),
        ("Gate Exit", "Portail de sortie"),
        ("Lift 1", "Ascenseur 2"),
        ("Dorma", "Porte dorma 2")
    ]
    

    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        // Utilisation de ZStack pour empiler les vues
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.red, Color.black]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
                       
            
            // Utilisation de ScrollView pour permettre le défilement
            ScrollView {
                // Utilisation de VStack pour empiler les boutons verticalement
                Text("Sélectionner l'accès :")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.top, -20)
                
                VStack(spacing: 10) {
                    // Boucle sur les entrées pour créer les boutons
                    ForEach(doorEntries, id: \.0) { entry in
                        Button(action: {
                            // Action du bouton
                            sendRequest(for: entry.0)
                        }) {
                            // Design du bouton
                            Text(entry.1)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("👹"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    func sendRequest(for key: String) {
        guard let url = URL(string: "https://api.exemple.com/open") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["door": key]
        
        /// BODY ENCODING
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            DispatchQueue.main.async {
                self.alertMessage = "Erreur encodage body"
                self.showAlert = true
            }
            return
        }
        
        /// REQUEST
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self.alertMessage = "Erreur : \(error?.localizedDescription ?? "inconnu")"
                    self.showAlert = true
                }
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let response = json["response"] as? Bool {
                    DispatchQueue.main.async {
                        self.alertMessage = response ? "Ouverture en cours" : "Erreur lors de l'ouverture"
                        self.showAlert = true
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.alertMessage = "Erreur lors de l'ouverture"
                    self.showAlert = true
                }
            }
        }
        
        task.resume()
    }
}

#Preview {
    ContentView()
}
