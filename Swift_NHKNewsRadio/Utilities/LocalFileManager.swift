//
//  LocalFileManager.swift
//
//  Created by LiSong on 2023/10/23.
//

import SwiftUI




public class LocalFileManager {
    static let instance = LocalFileManager()
    
    private let cacheDataFolderName: String
    
    
    private init(){
        cacheDataFolderName = LocalFileManager.getAppDisplayName()
        createCacheDataFolderIfNeeded()
    }
    
    
    static func getAppDisplayName() -> String {
        //获取app信息
        guard let infoDictionary: Dictionary = Bundle.main.infoDictionary,
              
                // app名称
              //        let kAppDisplayName = infoDictionary["CFBundleDisplayName"] as? String
                //bundle id
                let bundleIdentifier = infoDictionary["CFBundleIdentifier"] as? String
        else {
            
            return "nhk radio"
        }
        
        return bundleIdentifier
    }
    
    func createFolderIfNeeded(folderName: String){
        guard
            let path = FileManager
                .default
                .urls(for: .cachesDirectory, in: .userDomainMask)
                .first?
                .appendingPathComponent(cacheDataFolderName)
                .appendingPathComponent(folderName)
                .path
        else{
            return
        }
        
        if !FileManager.default.fileExists(atPath: path) {
            
            do {
                try FileManager.default.createDirectory(
                    atPath: path,
                    withIntermediateDirectories: true)
                print("create folder success.")
            } catch let error {
                print("create folder error. \(error)")
            }
            
        }
    }
    
    private func createCacheDataFolderIfNeeded(){
        createFolderIfNeeded(folderName: "")
    }
    
    private func getFolderPath() ->URL? {
        
        /*
         // FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
         [file:///Users/xxx/Library/Developer/.../Documents/]
         // FileManager.default.urls(for: .documentationDirectory, in: .userDomainMask)
         [file:///Users/xxx/Library/Developer/.../Library/Documentation/]
         // FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
         [file:///Users/xxx/Library/Developer/.../Library/Caches/]
         // FileManager.default.temporaryDirectory
         file:///Users/xxx/Library/Developer/.../tmp/
         */
        return FileManager
            .default
            .urls(for: .cachesDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(cacheDataFolderName)
    }
    
    func createFolder(folderName: String){
        guard
            let url = getSaveFilePath(forResource: folderName),
            !FileManager.default.fileExists(atPath: url.path)
        else {
            return
        }
        
        do {
            try FileManager.default.createDirectory(atPath: url.path, withIntermediateDirectories: true)
            print("create folder success.")
        } catch let error {
            print("create folder error. \(error)")
        }
    }
    
    func deleteFolder(folderName: String){
        guard
            let url = getSaveFilePath(forResource: folderName),
            FileManager.default.fileExists(atPath: url.path)
        else {
            return
        }
        
        do {
            try FileManager.default.removeItem(atPath: url.path)
            print("delete folder success.url.path:\(url.path)")
        } catch let error {
            print("delete folder error. \(error)")
        }
        
    }
    
    func deleteAppFolder(){
        guard
            let path = FileManager
                .default
                .urls(for: .cachesDirectory, in: .userDomainMask)
                .first?
                .appendingPathComponent(cacheDataFolderName)
                .path
        else{
            return
        }
        
        do {
            try FileManager.default.removeItem(atPath: path)
            print("delete folder success.")
        } catch let error {
            print("delete folder error. \(error)")
        }
        
    }
    
    public func deleteFile(fileName:String, withExtension: String = "") -> Bool {
        guard
            let path = getSaveFilePath(forResource: fileName, withExtension:withExtension),
            FileManager.default.fileExists(atPath: path.path)
        else {
            print("delete file path error.")
            return false
        }
        do {
            try FileManager.default.removeItem(at: path)
            print("delete file form cache ok.")
            return true
        } catch let error {
            print("delete file error. \(error)")
            return false
        }
        
    }
    
    func getSaveFilePath(forResource:String, withExtension: String = "")  -> URL? {
        createCacheDataFolderIfNeeded()
        
        guard let folderPath = getFolderPath() else {
            return nil
        }
        if withExtension.isEmpty {
            return folderPath.appendingPathComponent("\(forResource)")
        }
        else{
            return folderPath.appendingPathComponent("\(forResource).\(withExtension)")
        }
    }
    
    func fileExist(forResource: String, withExtension: String = "") -> Bool {
        
        guard !forResource.isEmpty,
            let url = getSaveFilePath(forResource: forResource, withExtension: withExtension)
        else {
            return false
        }
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    func folderExist(forResource: String) -> Bool {
        
        guard !forResource.isEmpty,
            let url = getSaveFilePath(forResource: forResource)
        else {
            return false
        }
        
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    //MARK: -------------------------- File --------------------------
    
    func getJsonCacheFile<T>(_ type: T.Type, fileName: String) -> T? where T : Decodable {
        guard
            let filePath = getSaveFilePath(forResource: fileName, withExtension:"json"),
            FileManager.default.fileExists(atPath: filePath.path)
        else {
            print("get json file cache error! file not exist. name: \(fileName)")
            return nil
        }
        
        guard
            let data = try? Data(contentsOf: filePath),
            let result = try? JSONDecoder().decode(type, from: data)
        else {
            return nil
        }
        print("get cache data success! form: \(filePath.path)")
        return result
    }
    
    func saveFile(fileName: String, data: Data){
        guard
            let filePath = getSaveFilePath(forResource: fileName)
        else {
            return
        }
        do {
            if !FileManager.default.fileExists(atPath: filePath.path) {
                print("create new file. \(filePath)")
                FileManager.default.createFile(atPath: filePath.path, contents: data)
            }else{
                try data.write(to: filePath)
                print("save [\(filePath)] file ok.")
            }
        } catch let error {
            print("save [\(filePath)] file error. \(error)")
        }
    }
      
}
