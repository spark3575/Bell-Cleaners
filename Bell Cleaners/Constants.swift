//
//  Constants.swift
//  Bell Cleaners
//
//  Created by Shin Park on 6/13/17.
//  Copyright © 2017 shinparkdev. All rights reserved.
//

import UIKit

struct Constants {
    
    struct Alerts {
        
        struct Titles {
            static let CreateAccountFailed = "Create Account Failed"
            static let CreateAccountSuccesful = "Create Account Succesful"
            static let EmailVerification = "Email Verification Required"
            static let Location = "Location Services Required"
            static let MapAppsAvailable = "Available Maps"
            static let MissingFields = "Missing Fields"
            static let Password = "Password Required"
            static let ReAuthenticationFailed = "Re-authentication Failed"
            static let SignInFailed = "Sign In Failed"
            static let TouchID = "Touch ID not available"
            static let UpdateEmailFailed = "Update Email Failed"
            static let UpdateEmailSuccesful = "Update Email Successful"
            static let UpdatePasswordFailed = "Update Password Failed"
            static let UpdatePasswordSuccesful = "Update Password Successful"
            static let UserNotFound = "User Not Found"
            static let ValidEmail = "Valid Email Address Required"
        }
        
        struct Messages {
            static let AllRequired = "All fields required for pickup & delivery"
            static let CheckEmailPassword = "Please check your email address or password"
            static let CheckVerificationEmail = "Please check your email to verify and sign in"
            static let CreateNewAccount = "Please create a new account"
            static let Location = "Authorization can be changed in your Privacy Settings"
            static let MapAppsAvailable = "Which do you prefer"
            static let MissingFields = "Full name and phone number required to access your account"
            static let Password = "Enter atleast 6 characters"
            static let ReAuthenticationFailed = "Incorrect password"
            static let TouchSettings = "Authorization can be changed in your Touch ID Settings"
            static let UpdateEmailFailed = "Incorrect password"
            static let UpdateEmailSuccesful = "Please check your updated email to verify and sign in"
            static let UpdatePasswordFailed = "Please check your passwords"
            static let UpdatePasswordSuccesful = "Please sign in using your new password"
            static let VerificationEmail = "Verification email will be sent"
            static let VerifyEmail = "Please check your email to verify"
        }
        
        struct Actions {
            static let AppleMaps = "Apple Maps"
            static let Cancel = "Cancel"
            static let CreateAccount = "Create Account"
            static let GoogleMaps = "Google Maps"
            static let OK = "OK"
            static let SendVerificationEmail = "Send Verification Email"
            static let Settings = "Settings"
        }        
    }
    
    struct Animations {
        
        struct Keyboard {
            static let DurationShow = 0.3
            static let DurationHide = 0.3
        }
        
        struct Segue {
            static let Delay = 0.0
            static let Duration = 0.3
            static let TranslationX: CGFloat = 0
            static let TranslationY: CGFloat = 0
        }
        
        struct Shake {
            static let Duration = 0.3
            static let FromValue = 0.0
            static let KeyPath = "transform.rotation"
            static let RepeatCount: Float = 2
            static let ToValue = -(CGFloat.pi / 3)
        }
        
        struct Switch {
            static let Duration = 0.3
        }
        
        struct Touch {
            static let Duration = 0.2
            static let ScaleX: CGFloat = 1.1
            static let ScaleY: CGFloat = 1.1
        }
    }
    
    struct CGRects {
        static let Dx: CGFloat = 12
        static let Dy: CGFloat = 0
    }
    
    struct Colors {
        static let BellGreen = UIColor(red: 64.0 / 255.0, green: 170.0 / 255.0, blue: 107.0 / 255.0, alpha: 1.0)
        static let BellRed = UIColor(red: 230.0 / 255.0, green: 81.0 / 255.0, blue: 85.0 / 255.0, alpha: 1.0)
    }
    
    struct Coordinates {
        static let BellLatitude = 32.705250
        static let BellLongitude = -96.799470
        static let SpanLatitudeDelta = 0.0027
        static let SpanLongitudeDelta = 0.0027
    }
    
    struct DefaultsKeys {
        static let AbleToAccessMyAccount = "ableToAccessMyAccount"
        static let AbleToAccessPickupDelivery = "ableToAccessPickupDelivery"
        static let Email = "email"
        static let HasSignedInBefore = "hasSignedInBefore"
        static let HasUsedTouch = "hasUsedTouch"
    }
    
    struct ErrorMessages {
        static let Default = "There was a problem. Please try again."
        static let EmailAlreadyInUse = "Email already in use"
        static let InvalidEmail = "Invalid email address"
        static let InvalidPassword = "Invalid password"
        static let KeyChain = "Keychain Update Failed - "
        static let LAAuthentication = "Authentication Failed"
        static let LACancel = "Touch ID cancelled"
        static let LADefault = "Touch ID Failed"
        static let LAPasscode = "Passcode needs to be set to use Touch ID"
        static let NetworkConnection = "Network connection not available"
        static let RequiresRecentLogin = "Requires recent login"
        static let SetDisplayName = "Set Display Name Failed - "
        static let SignOut = "Sign Out Failed - "
        static let TouchID = "Touch ID not available"
        static let UserNotFound = "User not found"
        static let VerificationEmail = "Verification Email Failed - "
    }
    
    struct KeychainConfigurations {
        static let AccessGroup: String? = nil
        static let Email = "email"
        static let ServiceName = "Bell Cleaners"
    }
    
    struct Keyboards {
        static let ActionDone = "Done"
        static let ActionNext = "Next"
        static let ToolbarHeight: CGFloat = 40
        static let OriginalConstraint: CGFloat = 84
        static let SpaceToText: CGFloat = 10
    }
    
    struct Layers {
        static let BorderWidth: CGFloat = 2.0
        static let CornerRadius: CGFloat = 10.0
        static let ShadowColor = UIColor.black.cgColor
        static let ShadowOffset = CGSize(width: 0, height: 2.0)
        static let ShadowOpacity: Float = 0.5
        static let ShadowRadius: CGFloat = 4.0
        static let textFieldShadowOffset = CGSize(width: 0, height: 1.0)
        static let textFieldShadowOpacity: Float = 0.3
        static let textFieldShadowRadius: CGFloat = 3.0
    }
    
    struct Literals {
        static let AbleToAccessMyAccount = "ableToAccessMyAccount"
        static let Address = "address"
        static let AdminEmail = "bellcleaners@gmail.com"
        static let BellCleaners = "Bell Cleaners"
        static let City = "city"
        static let Comma = ","
        static let CreateAccount = "Create Account"
        static let DecimalPlaces = "%.5f"
        static let Email = "email"
        static let EmptyString = ""
        static let ExpertGarmentCare = "Expert Garment Care"
        static let FirstName = "firstName"
        static let KeyboardWillShow = "keyboardWillShow"
        static let LastName = "lastName"
        static let LocalizedReason = "Sign In with Touch ID"
        static let MailTo = "mailto:"
        static let Map = "Map"
        static let Password = "password"
        static let PhoneNumber = "phoneNumber"
        static let PickupDelivery = "pickupDelivery"
        static let Profile = "profile"
        static let SecureText: Character = "•"
        static let SignIn = "Sign In"
        static let Users = "users"
        static let Zipcode = "zipcode"
    }
    
    struct Sounds {
        
        struct Files {
            static let DingSmallBell = "dingSmallBell"
        }
        
        struct Extensions {
            static let Mp3 = "mp3"
        }
    }
    
    struct Segues {
        static let AccessAccountVC = "AccessAccountVC"
        static let AdminVC = "AdminVC"
        static let BellCleanersVC = "BellCleanersVC"
        static let MyAccountVC = "MyAccountVC"
        static let ProfileVC = "ProfileVC"
        static let UpdateEmailVC = "UpdateEmailVC"
        static let UpdatePasswordVC = "UpdatePasswordVC"
        static let UnwindToAccessAccountVC = "unwindToAccessAccountVC"
        static let UnwindToBellCleanersVC = "unwindToBellCleanersVC"
    }
    
    struct TimerIntervals {
        static let BellShakeDelay = 0.5
        static let FirebaseDelay = 1.0
    }
    
    struct URLs {
        static let Google = "comgooglemaps://"
        static let PhoneNumber = URL(string: "tel://2143747007")
        static let Settings = URL(string: UIApplicationOpenSettingsURLString)
        
        struct AppleMaps {
            static let BellURLPrefix = "https://maps.apple.com/?saddr="
            static let BellURLSuffix = "&daddr=3508+S+Lancaster+Rd+75216"
        }
        
        struct GoogleMaps {
            static let BellURLPrefix = "comgooglemaps://?saddr="
            static let BellURLSuffix = "&daddr=3508+S+Lancaster+Rd+75216"
        }
    }
    
    struct Validations {
        
        struct Email {
            static let MatchesCount = 1
            static let RangeLocation = 0
        }
        
        struct Password {
            static let MinimumLength = 6
        }
    }
}
