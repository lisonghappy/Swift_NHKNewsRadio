//
//  MainViewModel.swift
//  Swift_NHKNewsRadio
//
//  Created by lisong on 2024/5/16.
//

import SwiftUI
import Foundation
import MediaPlayer


class MainViewModel: ObservableObject {
    
    @Published var radioItems: [RadioModel] = []{
        didSet {
            filter()
            saveData()
        }
    }
    
    @Published var radioSections: [RadioSectionModel] = []
    @Published var selectedRadio: RadioModel? = nil
    
    @Published var isRadioInVisible: Bool = false
    var InVisibleMaxY: Double = 1000
    var soundService: SoundService? = nil
    
    
    @AppStorage("is_new_to_old") var isNewToOld: Bool = true
    @AppStorage("is_repeat_type") var repeatType: Int = 0   // 0,1,2
    @AppStorage("radio_play_jump_second") var jumpPlaySecond: RadioPlayJumpSecond = RadioPlayJumpSecond._10

    @Published var oldNestDate: Date = Date()



    
    static let CACHE_FOLDER_NAME: String = "nhk_radios"
    static let CACHE_FILE_NAME: String = "radios"
    static let CACHE_RADIO_FOLDER_NAME: String = "radio_files"
    
    @Published var isDownloadFailed: Bool = false
    @Published var isNeedDownload: Bool = false
    
    
    init(){
        LocalFileManager.instance.createFolderIfNeeded(folderName: MainViewModel.CACHE_FOLDER_NAME)
    }
    
    
    
    // get data from url
    func getData() async {
        NHKRadioNewsDataService.instance.getNHKNewsRadioXMLData {[weak self] data in
            guard let data = data else {return}
            let parser = NHKNewsRadioXMLParser(data: data)
            let newsData = parser.parse()
            
            if newsData.items.count > 0 {
                self?.appendData(radios: newsData.items)
            }
        }
    }
    
    
    //get data from lcoal cache
    func getDataFromCache() {
//        DispatchQueue.global(qos: .background).async {
            let name = MainViewModel.getRadioConfigFilePath()
            guard
                LocalFileManager.instance.fileExist(forResource: name, withExtension: "json"),
                let cacheData = LocalFileManager.instance.getJsonCacheFile([RadioModel].self, fileName: name)
            else {
                if LocalFileManager.instance.fileExist(forResource: name, withExtension: "json"),
                   let cacheRawData = LocalFileManager.instance.getJsonCacheFile([RawRadioModel].self, fileName: name){
//                    DispatchQueue.main.async {
//                    }
                    self.prepareFromRawRadioModelData(rawRadios: cacheRawData)
                }
                return
            }
            
            self.prepareFromRadioModelData(radios: cacheData)
//            DispatchQueue.main.async {
//            }
//        }
    }
    
    
    private func prepareFromRadioModelData(radios : [RadioModel]) {
        var temp: [RadioModel] = []
        // init radio state
        for var item in radios {
            item.isDownloading = false
            item.isDownloaded = checkRadioAudioFile(fileName: item.fileName)
            temp.append(item)
        }
        
        radioItems = temp
        
    }
    
    private func prepareFromRawRadioModelData(rawRadios : [RawRadioModel]) {
        var temp: [RadioModel] = []
        // init radio state
        for item in rawRadios {
            var radio = RadioModel(
                rawData: item,
                isDownloaded: false, isDownloading: false
            )
            
            radio.isDownloaded = checkRadioAudioFile(fileName: radio.fileName)
            temp.append(radio)
        }
        
        radioItems = temp
        
    }
    
    func getRadioAudioFilePath(radio:RadioModel) -> URL? {
        LocalFileManager.instance.getSaveFilePath(forResource: MainViewModel.getRadioFilePath(rdioFileName: radio.fileName))
    }
    
    func changeSort(){
        self.isNewToOld.toggle()
        sort()
    }
    
    //download radio mp3 file
    func downloadRadio(radio: RadioModel) {
        
        changeRadioDownloadingState(radio: radio, state: true)
        
//        DispatchQueue.global(qos: .background).async {
            
            NHKRadioNewsDataService.instance.downloadRadioAudio(urlString: radio.rawData.url) {[weak self] (data, error) in
                guard let data = data else {
                    if error as? URLError == URLError(.unknown) {
                        self?.changeRadioNoDownloadFromServerState(radio: radio, state: true)
                    }
                    
                    self?.changeRadioDownloadingState(radio: radio, state: false)
                    self?.isDownloadFailed.toggle()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self?.isDownloadFailed.toggle()
                    }
                    return
                }
                //save
                LocalFileManager.instance.createFolderIfNeeded(folderName: MainViewModel.getRadioFilePath(rdioFileName: ""))
                LocalFileManager.instance.saveFile(fileName: MainViewModel.getRadioFilePath(rdioFileName: radio.fileName), data: data)
                
                //change state
                self?.changeRadioDownloadedState(radio: radio, state: true)
                self?.changeRadioDownloadingState(radio: radio, state: false)
            }
//        }
    }
    
    func downloadRadios(radios: [RadioModel]) {
        for radio in radios {
            downloadRadio(radio: radio)
        }
    }
    
    
    func deleteRadio(radio: RadioModel) {
        
        if let selectedRadio = selectedRadio,
            selectedRadio.id == radio.id,
           let soundService = soundService {
            
            soundService.stopRadio()
            self.selectedRadio = nil
        }
        

        //delete file
        let isDeleteOk = LocalFileManager.instance.deleteFile(fileName: MainViewModel.getRadioFilePath(rdioFileName: radio.fileName))
        
        if isDeleteOk {
            changeRadioDownloadedState(radio: radio, state: false)
        }
    }
    
    func deleteRadios(radios: [RadioModel]) {
        for radio in radios {
            deleteRadio(radio: radio)
        }
    }
    
    func deleteAllRadios() {
        let radios = radioItems.filter{$0.isDownloaded}
        for radio in radios {
            deleteRadio(radio: radio)
        }
        
        //delete all mp3 file
        LocalFileManager.instance.deleteFolder(folderName: "\(MainViewModel.CACHE_FOLDER_NAME)/\(MainViewModel.CACHE_RADIO_FOLDER_NAME)")
    }
    
    
    
    func markRadios(radios: [RadioModel]){
        for radio in radios {
            changeRadioMarkState(radio: radio, state: true)
        }
    }
    
    func unmarkRadios(radios: [RadioModel]){
        for radio in radios {
            changeRadioMarkState(radio: radio, state: false)
        }
    }
    
    
    
    func changeRadioPlayType(){
        withAnimation(.easeInOut(duration: 0.5)){
            if repeatType == 2 {
                repeatType = 0
            }else {
                repeatType += 1
            }
        }
    }
    
    
    
    
    
    //MARK: change radio state ---------------------------------------------------------------------
    
    static func getRadioFilePath(rdioFileName: String) -> String {
        if rdioFileName.isEmpty {
            return "\(MainViewModel.CACHE_FOLDER_NAME)/\(MainViewModel.CACHE_RADIO_FOLDER_NAME)"
        }else {
        return "\(MainViewModel.CACHE_FOLDER_NAME)/\(MainViewModel.CACHE_RADIO_FOLDER_NAME)/\(rdioFileName)"
        }
            
        
    }
    
    static func getRadioConfigFilePath() -> String {
        "\(MainViewModel.CACHE_FOLDER_NAME)/\(MainViewModel.CACHE_FILE_NAME)"
    }
    
    func changeRadioDownloadedState(radio: RadioModel, state: Bool) {
        let index = radioItems.firstIndex { data in
            data.id == radio.id
        }
        if let index = index, radioItems[index].isDownloaded != state {
            radioItems[index].isDownloaded = state
        }
    }
    
    func changeRadioDownloadingState(radio: RadioModel, state: Bool) {
        let index = radioItems.firstIndex { data in
            data.id == radio.id
        }
        if let index = index, radioItems[index].isDownloading != state {
            radioItems[index].isDownloading = state
        }
    }
    
    
    func changeRadioNoDownloadFromServerState(radio: RadioModel, state: Bool) {
        let index = radioItems.firstIndex { data in
            data.id == radio.id
        }
        if let index = index, radioItems[index].isNoDownloadFormServer != state {
            radioItems[index].isNoDownloadFormServer = state
        }
    }
    
    func changeRadioMarkState(radio: RadioModel, state: Bool) {
        let index = radioItems.firstIndex { data in
            data.id == radio.id
        }
        if let index = index{
            radioItems[index].isMark = state
        }
    }
    
    func changeRadioMarkState(radio: RadioModel) {
        changeRadioMarkState(radio: radio, state: !radio.isMark)
    }
    
    func saveData(){
//        DispatchQueue.global(qos: .background).async {
            
            guard
                let jsonData = try? JSONEncoder().encode(self.radioItems)
            else {
                return
            }
            
            LocalFileManager.instance.saveFile(fileName: "\(MainViewModel.getRadioConfigFilePath()).json", data: jsonData)
//        }
    }
    
    
    //MARK: PRIVATE FUNC------------------------------------------------------------------------------
    
    
    private func checkRadioAudioFile(fileName: String) -> Bool {
        LocalFileManager.instance.fileExist(forResource: MainViewModel.getRadioFilePath(rdioFileName: fileName))
    }
    
    
    private func appendData(radios: [RadioModel]){
        var temp = radioItems
        
        for item in radios {
            if !temp.contains(item) {
                temp.append(item)
            }
        }
        
        radioItems = temp
    }
    
    private func filter(){
        radioSections = []
        //filter
        for item in radioItems {
            
            let dateStr = item.PubDate.asShortDateString()
            
            let index = radioSections.firstIndex { section in
                section.date == dateStr
            }
            
            if let index = index {
                if !radioSections[index].radios.contains(item) {
                    radioSections[index].radios.append(item)
                }
                
            }else {
                radioSections.append(RadioSectionModel(date: dateStr, radios: [item]))
            }
            
            if oldNestDate > item.PubDate {
                oldNestDate = item.PubDate
            }
        }
        
        // set state
        var temp: [RadioSectionModel]  = []
        for section in radioSections {
            temp.append(RadioSectionModel(
                date: section.date,
                radios: section.radios,
                count: section.radios.count,
                downloadedCount: section.radios.filter{$0.isDownloaded}.count
            ))
        }
        radioSections = temp
        
        sort()
    }
    
    
    private func sort(){
        //sort
        
        if isNewToOld {
            radioSections.sort{section1, section2 in
                section1.date  > section2.date
            }
            
            //            for index in radioSections.indices {
            //                radioSections[index].radios.sort{radio1, radio2 in
            //                    return radio1.pubDate > radio2.pubDate
            //                }
            //            }
            
        }else {
            radioSections.sort{section1, section2 in
                section1.date  < section2.date
            }
            
            //            for index in radioSections.indices {
            //                radioSections[index].radios.sort{radio1, radio2 in
            //                    radio1.pubDate < radio2.pubDate
            //                }
            //            }
        }
        
        
        
    }
}



extension MainViewModel {
    static let mock = MainViewModel()
    
    
}
