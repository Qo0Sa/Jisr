//
//  Untitled.swift
//  Jisr
//
//  Created by Sarah on 25/12/1447 AH.
//

import Foundation
import FirebaseAuth

final class FirebaseManager {
    static let shared = FirebaseManager()

    private init() {}

    func signInAnonymously() {

        if let user = Auth.auth().currentUser {
            print("Already signed in: \(user.uid)")
            return
        }

        Auth.auth().signInAnonymously { result, error in

            if let error = error {
                print("Firebase Error:")
                print(error.localizedDescription)
                return
            }

            if let user = result?.user {
                print("Firebase UID:")
                print(user.uid)
            }
        }
    }
}
