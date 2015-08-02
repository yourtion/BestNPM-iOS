//
//  NpmDataSource.swift
//  NPM data
//
//  Created by YourtionGuo on 7/29/15.
//  Copyright (c) 2015 Yourtion. All rights reserved.
//

import Foundation

@objc protocol NpmDataSourceDelegate {
    optional func getSearchResult(result:NSArray!, error:NSError!)
    optional func getSuggestionsResult(result:Array<String>!, error:NSError!)
    optional func getGetNpmPackageResult(result:AnyObject!, error:NSError!)
}

class NpmDataSource {
    
    var delegate:NpmDataSourceDelegate?
    let op:NSOperationQueue = NSOperationQueue()
    
    static let sharedInstance = NpmDataSource()
    private init() {}
    
    func SearcNpm (keyword:String) {
        self.op.cancelAllOperations()
        let urlstr = "https://npm.best/api/search.json?query=" + keyword + "&skip=0&limit=10"
        let url = NSURL(string: urlstr)
        let urlrequest = NSURLRequest(URL: url!)
        //通过NSURLConnection发送请求
        NSLog("开始请求数据...")
        NSURLConnection.sendAsynchronousRequest(urlrequest, queue: self.op) {
            (response:NSURLResponse!, data:NSData!, error:NSError!) -> Void in
            
            NSLog("下载完成")
            var json = NSJSONSerialization.JSONObjectWithData(data,options:NSJSONReadingOptions.AllowFragments,error:nil) as! NSDictionary
            var result = json.objectForKey("result") as! NSDictionary
            var list = result.objectForKey("list") as! NSArray
            
            if((self.delegate?.getSearchResult) != nil){
                self.delegate?.getSearchResult!(list, error: error)
            }else{
                NSLog("Error")
            }
            
        }
    }
    
    func SuggestionsNpm (keyword:String) {
        
        self.op.cancelAllOperations()
        let urlstr = "https://npm.best/api/search/input/suggestions?type=start&query=" + keyword + "&skip=0&limit=10"
        let url = NSURL(string: urlstr)
        let urlrequest = NSURLRequest(URL: url!)
        //通过NSURLConnection发送请求
        NSLog("开始请求数据...")
        NSURLConnection.sendAsynchronousRequest(urlrequest, queue: self.op) {
            (response:NSURLResponse!, data:NSData!, error:NSError!) -> Void in
            
            NSLog("下载完成")
            var json = NSJSONSerialization.JSONObjectWithData(data,options:NSJSONReadingOptions.AllowFragments,error:nil) as! NSDictionary
            var result = json.objectForKey("result") as! NSDictionary
            var list = result.objectForKey("list") as! NSArray
            
            var resList = [String]()
            
            for (item) in list{
                resList.append(item.objectForKey("w") as! String)
            }
            
            
            if((self.delegate?.getSuggestionsResult) != nil){
                self.delegate?.getSuggestionsResult!(resList, error: error)
            }else{
                NSLog("Error")
            }
            
        }
    }
    
    func GetNpmPackage (package:String) {
        let urlstr = "http://registry.npmjs.org/" + package
        let url = NSURL(string: urlstr)
        let urlrequest = NSURLRequest(URL: url!)
        //通过NSURLConnection发送请求
        NSLog("开始请求数据...")
        NSURLConnection.sendAsynchronousRequest(urlrequest, queue: self.op) {
            (response:NSURLResponse!, data:NSData!, error:NSError!) -> Void in
            
            
            
            if((self.delegate?.getGetNpmPackageResult) != nil){
                self.delegate?.getGetNpmPackageResult!(data, error: error)
            }else{
                NSLog("Error")
            }
            
        }
    }
    
}