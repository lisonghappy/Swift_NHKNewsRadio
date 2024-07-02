//
//  NHKRadioNewsDataService.swift
//  Swift_NHKNewsRadio
//
//  Created by lisong on 2024/5/16.
//

import Foundation



import Foundation
import Combine

public class NHKRadioNewsDataService {
    public static let instance = NHKRadioNewsDataService()
    
    private let  nhkRadioURL : URL? = URL(string: Constant.NHKNewsRadioURL)
    
    
    
    
    public var cancellables = Set<AnyCancellable>()
    
    
    private init(){ }
    

    /// download net data，and update local cache file
    public func getNHKNewsRadioXMLData(completionHandler: @escaping (Data?) -> ()){
        guard let url = nhkRadioURL else {
            completionHandler(nil)
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .tryMap(handleOutput)
            .sink { compltation in
                switch compltation {
                case .finished :
                    break
                case .failure(let error) :
                    completionHandler(nil)
                    print("downloading net data error. \(error)")
                    break
                }
            } receiveValue: {receiveData in
                completionHandler(receiveData)
            }
            .store(in: &cancellables)
    }
    
    public func downloadRadioAudio(urlString: String, completionHandler: @escaping (Data?, Error?) -> ()) {
        guard
            let url = URL(string: urlString)
        else {
            completionHandler(nil, nil)
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .tryMap(handleOutput)
            .sink { compltation in
                switch compltation {
                case .finished :
                    break
                case .failure(let error) :
                    completionHandler(nil, error)
                    print("downloading net data error. \(error)")
                    break
                }
            } receiveValue: {receiveData in
                completionHandler(receiveData, nil)
            }
            .store(in: &cancellables)
    }
    
    
    
    private func handleOutput(output: URLSession.DataTaskPublisher.Output) throws -> Data {
        guard let resoponse = output.response as? HTTPURLResponse
        else {
            throw URLError(.badServerResponse)
        }

        if resoponse.statusCode >= 200 && resoponse.statusCode < 300 {
            return output.data
        }else if resoponse.statusCode == 404 {
            throw URLError(.unknown)
        }else {
            throw URLError(.badServerResponse)
        }
        
    }
}
