//
//  UniversalLogin.swift
//  LoginSDK
//
//  Created by coolishbee on 2022/10/18.
//

import Foundation
import GoogleSignIn
import FBSDKLoginKit
import CryptoKit
import AuthenticationServices

class UniversalLogin: NSObject {
    static let shared = UniversalLogin()
    
    private let clientID = "526488632616-v5e8d51cccmonngl07o95c2cr843ri40.apps.googleusercontent.com"
    private lazy var configuration: GIDConfiguration = {
        return GIDConfiguration(clientID: clientID)
    }()
    
    // Unhashed nonce.
    fileprivate var currentNonce: String?
    fileprivate var currentView: UIViewController?
    
    var loginCallback : ((SDKLoginResult?, Error?) -> Void)?
    
    override init() {
        super.init()
    }
    
    public func login(loginType: LoginType,
                      inViewController vc: UIViewController,
                      completionHandler completion: @escaping (SDKLoginResult?, Error?) -> Void)
    {
        
        switch loginType {
        case .google:
            GIDSignIn.sharedInstance.signIn(with: configuration,
                                            presenting: vc)
            {
                user, error in
                guard let user = user else {
                    print("Error! \(String(describing: error))")
                    return
                }
                print(user.userID ?? "nil")
                print(user.profile?.name ?? "nil")
                print(user.profile?.email ?? "nil")
                var pic: URL?
                if ((user.profile?.hasImage) != nil) {
                    pic = user.profile?.imageURL(withDimension: 100)
                    print(pic?.absoluteString ?? "nil")
                }
                let loginResult = LoginResult(userID: user.userID,
                                              name: user.profile?.name,
                                              email: user.profile?.email,
                                              imageURL: pic,
                                              idToken: user.authentication.idToken)
                completion(SDKLoginResult.init(loginResult), nil)
            }
            break
        case .facebook:
            Settings.appID = "2925534737733374"
            Settings.displayName = "Dev"
            
            let loginManager = LoginManager()
            loginManager.logIn(permissions: ["email"],
                               from: vc) { result, error in
                guard error == nil else {
                    print("Error! \(String(describing: error))")
                    return
                }
                guard result?.isCancelled == false else {
                    print("isCancelled")
                    return
                }
                guard let accessToken = AccessToken.current else {
                    print("accessToken is null")
                    return
                }
                            
                //print(accessToken.userID)
                
                GraphRequest(graphPath: "me",
                             parameters: ["fields": "id, name, picture.type(normal), email"]).start(
                                completion: { (connection, result, error) -> Void in
                                    guard error == nil else {
                                        print("Error! \(String(describing: error))")
                                        return
                                    }
//                                    let parsedData = result as! Dictionary<String, AnyObject>?
//                                    if let email = parsedData?["email"] {
//                                        print("Email: \(email as! String)")
//                                    }
                                    if let dictData: [String: Any] = result as? [String: Any] {
                                        DispatchQueue.main.async {
                                            //print(dictData["email"]!)
                                            //print(dictData["name"]!)
                                            //print(dictData["id"]!)
                                            
                                            if let picData: [String: Any] = dictData["picture"] as? [String: Any] {
                                                if let data: [String: Any] = picData["data"] as? [String: Any] {
                                                    //print(data["url"]!)
                                                    let picURL = URL(string: data["url"]! as! String)
                                                    
                                                    let loginResult = LoginResult(userID: accessToken.userID,
                                                                                  name: dictData["name"]! as? String,
                                                                                  email: dictData["email"]! as? String,
                                                                                  imageURL: picURL,
                                                                                  idToken: accessToken.tokenString)
                                                    completion(SDKLoginResult.init(loginResult), nil)
                                                }
                                            }
                                        }
                                    }
                                })
            }
            break
        case .apple:
            if #available(iOS 13, *) {
                self.loginCallback = completion
                startSignInWithAppleFlow()
            } else {
                print("Only available on ios 13 or higher.")
            }
            break
        }
    }
}

@available(iOS 13, *)
extension UniversalLogin: ASAuthorizationControllerDelegate,
                          ASAuthorizationControllerPresentationContextProviding
{
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization)
    {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential
        else {
          print("Unable to retrieve AppleIDCredential")
          return
        }

        guard let nonce = currentNonce else {
          fatalError("Invalid state: A login callback was received, but no login request was sent.")
        }
        guard let appleIDToken = appleIDCredential.identityToken else {
          print("Unable to fetch identity token")
          return
        }
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
          print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
          return
        }
        
        let userName = String(format: "%@%@",
                              appleIDCredential.fullName?.familyName ?? "",
                              appleIDCredential.fullName?.givenName ?? "")
        
        let userEmail = appleIDCredential.email ?? ""
        
        print("nonce: \(nonce)")
        print("idTokenString: \(idTokenString)")
        print("user: \(appleIDCredential.user)")
        print("user name: \(userName)")
        print("user email: \(userEmail)")
        
        let loginResult = LoginResult(userID: appleIDCredential.user,
                                      name: userName,
                                      email: userEmail,
                                      imageURL: nil,
                                      idToken: idTokenString)
        self.loginCallback!(SDKLoginResult.init(loginResult), nil)
    }
    
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithError error: Error)
    {
        print("Sign in with Apple errored: \(error)")
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return currentView!.view.window!
    }
        
    func startSignInWithAppleFlow() {
      let nonce = randomNonceString()
      currentNonce = nonce
      let appleIDProvider = ASAuthorizationAppleIDProvider()
      let request = appleIDProvider.createRequest()
      request.requestedScopes = [.fullName, .email]
      request.nonce = sha256(nonce)

      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
      authorizationController.delegate = self
      authorizationController.presentationContextProvider = self
      authorizationController.performRequests()
    }
    
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError(
              "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
          }
          return random
        }

        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }
        
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }
}

//@available(iOS 13.0, *)
//extension UniversalLogin: ASAuthorizationControllerPresentationContextProviding {
//
//    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
//        return currentView!.view.window!
//    }
//}
