//
//  JoWebViewConfiguration.swift
//  JoWebJS
//
//  Created by otisaldridge on 15/9/25.
//  Copyright © 2015年 zhuxietong. All rights reserved.
//

import UIKit
import WebKit



typealias Js_Config_Block = (user_controller:WKUserContentController,hander:WKScriptMessageHandler)->()

typealias Js_Hander_Block = (user_controller:WKUserContentController,message:WKScriptMessage)->()


class JoWebViewConfiguration:WKWebViewConfiguration,WKScriptMessageHandler {
    
    var hander_block: Js_Hander_Block?
    
    internal func userContentController(userContentController: WKUserContentController,didReceiveScriptMessage message: WKScriptMessage) {
        self.hander_block?(user_controller: userContentController,message: message)
    }
    
    var config_block:Js_Config_Block
    {
        get{
            return {_,_ in }
        }
        
        set(newValue){
            let userController:WKUserContentController = WKUserContentController()
            newValue(user_controller: userController, hander: self)
            self.userContentController = userController;
        }
    }
    
}
