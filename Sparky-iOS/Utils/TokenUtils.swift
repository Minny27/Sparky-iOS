//
//  TokenUtils.swift
//  Sparky-iOS
//
//  Created by SeungMin on 2022/10/10.
//

import Security
import Alamofire
 
final class TokenUtils {
    
    // Create
    // service 파라미터는 url주소를 의미하나 토큰을 캐싱하기만 하기 때문에 큰 의미는 없음
    func create(_ service: String, account: String, value: String) {
        
        // 1. query작성
        let keyChainQuery: NSDictionary = [
            kSecClass : kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecValueData: value.data(using: .utf8, allowLossyConversion: false)!
        ]
        // allowLossyConversion은 인코딩 과정에서 손실이 되는 것을 허용할 것인지 설정
        
        // 2. Delete
        // Key Chain은 Key값에 중복이 생기면 저장할 수 없기때문에 먼저 Delete
        SecItemDelete(keyChainQuery)
        
        // 3. Create
        let status: OSStatus = SecItemAdd(keyChainQuery, nil)
        assert(status == noErr, "failed to saving Token")
    }
    
    // Read
    func read(_ service: String, account: String) -> String? {
        let KeyChainQuery: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecReturnData: kCFBooleanTrue, // CFData타입으로 불러오라는 의미
            kSecMatchLimit: kSecMatchLimitOne // 중복되는 경우 하나의 값만 가져오라는 의미
        ]
        // CFData 타입 -> AnyObject로 받고, Data로 타입변환해서 사용하면됨
        
        // Read
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(KeyChainQuery, &dataTypeRef)
        
        // Read 성공 및 실패한 경우
        if(status == errSecSuccess) {
            let retrievedData = dataTypeRef as! Data
            let value = String(data: retrievedData, encoding: String.Encoding.utf8)
            return value
        } else {
            print("failed to loading, 토큰이 존재하지 않습니다. status code = \(status)")
            return nil
        }
    }
    
    // Delete
    func delete(_ service: String, account: String) {
        let keyChainQuery: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ]
        
        let status = SecItemDelete(keyChainQuery)
        assert(status == noErr, "토큰이 존재하지 않습니다. status code = \(status)")
    }
    
    // HTTPHeaders 구성
    func getAuthorizationHeaderString() -> String {
        let serviceID = "com.sparky.token"
        if let accessToken = self.read(serviceID, account: "accessToken") {
//            return ["Authorization" : "bearer \(accessToken)"] as HTTPHeaders
            print("accessToken - \(accessToken)")
            return accessToken
        } else {
            if let refreshToken = self.read(serviceID, account: "refreshToken") {
                print("refreshToken - \(refreshToken)")
                return refreshToken
            } else {
                return ""
            }
        }
    }
    
//    func getAccessToken() -> String? {
//        let serviceID = "com.sparky.token"
//        if let accessToken = self.read(serviceID, account: "accessToken") {
////            return ["Authorization" : "bearer \(accessToken)"] as HTTPHeaders
//            print("accessToken - \(accessToken)")
//            return accessToken
//        } else {
//            return nil
//        }
//    }
//
//    func getRefreshToken() -> String? {
//        let serviceID = "com.sparky.token"
//        if let refreshToken = self.read(serviceID, account: "refreshToken") {
////            return ["Authorization" : "bearer \(accessToken)"] as HTTPHeaders
//            print("refreshToken - \(refreshToken)")
//            return refreshToken
//        } else {
//            return nil
//        }
//    }
}
