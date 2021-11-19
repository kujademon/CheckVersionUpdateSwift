//
//  CheckVersion.swift
//
//  Created by Pitchaorn on 22/10/2561 BE.
//

import Foundation
import UIKit

class CheckVersion:NSObject{
    enum VersionError: Error {
        case invalidResponse, invalidBundleInfo
    }
    
    lazy var defaultSession: URLSession = {
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        
        return session
    }()
    
    func isUpdateAvailable(completion: @escaping (Error?) -> Void) throws -> URLSessionDataTask {
        guard let info = Bundle.main.infoDictionary,
            let currentVersion = info["CFBundleShortVersionString"] as? String,
            let identifier = info["CFBundleIdentifier"] as? String,
            let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(identifier)") else {
                throw VersionError.invalidBundleInfo
        }
        
        let task = defaultSession.dataTask(with: url) { (data, response, error) in
            do {
                if let error = error { throw error }
                guard let data = data else { throw VersionError.invalidResponse }
                let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any]
                guard let result = (json?["results"] as? [Any])?.first as? [String: Any], let version = result["version"] as? String else {
                    throw VersionError.invalidResponse
                }
                if currentVersion.compare(version, options: .numeric) == .orderedAscending{
                    
                    let bundleDisplayName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
                    let bundleName = Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as? String
                    
                    let alert = UIAlertController(title: "มีการอัพเดต", message: String(format: "เวอร์ชั่นใหม่ของ %@ สามารถใช้งานได้แล้ว กรุณาอัพเดทแอพให้เป็นเวอร์ชั่น %@ ", bundleDisplayName ?? bundleName ?? "", version), preferredStyle: .alert)
                    
                    
                    let action = UIAlertAction(title: "อัพเดต", style: .default) {  _ in
                        
                        guard let appID = result["trackId"] else {
                            
                            return
                        }
                        
                        
                        guard let url = URL(string: "https://itunes.apple.com/app/id\(appID)") else {
                                return
                        }
                        
                        DispatchQueue.main.async {
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            } else {
                                UIApplication.shared.openURL(url)
                            }
                        }
                        
                        
                    }
                    
                    alert.addAction(action)
                    DispatchQueue.main.async {
                        
                        
                        if let vc =  UIApplication.topViewController(){
                            vc.present(alert, animated: true, completion: nil)
                        }
                        
                    }
                }
                completion(nil)
            } catch {
                completion(error)
            }
        }
        task.resume()
        return task
    }
    
}

extension CheckVersion: URLSessionDelegate {
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
    
}
