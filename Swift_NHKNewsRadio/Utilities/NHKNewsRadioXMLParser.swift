//
//  NHKNewsRadioXMLParser.swift
//  Swift_NHKNewsRadio
//
//  Created by lisong on 2024/5/16.
//


import Foundation


public class NHKNewsRadioXMLParser: NSObject {
    
    private var parser: XMLParser? =  nil
    
    private var newsModel: NHKNewsRadioModel
    private var lastElementName: String = ""
    private var itemIndex: Int = -1
    
    
     
    init(contentsOf url: URL){
        newsModel = NHKNewsRadioModel()
        super.init()
        initParser(url: url)
    }
    
    
    init(data: Data?){
        newsModel = NHKNewsRadioModel()
        super.init()
        
        initParser(data: data)
    }
    
    
    private func initParser(url: URL){
        guard let data = try? Data(contentsOf: url) else { return }
        initParser(data: data)
    }
    
    private func initParser(data: Data?){
        guard let data = data else { return }
        
        parser = XMLParser(data: data)
        
        guard let parser = parser else { return }
        parser.delegate = self
        parser.shouldProcessNamespaces = true
        
    }
    
    
    public func parse() -> NHKNewsRadioModel {
        if parser != nil {
            parser?.parse()
        }
        
        return newsModel
    }
}


extension NHKNewsRadioXMLParser:  XMLParserDelegate {
    
    public func parserDidStartDocument(_ parser: XMLParser) {
//        print("Start of the document")
//        print("Line number: \(parser.lineNumber)")
    }
    
    public func parserDidEndDocument(_ parser: XMLParser) {
//        print("End of the document")
//        print("Line number: \(parser.lineNumber)")
    }
    
    
    /// Called when opening tag (`<elementName>`) is found/
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        lastElementName = elementName
        
        if lastElementName == "item" {
            itemIndex += 1
            newsModel.items.append(
                RadioModel(
                    rawData: RawRadioModel(
                        title: "", url: "", length: 0, type: "", pubDate: "", isPermaLink: false, description: "", duration: ""
                    )
                )
            )
        }
        
        switch lastElementName {
        case "category":
            for (_, attr_val) in attributeDict {
                newsModel.category += attr_val
            }
            break
        case "image":
            for (_, attr_val) in attributeDict {
                newsModel.image += attr_val
            }
            break
        case "enclosure":
            for (attr_key, attr_val) in attributeDict {
                switch attr_key {
                case "url":
                    newsModel.items[itemIndex].rawData.url = attr_val
                    break
                case "length":
                    newsModel.items[itemIndex].rawData.length = Double(attr_val) ?? 0
                    break
                case "type":
                    newsModel.items[itemIndex].rawData.type = attr_val
                    break
                default:
                    break
                }
            }
            break
        case "guid":
            for (_, attr_val) in attributeDict {
                newsModel.items[itemIndex].rawData.isPermaLink = Bool(attr_val) ?? false
            }
            break
        default:
            break
        }
        
        
    }
    
    
    // Called when closing tag (`</elementName>`) is found
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
    }
    
    /// Called when a character sequence is found
    public func parser(_ parser: XMLParser, foundCharacters string: String ) {
        let content = string.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: .newlines).trimmingCharacters(in: .controlCharacters)
        
        if (content != "") {
            switch lastElementName {
            case "title":
                if itemIndex == -1 {
                    newsModel.title += content
                }
                else {
                    newsModel.items[itemIndex].rawData.title += content
                }
                break
            case "link":
                newsModel.link += content
                break
            case "language":
                newsModel.language += content
                break
            case "copyright":
                newsModel.copyright += content
                break
            case "author":
                newsModel.author += content
                break
            case "description":
                if itemIndex == -1 {
                    newsModel.description += content
                }
                else {
                    newsModel.items[itemIndex].rawData.description += content
                }
                break
            case "lastBuildDate":
                newsModel.lastBuildDate += content
                break
            case "keywords":
                newsModel.keywords += content
                break
            case "email":
                newsModel.email += content
                break
            case "explicit":
                newsModel.explicit = Bool(content) ?? false
                break
            case "new-feed-url":
                newsModel.newFeedUrl += content
                break
            case "pubDate":
                if itemIndex != -1 {
                    newsModel.items[itemIndex].rawData.pubDate += content
                    /*
                     var dateTimeZone = TimeZone(abbreviation: "GMT-6")
                     lazy var dateFormater: DateFormatter = {
                         let df = DateFormatter()
                         //Please set up this DateFormatter for the entry `date`
                         df.locale = Locale(identifier: "en_US_POSIX")
                         df.dateFormat = "MMM dd, yyyy"
                         df.timeZone = dateTimeZone
                         return df
                     }()
                     
                     nextArticle?.date = dateFormater.date(from: textBuffer)

                     */
                }
                break
            case "guid":
                if itemIndex != -1 {
                    newsModel.items[itemIndex].rawData.guid = content
                }
                break
            case "duration":
                if itemIndex != -1 {
                    newsModel.items[itemIndex].rawData.duration += content
                }
                break
            default:
                break
            }
            
            
        }
    }
    
    /// Called when a CDATA block is found
    public func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        guard String(data: CDATABlock, encoding: .utf8) != nil else {
            print("CDATA contains non-textual data, ignored")
            return
        }
        
    }
    
    /// For debugging
    public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error ) {
        print(parseError)
        print("on:", parser.lineNumber, "at:", parser.columnNumber)
        
    }
    
}
