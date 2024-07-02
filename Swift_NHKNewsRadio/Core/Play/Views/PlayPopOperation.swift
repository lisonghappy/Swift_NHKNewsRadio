//
//  PlayPopOperation.swift
//  Swift_NHKNewsRadio
//
//  Created by LiSong on 2024/5/14.
//

import Foundation
import SwiftUI

public class PlayPopOperation {


    
    public func GetRadioItemPopOperation() -> ActionSheet {
        let downloadBtn : ActionSheet.Button = .default(Text("Downlaod")){
            
        }
        
        let deleteBtn : ActionSheet.Button = .destructive(Text("Delete")){
            
        }
        let markBtn : ActionSheet.Button = .default(Text("Mark")){
            
        }
        let cabcelBtn : ActionSheet.Button = .cancel()
        
        
        return ActionSheet(
            title: Text("title"),
            message: nil,
            buttons: [downloadBtn, deleteBtn,markBtn, cabcelBtn]
        )
    }
    
}
