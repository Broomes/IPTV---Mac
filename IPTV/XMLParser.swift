//
//  XMLParser.swift
//  IPTV
//
//  Created by Granville Broomes on 6/24/19.
//  Copyright © 2019 CCSD. All rights reserved.
//

import Foundation

let xmlFile: String = "http://iptv.cobbk12.org/GB/resources/list.xml"

struct channel {
    var channelName: String
    var channelAddress: String
}

class ChannelParser: NSObject, XMLParserDelegate
{
    private var listItems: [channel] = []
    private var currentElement = ""
    private var channelName: String = ""
    private var channelAddress: String = ""
    private var parserCompletionHandler: (([channel])-> Void)?
    
    func parseXML(completionHandler: (([channel]) -> Void)?)
    {
        self.parserCompletionHandler = completionHandler
        
        let request = URLRequest(url: URL(string: xmlFile)!)
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: request) { (data, response, error) in
            guard let data = data else{
                if let error = error {
                    print(error.localizedDescription)
                }
                return
            }
            let parser = XMLParser(data: data)
            parser.delegate = self
            parser.parse()
        }
        task.resume()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:])
    {
        currentElement = elementName
        if currentElement == "channel" {
            channelName = ""
            channelAddress = ""
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch currentElement {
        case "channelName": channelName += string
        case "channelAddress": channelAddress += string
        default: break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {
        if elementName == "channel" {
            let channelItem = channel(channelName: channelName, channelAddress: channelAddress)
            self.listItems.append(channelItem)
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        parserCompletionHandler?(listItems)
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError.localizedDescription)
    }
    
    func getChannelList() -> [channel] {
      return listItems
    }
}
