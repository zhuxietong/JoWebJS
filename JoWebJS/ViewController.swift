//  Created by otisaldridge on 15/9/25.
//  Copyright © 2015年 zhuxietong. All rights reserved.
//

import UIKit
import WebKit
//import JSQWebViewController


class ViewController: UIViewController {
    
    @IBAction func openJsWeb(sender: AnyObject) {
        
        let path = NSBundle.mainBundle().pathForResource("index", ofType: "html")
        
        let url = NSURL(fileURLWithPath: path!)
//        let url = NSURL(string: "http://192.168.0.102/test/index.html")!

        let config = JoWebViewConfiguration()
        config.config_block = { controller,hander in
            controller.addScriptMessageHandler(hander, name: "find")
            controller.addScriptMessageHandler(hander, name: "search")
            
            let appUserInfo =
            "        function getAppUserInfo(){" +
            "           return {'username':'zhuxietong','age':'16'} ;" +
            "        }"
            
            let script11 = WKUserScript(source: appUserInfo, injectionTime: WKUserScriptInjectionTime.AtDocumentStart, forMainFrameOnly: true)
            let script12 = WKUserScript(source: appUserInfo, injectionTime: WKUserScriptInjectionTime.AtDocumentEnd, forMainFrameOnly: true)
            
            controller.addUserScript(script11)
            controller.addUserScript(script12)
        }
        
        
        config.hander_block = { controller,message in
            let alert = UIAlertView(title: "js post name is : \(message.name)", message:"javaScript: \n\(message.body)", delegate: nil, cancelButtonTitle: "canle")
            alert.show()
            
        }
        
        let webVC = WebViewController(url: url, wk_config: config)
        self.navigationController?.pushViewController(webVC, animated: true)
        
    }


}

