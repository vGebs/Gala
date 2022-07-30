//
//  UrlExtension.swift
//  Gala
//
//  Created by Vaughn on 2022-07-28.
//

import Foundation

func deleteLocalFile(at url: URL) {
    if FileManager.default.fileExists(atPath: url.path) {
        do {
            try FileManager.default.removeItem(atPath: url.path)
            print("URLExtension: Cleared file at url: \(url.path)")
        } catch {
            print("URLExtension: Could not remove file at url: \(url.path)")
            print("URLExtension-err: \(error)")
        }
    }
}

func getDocumentsDirectory() -> URL {
    // find all possible documents directories for this user
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

    // just send back the first one, which ought to be the only one
    return paths[0]
}
