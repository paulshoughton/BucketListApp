//
//  ContentView.swift
//  BucketListApp
//
//  Created by Paul Houghton on 12/11/2020.
//

import LocalAuthentication
import MapKit
import SwiftUI

struct BucketListView: View {
    @Binding var centreCoordinate: CLLocationCoordinate2D
    @Binding var selectedPlace: MKPointAnnotation?
    @Binding var showingPlaceDetails: Bool
    @Binding var locations: [CodableMKPointAnnotation]
    @Binding var showingEditScreen: Bool
    
    var body: some View {
        ZStack {
            MapView(
                centreCoordinate: $centreCoordinate,
                selectedPlace: $selectedPlace,
                showingPlaceDetails: $showingPlaceDetails,
                annotations: locations
            )
                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            Circle()
                .fill(Color.blue)
                .opacity(0.3)
                .frame(width: 32, height: 32)
            
            VStack {
                Spacer()
                Button(action: {
                    let newLocation = CodableMKPointAnnotation()
                    newLocation.title = "Example Location"
                    newLocation.coordinate = self.centreCoordinate
                    self.locations.append(newLocation)
                    
                    self.selectedPlace = newLocation
                    self.showingEditScreen = true
                }) {
                    Image(systemName: "plus")
                        .padding()
                        .background(Color.black.opacity(0.75))
                        .foregroundColor(.white)
                        .font(.title)
                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                        .padding(.bottom)
                }
            }
        }
    }
}

struct ContentView: View {
    @State var centreCoordinate = CLLocationCoordinate2D()
    @State var locations = [CodableMKPointAnnotation]()
    @State var selectedPlace: MKPointAnnotation?
    @State var showingPlaceDetails = false
    @State var showingEditScreen = false
    @State var isUnlocked = true
    
    var body: some View {
        ZStack {
            if isUnlocked {
                BucketListView(
                    centreCoordinate: $centreCoordinate,
                    selectedPlace: $selectedPlace,
                    showingPlaceDetails: $showingPlaceDetails,
                    locations: $locations,
                    showingEditScreen: $showingEditScreen
                )
                
//                MapView(centreCoordinate: $centreCoordinate, selectedPlace: $selectedPlace, showingPlaceDetails: $showingPlaceDetails, annotations: locations)
//                    .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
//                Circle()
//                    .fill(Color.blue)
//                    .opacity(0.3)
//                    .frame(width: 32, height: 32)
//
//                VStack {
//                    Spacer()
//                    Button(action: {
//                        let newLocation = CodableMKPointAnnotation()
//                        newLocation.title = "Example Location"
//                        newLocation.coordinate = self.centreCoordinate
//                        self.locations.append(newLocation)
//
//                        self.selectedPlace = newLocation
//                        self.showingEditScreen = true
//                    }) {
//                        Image(systemName: "plus")
//                            .padding()
//                            .background(Color.black.opacity(0.75))
//                            .foregroundColor(.white)
//                            .font(.title)
//                            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
//                            .padding(.bottom)
//                    }
//                }
            }
            else {
                Button("Unlock Places") {
                    self.authenticate()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Capsule())
            }
        }
        .alert(isPresented: $showingPlaceDetails) {
            Alert(
                title: Text(selectedPlace?.title ?? "Unknown"),
                message: Text(selectedPlace?.subtitle ?? "Missing place information"),
                primaryButton: .default(Text("OK")),
                secondaryButton: .default(Text("Edit")) {
                    self.showingEditScreen = true
                })
        }
        .sheet(isPresented: $showingEditScreen, onDismiss: saveData) { 
            if self.selectedPlace != nil {
                AnyView(EditView(placemark: self.selectedPlace!))
            }
            else {
                AnyView(Text("No location selected..."))
            }
        }
        .onAppear(perform: loadData)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func loadData() {
        let filename = getDocumentsDirectory().appendingPathComponent("SavedPlaces")
        
        do {
            let data = try Data(contentsOf: filename)
            locations = try JSONDecoder().decode([CodableMKPointAnnotation].self, from: data)
        }
        catch {
            print("Unable to load saved data")
        }
    }
    
    func saveData() {
        do {
            let filename = getDocumentsDirectory().appendingPathComponent("SavedPlaces")
            let data = try JSONEncoder().encode(self.locations)
            try data.write(to: filename, options: [.atomicWrite, .completeFileProtection])
        }
        catch {
            print("Unable to save data.")
        }
    }
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Please authenticate yourself to unlock your places."
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self.isUnlocked = true
                    }
                    else {
                        // error
                    }
                }
            }
        }
        else {
            // no biometrics
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
