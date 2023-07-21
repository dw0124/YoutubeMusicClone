//
//  WebService.swift
//  YoutubeMusicClone
//
//  Created by 김두원 on 2023/07/11.
//

import Foundation

class WebService {
    
    func loadData<T: Codable>(urlStr: String, completion: @escaping (T?) -> Void) {
        guard let url = URL(string: urlStr) else { fatalError("Invalid URL") }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                completion(nil)
            } else if let data = data {
                do {
                    let result = try JSONDecoder().decode(T.self, from: data)
                    completion(result)
                } catch {
                    print("Failed to decode JSON data: \(error)")
                    completion(nil)
                }
            }
        }.resume()
    }

    
}
