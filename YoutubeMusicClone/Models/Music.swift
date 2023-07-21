//
//  Music.swift
//  YoutubeMusicClone
//
//  Created by 김두원 on 2023/07/10.
//

import Foundation

// MARK: - Music
struct Music: Codable {
    let resultCount: Int
    var results: [Result]
}

// MARK: - Result
struct Result: Codable {
    let trackName: String
    let artistName: String
    let previewUrl: String
    let artworkUrl30, artworkUrl60, artworkUrl100: String
}

