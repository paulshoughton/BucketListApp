//
//  MKPointAnnotation-ObservableObject.swift
//  BucketListApp
//
//  Created by Paul Houghton on 16/11/2020.
//

import MapKit

extension MKPointAnnotation: ObservableObject {

    public var wrappedTitle: String {
        get {
            self.title ?? "Unknown value"
        }
        
        set {
            title = newValue
        }
    }
    
    public var wrappedSubtitle: String {
        get {
            self.subtitle ?? "Unknown value"
        }
        
        set {
            subtitle = newValue
        }
    }
    
}
