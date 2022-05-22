//
//  APICaller.swift
//  GiphyApp
//
//  Created by Константин Малков on 21.05.2022.
//

import Foundation

struct APIResponse: Codable {
    let data: [Data]
}

struct Data: Codable {
    let id: String
    let images: Images
}

struct Images: Codable {
    let original: Original
    let downsized: Downsized
}

struct Original: Codable {
    let url: String
}

struct Downsized: Codable{
    let url:String
}
