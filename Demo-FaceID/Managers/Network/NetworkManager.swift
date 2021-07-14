//
//  NetworkManager.swift
//  Demo-FaceID
//
//  Created by User on 14.07.2021.
//

import Combine
import Alamofire

class NetworkManager {

    @Published var successResponse: LoginResponse?
    @Published var isLoading = false

    func login(email: String, password: String, completion: @escaping(LoginResponse) -> Void) {
        isLoading = true

        let url = "http://18.192.5.103:8080/api/tokens/credentials"
        let params = ["email" : email, "password" : password, "clientSecret" : "edd67720-9c02-11ea-bb37-0242ac130002"]
        let headers : HTTPHeaders = ["Content-Type" : "application/json"]

        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { [weak self] response in
            guard let weakSelf = self else { return }
            switch response.result {
            case .success(_):
                do {
                    let result = try JSONDecoder().decode(LoginResponse.self, from: response.data!)
                    weakSelf.successResponse = result
                    completion(result)
                } catch let error as NSError {
                    print("Failed to load: \(error.localizedDescription)")
                }
            case .failure(let error):
                print("Request error: \(error.localizedDescription)")
            }
            weakSelf.isLoading = false
        }
    }

}
