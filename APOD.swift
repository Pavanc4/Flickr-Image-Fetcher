
//  Photo.swift
//  FlickrImageFetcher
//
//  Created by PavanAvvaru on 2025-04-24.
//

// APOD.swift
import Foundation

struct APOD: Codable {
    let title: String
    let imageURL: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case imageURL = "url"
    }
}
