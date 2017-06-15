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
            static let Email = "Valid Email Address Required"
            static let Location = "Location Services Required"
            static let MapAppsAvailable = "Available Maps"
            static let MissingFields = "Missing Fields"
            static let Password = "Password Required"
            static let SignInFailed = "Sign In Failed"
            static let TouchID = "Touch ID not available"
            static let UserNotFound = "User Not Found"
        }
        
        struct Messages {
            static let AllRequired = "All fields required for pickup & delivery"
            static let CheckEmailPassword = "Please check your email address or password"
            static let CreateNewAccount = "Please create a new account"
            static let Email = "Verification email will be sent"
            static let Location = "Authorization can be changed in your Privacy Settings"
            static let MapAppsAvailable = "Which do you prefer"
            static let MissingFields = "Full name and phone number required to access your account"
            static let Password = "Enter atleast 6 characters"
            static let TouchSettings = "Authorization can be changed in your Touch ID Settings"
        }
        
        struct Actions {
            static let AppleMaps = "Apple Maps"
            static let Cancel = "Cancel"
            static let CreateAccount = "Create Account"
            static let GoogleMaps = "Google Maps"
            static let OK = "OK"
            static let Settings = "Settings"
        }        
    }
    
    struct Animations {
        
        struct Segue {
            static let Delay = 0.0
            static let Duration = 0.25
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
        static let BellColor = UIColor(red: 64.0 / 255.0, green: 170.0 / 255.0, blue: 107.0 / 255.0, alpha: 1.0)
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
        static let SignOut = "Sign Out Failed - "
        static let TouchID = "Touch ID not available"
        static let UserNotFound = "User not found"
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
        static let OriginalConstraint: CGFloat = 64
        static let SpaceToText: CGFloat = 8
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
        static let BellCleaners = "Bell Cleaners"
        static let City = "city"
        static let Comma = ","
        static let CreateAccount = "Create Account"
        static let DecimalPlaces = "%.5f"
        static let Email = "email"
        static let EmptyString = ""
        static let ExpertGarmentCare = "Expert Garment Care"
        static let FirstName = "firstName"
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
        static let AccessAccount = "AccessAccountVC"
        static let BellCleaners = "BellCleanersVC"
        static let MyAccount = "MyAccountVC"
        static let Profile = "ProfileVC"
    }
    
    struct TimerIntervals {
        static let BellShake = 0.5
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
