//
//  GraffitiManager.swift
//  Graffiti
//
//  Created by Johan Vallejo on 14/12/16.
//  Copyright © 2016 kijho. All rights reserved.
//

import Foundation

class GraffitiManager {
    static let sharedInstance = GraffitiManager()
    
    var graffitis : [Graffiti] = [Graffiti]()
    
    func save() {
        if let url = databaseURL() {
            NSKeyedArchiver.archiveRootObject(graffitis, toFile: url.path)
        } else {
            print("Error guardando datos")
        }
    }

    func load() {
        if let url = databaseURL(), let saveData = NSKeyedUnarchiver.unarchiveObject(withFile: url.path) as? [Graffiti] {
            graffitis = saveData
        } else {
            print("Error cargando los datos")
        }
    }

    func databaseURL() -> URL? {
        if let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let url = URL(fileURLWithPath: documentDirectory)
            return url.appendingPathComponent("graffitis.data")
        } else {
            return nil
        }
    }

    func imageURL() -> URL? {
        if let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let url = URL(fileURLWithPath: documentDirectory)
            return url
        } else {
            return nil
        }
    }
}
