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
    
    func SearchNpm (keyword:String) {
        let urlstr = "https://npm.best/api/search.json?query=" + keyword + "&skip=0&limit=10"
        guard let url = NSURL(string: urlstr)  else { return }
        let urlrequest = NSURLRequest(URL: url)
        self.op.cancelAllOperations()
        //通过NSURLConnection发送请求
        NSLog("SearchNpm 开始请求数据...")
        NSURLConnection.sendAsynchronousRequest(urlrequest, queue: self.op) {
            (response:NSURLResponse?, data:NSData?, error:NSError?) -> Void in
            if (data == nil){
                return (self.delegate?.getSearchResult?(nil, error: error))!
            }
            NSLog("下载完成")
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!,options:NSJSONReadingOptions.AllowFragments) as! NSDictionary
                let result = json.objectForKey("result") as! NSDictionary
                let list = result.objectForKey("list") as! NSArray
                
                self.delegate?.getSearchResult?(list, error: error)
                
            } catch {
                print("error serializing JSON: \(error)")
            }
        }
    }
    
    func SuggestionsNpm (keyword:String) {
        let urlstr = "https://npm.best/api/search/input/suggestions?type=start&query=" + keyword + "&skip=0&limit=10"
        guard let url = NSURL(string: urlstr) else { return }
        self.op.cancelAllOperations()
        let urlrequest = NSURLRequest(URL: url)
        //通过NSURLConnection发送请求
        NSLog("SuggestionsNpm 开始请求数据...")
        NSURLConnection.sendAsynchronousRequest(urlrequest, queue: self.op) {
            (response:NSURLResponse?, data:NSData?, error:NSError?) -> Void in
            guard let data = data else {
                return (self.delegate?.getSuggestionsResult?(nil, error: error))!
            }
            NSLog("下载完成")
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                let result = json.objectForKey("result") as! NSDictionary
                let list = result.objectForKey("list") as! NSArray
                
                var resList = [String]()
                for (item) in list{
                    resList.append(item.objectForKey("w") as! String)
                }
                
                self.delegate?.getSuggestionsResult?(resList, error: error)
                
            } catch {
                print("error serializing JSON: \(error)")
            }
        }
    }
    
    func GetNpmPackage (package:String) {
        let urlstr = "http://registry.npmjs.org/" + package
        let url = NSURL(string: urlstr)
        let urlrequest = NSURLRequest(URL: url!)
        //通过NSURLConnection发送请求
        NSLog("GetNpmPackage 开始请求数据...")
        NSURLConnection.sendAsynchronousRequest(urlrequest, queue: self.op) {
            (response:NSURLResponse?, data:NSData?, error:NSError?) -> Void in
            
            self.delegate?.getGetNpmPackageResult!(data, error: nil)
        }
    }
    
    func cancleAllRequest() {
        self.op.cancelAllOperations()
    }
    
}